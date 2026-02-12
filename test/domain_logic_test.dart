import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nyaya_uday/models/roadmap_model.dart';
import 'package:nyaya_uday/models/state_catalog.dart';
import 'package:nyaya_uday/models/user_model.dart';
import 'package:nyaya_uday/providers/user_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rank thresholds', () {
    test('matches configured ladder', () {
      expect(UserModel.getRankTitle(0), 'Trainee');
      expect(UserModel.getRankTitle(50), 'Trainee Magistrate');
      expect(UserModel.getRankTitle(100), 'Junior Judge');
      expect(UserModel.getRankTitle(200), 'Senior Magistrate');
      expect(UserModel.getRankTitle(350), 'District Judge');
      expect(UserModel.getRankTitle(500), 'High Court Judge');
    });
  });

  group('State normalization and roadmap mapping', () {
    test('normalizes code and full state name consistently', () {
      expect(StateCatalog.normalizeCode('UP'), 'UP');
      expect(StateCatalog.normalizeCode('Uttar Pradesh'), 'UP');
      expect(StateCatalog.displayName('UP'), 'Uttar Pradesh');
    });

    test('returns state-specific roadmap for state code', () {
      final roadmap = RoadmapData.getDefaultRoadmap('UP', 'class_12');
      expect(roadmap.state, 'Uttar Pradesh');
      expect(roadmap.steps[3].title, 'UP PCS-J Exam');
    });
  });

  group('User provider badge migration and scoring', () {
    test('migrates legacy badge ids on initialize', () async {
      SharedPreferences.setMockInitialValues({
        'is_onboarded': true,
        'user_state': 'UP',
        'user_education': 'class_12',
        'preferred_language': 'en',
        'total_score': 120,
        'cases_completed': 10,
        'badges': ['ten_cases', 'century', 'first_case'],
        'rank': 'Trainee',
      });

      final provider = UserProvider();
      await provider.initialize();

      final badges = provider.user?.badges ?? [];
      expect(badges.contains('dedicated'), true);
      expect(badges.contains('centurion'), true);
      expect(badges.contains('ten_cases'), false);
      expect(badges.contains('century'), false);
      expect(provider.user?.rank, 'Junior Judge');
    });

    test('awards expected badges without duplicates', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = UserProvider();

      await provider.saveUser(state: 'UP', educationLevel: 'class_12');
      await provider.updateScore(15); // first case + perfect + fair
      await provider.updateScore(12); // fair again should not duplicate

      final badges = provider.user?.badges ?? [];
      expect(badges.where((b) => b == 'first_case').length, 1);
      expect(badges.where((b) => b == 'perfect_judgment').length, 1);
      expect(badges.where((b) => b == 'fair_judge').length, 1);
    });
  });
}

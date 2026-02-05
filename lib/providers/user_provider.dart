import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/roadmap_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isOnboarded = false;

  // User profile fields (local only - no cloud auth)
  String? _displayName;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _isOnboarded;

  String? get displayName => _displayName;

  // Initialize from local storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    _displayName = prefs.getString('user_display_name');

    if (_isOnboarded) {
      _user = UserModel(
        state: prefs.getString('user_state') ?? '',
        educationLevel: prefs.getString('user_education') ?? '',
        preferredLanguage: prefs.getString('preferred_language') ?? 'en',
        totalScore: prefs.getInt('total_score') ?? 0,
        casesCompleted: prefs.getInt('cases_completed') ?? 0,
        badges: prefs.getStringList('badges') ?? [],
        rank: prefs.getString('rank') ?? 'Trainee',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile name
  Future<void> updateDisplayName(String name) async {
    _displayName = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_display_name', name);

    notifyListeners();
  }

  // Save user after onboarding
  Future<void> saveUser({
    required String state,
    required String educationLevel,
    String preferredLanguage = 'en',
  }) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    await prefs.setString('user_state', state);
    await prefs.setString('user_education', educationLevel);
    await prefs.setString('preferred_language', preferredLanguage);
    await prefs.setInt('total_score', 0);
    await prefs.setInt('cases_completed', 0);
    await prefs.setStringList('badges', []);
    await prefs.setString('rank', 'Trainee');

    _user = UserModel(
      state: state,
      educationLevel: educationLevel,
      preferredLanguage: preferredLanguage,
    );
    _isOnboarded = true;

    _isLoading = false;
    notifyListeners();
  }

  // Update score after simulation
  Future<void> updateScore(int additionalScore) async {
    if (_user == null) return;

    final newScore = _user!.totalScore + additionalScore;
    final newCasesCompleted = _user!.casesCompleted + 1;
    final newRank = UserModel.getRankTitle(newScore);

    // Check for new badges
    List<String> newBadges = List.from(_user!.badges);
    if (newCasesCompleted == 1 && !newBadges.contains('first_case')) {
      newBadges.add('first_case');
    }
    if (newCasesCompleted >= 3 && !newBadges.contains('quick_learner')) {
      newBadges.add('quick_learner');
    }
    if (newCasesCompleted >= 5 && !newBadges.contains('five_cases')) {
      newBadges.add('five_cases');
    }
    if (newCasesCompleted >= 10 && !newBadges.contains('dedicated')) {
      newBadges.add('dedicated');
    }
    if (newCasesCompleted >= 15 && !newBadges.contains('expert')) {
      newBadges.add('expert');
    }
    if (newScore >= 50 && !newBadges.contains('rising_star')) {
      newBadges.add('rising_star');
    }
    if (newScore >= 100 && !newBadges.contains('centurion')) {
      newBadges.add('centurion');
    }
    if (newScore >= 200 && !newBadges.contains('judicial_master')) {
      newBadges.add('judicial_master');
    }
    if (additionalScore == 15 && !newBadges.contains('perfect_judgment')) {
      newBadges.add('perfect_judgment');
    }
    if (additionalScore >= 12 && !newBadges.contains('fair_judge')) {
      newBadges.add('fair_judge');
    }

    _user = _user!.copyWith(
      totalScore: newScore,
      casesCompleted: newCasesCompleted,
      rank: newRank,
      badges: newBadges,
    );

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_score', newScore);
    await prefs.setInt('cases_completed', newCasesCompleted);
    await prefs.setString('rank', newRank);
    await prefs.setStringList('badges', newBadges);

    notifyListeners();
  }

  // Get roadmap for user
  RoadmapModel? getRoadmap() {
    if (_user == null) return null;
    return RoadmapData.getDefaultRoadmap(_user!.state, _user!.educationLevel);
  }

  // Update preferred language
  Future<void> updateLanguage(String language) async {
    if (_user == null) return;

    _user = _user!.copyWith(preferredLanguage: language);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', language);

    notifyListeners();
  }

  // Get badge display info
  Map<String, Map<String, String>> get badgeInfo => {
    'first_case': {
      'title': 'First Case',
      'titleHi': 'पहला केस',
      'icon': '⚖️',
      'description': 'Completed your first case',
      'descriptionHi': 'अपना पहला केस पूरा किया',
    },
    'quick_learner': {
      'title': 'Quick Learner',
      'titleHi': 'तीव्र सीखने वाला',
      'icon': '🎯',
      'description': 'Completed 3 cases',
      'descriptionHi': '3 केस पूरे किए',
    },
    'five_cases': {
      'title': 'Case Expert',
      'titleHi': 'केस विशेषज्ञ',
      'icon': '🏆',
      'description': 'Completed 5 cases',
      'descriptionHi': '5 केस पूरे किए',
    },
    'dedicated': {
      'title': 'Dedicated Judge',
      'titleHi': 'समर्पित न्यायाधीश',
      'icon': '👨‍⚖️',
      'description': 'Completed 10 cases',
      'descriptionHi': '10 केस पूरे किए',
    },
    'expert': {
      'title': 'Legal Expert',
      'titleHi': 'कानूनी विशेषज्ञ',
      'icon': '📚',
      'description': 'Completed all 15 cases',
      'descriptionHi': '15 केस पूरे किए',
    },
    'rising_star': {
      'title': 'Rising Star',
      'titleHi': 'उभरता सितारा',
      'icon': '⭐',
      'description': 'Scored 50+ points',
      'descriptionHi': '50+ अंक प्राप्त किए',
    },
    'centurion': {
      'title': 'Centurion',
      'titleHi': 'शतकवीर',
      'icon': '💫',
      'description': 'Scored 100+ points',
      'descriptionHi': '100+ अंक प्राप्त किए',
    },
    'judicial_master': {
      'title': 'Judicial Master',
      'titleHi': 'न्यायिक गुरु',
      'icon': '👑',
      'description': 'Scored 200+ points',
      'descriptionHi': '200+ अंक प्राप्त किए',
    },
    'perfect_judgment': {
      'title': 'Perfect Judgment',
      'titleHi': 'सटीक निर्णय',
      'icon': '💯',
      'description': 'Got maximum score in a case',
      'descriptionHi': 'एक केस में अधिकतम अंक प्राप्त किए',
    },
    'fair_judge': {
      'title': 'Fair Judge',
      'titleHi': 'निष्पक्ष न्यायाधीश',
      'icon': '⚡',
      'description': 'Scored 12+ in a case',
      'descriptionHi': 'एक केस में 12+ अंक प्राप्त किए',
    },
  };
}

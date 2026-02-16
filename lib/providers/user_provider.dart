import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/roadmap_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isOnboarded = false;
  static const Map<String, String> _legacyBadgeAliases = {
    'ten_cases': 'dedicated',
    'century': 'centurion',
  };

  // User profile fields (local only - no cloud auth)
  String? _displayName;

  // Roadmap step completion tracking
  Set<int> _completedSteps = {};

  // Study streak tracking
  int _streakDays = 0;
  String? _lastActiveDate;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _isOnboarded;

  String? get displayName => _displayName;
  Set<int> get completedSteps => _completedSteps;
  int get streakDays => _streakDays;

  // Initialize from local storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    _displayName = prefs.getString('user_display_name');
    final savedSteps = prefs.getStringList('completed_roadmap_steps') ?? [];
    _completedSteps = savedSteps.map(int.parse).toSet();

    // Load streak data
    _streakDays = prefs.getInt('streak_days') ?? 0;
    _lastActiveDate = prefs.getString('last_active_date');
    await _updateStreak(prefs);

    if (_isOnboarded) {
      final savedScore = prefs.getInt('total_score') ?? 0;
      final savedBadges = prefs.getStringList('badges') ?? [];
      final normalizedBadges = _normalizeBadges(savedBadges);
      final normalizedRank = UserModel.getRankTitle(savedScore);

      if (!_listEquals(savedBadges, normalizedBadges)) {
        await prefs.setStringList('badges', normalizedBadges);
      }
      if ((prefs.getString('rank') ?? '') != normalizedRank) {
        await prefs.setString('rank', normalizedRank);
      }

      _user = UserModel(
        state: prefs.getString('user_state') ?? '',
        educationLevel: prefs.getString('user_education') ?? '',
        preferredLanguage: prefs.getString('preferred_language') ?? 'en',
        totalScore: savedScore,
        casesCompleted: prefs.getInt('cases_completed') ?? 0,
        badges: normalizedBadges,
        rank: normalizedRank,
        age: prefs.getInt('user_age'),
        category: prefs.getString('user_category'),
        gender: prefs.getString('user_gender'),
        annualIncome: prefs.getDouble('user_annual_income'),
        hasDisability: prefs.getBool('user_has_disability'),
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
    int? age,
    String? category,
    String? gender,
    double? annualIncome,
    bool? hasDisability,
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
    if (age != null) await prefs.setInt('user_age', age);
    if (category != null) await prefs.setString('user_category', category);
    if (gender != null) await prefs.setString('user_gender', gender);
    if (annualIncome != null) {
      await prefs.setDouble('user_annual_income', annualIncome);
    }
    if (hasDisability != null) {
      await prefs.setBool('user_has_disability', hasDisability);
    }

    _user = UserModel(
      state: state,
      educationLevel: educationLevel,
      preferredLanguage: preferredLanguage,
      age: age,
      category: category,
      gender: gender,
      annualIncome: annualIncome,
      hasDisability: hasDisability,
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
    List<String> newBadges = _normalizeBadges(_user!.badges);
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
    newBadges = _normalizeBadges(newBadges);

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

  /// Update any combination of profile fields at runtime.
  Future<void> updateProfile({
    String? state,
    String? educationLevel,
    int? age,
    String? category,
    String? gender,
    double? annualIncome,
    bool? hasDisability,
  }) async {
    if (_user == null) return;

    final prefs = await SharedPreferences.getInstance();

    if (state != null) {
      await prefs.setString('user_state', state);
    }
    if (educationLevel != null) {
      await prefs.setString('user_education', educationLevel);
    }
    if (age != null) {
      await prefs.setInt('user_age', age);
    }
    if (category != null) {
      await prefs.setString('user_category', category);
    }
    if (gender != null) {
      await prefs.setString('user_gender', gender);
    }
    if (annualIncome != null) {
      await prefs.setDouble('user_annual_income', annualIncome);
    }
    if (hasDisability != null) {
      await prefs.setBool('user_has_disability', hasDisability);
    }

    _user = _user!.copyWith(
      state: state,
      educationLevel: educationLevel,
      age: age,
      category: category,
      gender: gender,
      annualIncome: annualIncome,
      hasDisability: hasDisability,
    );

    notifyListeners();
  }

  // ── Roadmap step progress ──────────────────────────────────
  bool isStepCompleted(int stepOrder) => _completedSteps.contains(stepOrder);

  Future<void> toggleStepCompletion(int stepOrder) async {
    if (_completedSteps.contains(stepOrder)) {
      _completedSteps.remove(stepOrder);
    } else {
      _completedSteps.add(stepOrder);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'completed_roadmap_steps',
      _completedSteps.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }

  int get totalRoadmapSteps {
    final roadmap = getRoadmap();
    return roadmap?.steps.length ?? 0;
  }

  double get roadmapProgress {
    final total = totalRoadmapSteps;
    if (total == 0) return 0;
    return _completedSteps.length / total;
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

  List<String> _normalizeBadges(List<String> badges) {
    final normalized = <String>{};
    for (final badge in badges) {
      final mapped = _legacyBadgeAliases[badge] ?? badge;
      if (badgeInfo.containsKey(mapped)) {
        normalized.add(mapped);
      }
    }
    final list = normalized.toList()..sort();
    return list;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ── Study Streak ──────────────────────────────────────────

  /// Returns today's date as yyyy-MM-dd string.
  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Called on app launch to update the streak.
  Future<void> _updateStreak(SharedPreferences prefs) async {
    final today = _todayString();

    if (_lastActiveDate == null) {
      // First ever launch
      _streakDays = 1;
      _lastActiveDate = today;
    } else if (_lastActiveDate == today) {
      // Already opened today — no change
      return;
    } else {
      // Check if yesterday
      final lastDate = DateTime.tryParse(_lastActiveDate!);
      final todayDate = DateTime.tryParse(today);
      if (lastDate != null && todayDate != null) {
        final diff = todayDate.difference(lastDate).inDays;
        if (diff == 1) {
          _streakDays += 1; // consecutive day
        } else {
          _streakDays = 1; // streak broken
        }
      } else {
        _streakDays = 1;
      }
      _lastActiveDate = today;
    }

    await prefs.setInt('streak_days', _streakDays);
    await prefs.setString('last_active_date', _lastActiveDate!);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the two LLB pathway options
enum LlbPathway {
  /// 5-Year LLB: After Class 12 (integrated program)
  fiveYear,

  /// 3-Year LLB: After graduation
  threeYear,
}

/// Extension methods for LlbPathway enum
extension LlbPathwayExtension on LlbPathway {
  /// Returns the storage key value
  String get storageValue {
    switch (this) {
      case LlbPathway.fiveYear:
        return '5_year';
      case LlbPathway.threeYear:
        return '3_year';
    }
  }

  /// Returns display name in English
  String get displayName {
    switch (this) {
      case LlbPathway.fiveYear:
        return '5-Year LLB';
      case LlbPathway.threeYear:
        return '3-Year LLB';
    }
  }

  /// Returns display name in Hindi
  String get displayNameHindi {
    switch (this) {
      case LlbPathway.fiveYear:
        return '5-वर्षीय LLB';
      case LlbPathway.threeYear:
        return '3-वर्षीय LLB';
    }
  }

  /// Returns short badge text
  String get badgeText {
    switch (this) {
      case LlbPathway.fiveYear:
        return '5Y LLB';
      case LlbPathway.threeYear:
        return '3Y LLB';
    }
  }

  /// Returns description in English
  String get description {
    switch (this) {
      case LlbPathway.fiveYear:
        return 'After 12th • Integrated BA/BBA LLB • CLAT/AILET';
      case LlbPathway.threeYear:
        return 'After Graduation • 3-Year LLB • Law Entrance';
    }
  }

  /// Returns description in Hindi
  String get descriptionHindi {
    switch (this) {
      case LlbPathway.fiveYear:
        return '12वीं के बाद • इंटीग्रेटेड BA/BBA LLB • CLAT/AILET';
      case LlbPathway.threeYear:
        return 'ग्रेजुएशन के बाद • 3-वर्षीय LLB • लॉ प्रवेश परीक्षा';
    }
  }

  /// Returns eligibility in English
  String get eligibility {
    switch (this) {
      case LlbPathway.fiveYear:
        return '45% in 12th (40% for SC/ST/OBC)';
      case LlbPathway.threeYear:
        return '45% in Graduation (40% for SC/ST/OBC)';
    }
  }

  /// Returns eligibility in Hindi
  String get eligibilityHindi {
    switch (this) {
      case LlbPathway.fiveYear:
        return '12वीं में 45% (SC/ST/OBC के लिए 40%)';
      case LlbPathway.threeYear:
        return 'ग्रेजुएशन में 45% (SC/ST/OBC के लिए 40%)';
    }
  }

  /// Returns icon emoji
  String get icon {
    switch (this) {
      case LlbPathway.fiveYear:
        return '📚';
      case LlbPathway.threeYear:
        return '🎓';
    }
  }

  /// Returns estimated duration to become a judge
  String get durationToJudge {
    switch (this) {
      case LlbPathway.fiveYear:
        return '7-8 years';
      case LlbPathway.threeYear:
        return '5-6 years';
    }
  }

  /// Returns estimated duration in Hindi
  String get durationToJudgeHindi {
    switch (this) {
      case LlbPathway.fiveYear:
        return '7-8 वर्ष';
      case LlbPathway.threeYear:
        return '5-6 वर्ष';
    }
  }
}

/// Provider for managing LLB pathway selection
class LlbPathwayProvider extends ChangeNotifier {
  static const String _storageKey = 'llb_pathway';

  LlbPathway? _selectedPathway;
  bool _isInitialized = false;

  /// The currently selected LLB pathway
  LlbPathway? get selectedPathway => _selectedPathway;

  /// Whether a pathway has been selected
  bool get hasSelectedPathway => _selectedPathway != null;

  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(_storageKey);

    if (storedValue != null) {
      _selectedPathway = _parsePathway(storedValue);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Set the selected pathway and persist to storage
  Future<void> setPathway(LlbPathway pathway) async {
    _selectedPathway = pathway;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, pathway.storageValue);

    notifyListeners();
  }

  /// Clear the selected pathway (for reset/logout)
  Future<void> clearPathway() async {
    _selectedPathway = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    notifyListeners();
  }

  /// Parse storage value to enum
  LlbPathway? _parsePathway(String value) {
    switch (value) {
      case '5_year':
        return LlbPathway.fiveYear;
      case '3_year':
        return LlbPathway.threeYear;
      default:
        return null;
    }
  }

  /// Get localized display name
  String getDisplayName(bool isHindi) {
    if (_selectedPathway == null) return '';
    return isHindi
        ? _selectedPathway!.displayNameHindi
        : _selectedPathway!.displayName;
  }

  /// Get localized description
  String getDescription(bool isHindi) {
    if (_selectedPathway == null) return '';
    return isHindi
        ? _selectedPathway!.descriptionHindi
        : _selectedPathway!.description;
  }
}

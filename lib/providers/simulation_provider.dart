import 'package:flutter/material.dart';
import '../models/case_scenario_model.dart';

class SimulationProvider extends ChangeNotifier {
  List<CaseScenario> _cases = [];
  int _currentCaseIndex = 0;
  Map<String, String> _selectedOptions = {}; // caseId -> optionId
  bool _isLoading = false;

  List<CaseScenario> get cases => _cases;
  int get currentCaseIndex => _currentCaseIndex;
  CaseScenario? get currentCase =>
      _currentCaseIndex < _cases.length ? _cases[_currentCaseIndex] : null;
  bool get isLoading => _isLoading;
  bool get hasMoreCases => _currentCaseIndex < _cases.length - 1;

  // Load cases
  Future<void> loadCases() async {
    _isLoading = true;
    notifyListeners();

    // Load bundled offline case data.
    await Future.delayed(const Duration(milliseconds: 150));
    _cases = CaseData.getSampleCases();
    _currentCaseIndex = 0;
    _selectedOptions = {};

    _isLoading = false;
    notifyListeners();
  }

  // Select an option for a specific case
  void selectOption(String caseId, String optionId) {
    _selectedOptions[caseId] = optionId;
    notifyListeners();
  }

  // Get selected option for a case
  String? getSelectedOption(String caseId) {
    return _selectedOptions[caseId];
  }

  // Check if current case has a selection
  bool get hasSelection =>
      currentCase != null && _selectedOptions.containsKey(currentCase!.id);

  // Get score for a case
  Map<String, int>? getScoreForCase(String caseId, String locale) {
    final optionId = _selectedOptions[caseId];
    if (optionId == null) {
      return null;
    }

    final caseScenario = _cases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => _cases.first,
    );

    final options = caseScenario.getOptions(locale);

    final selectedOption = options.firstWhere(
      (o) => o.id == optionId,
      orElse: () {
        return options.first;
      },
    );

    return {
      'fairness': selectedOption.fairnessScore,
      'evidence': selectedOption.evidenceScore,
      'bias': selectedOption.biasScore,
      'total': selectedOption.totalScore,
    };
  }

  // Move to next case
  void nextCase() {
    if (hasMoreCases) {
      _currentCaseIndex++;
      notifyListeners();
    }
  }

  // Reset simulation
  void reset() {
    _currentCaseIndex = 0;
    _selectedOptions = {};
    notifyListeners();
  }

  // Get case by index
  CaseScenario? getCaseByIndex(int index) {
    if (index >= 0 && index < _cases.length) {
      return _cases[index];
    }
    return null;
  }

  // Check if case is completed
  bool isCaseCompleted(String caseId) {
    return _selectedOptions.containsKey(caseId);
  }

  // Get total score from all completed cases
  int getTotalScore(String locale) {
    int total = 0;
    for (final entry in _selectedOptions.entries) {
      final score = getScoreForCase(entry.key, locale);
      if (score != null) {
        total += score['total'] ?? 0;
      }
    }
    return total;
  }

  // Get number of completed cases
  int get completedCasesCount => _selectedOptions.length;
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/case_scenario_model.dart';
import 'result_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final CaseScenario caseScenario;

  const CaseDetailScreen({super.key, required this.caseScenario});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  String? _selectedOptionId;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    // Check if already answered
    final simulationProvider = context.read<SimulationProvider>();
    _selectedOptionId = simulationProvider.getSelectedOption(
      widget.caseScenario.id,
    );
    if (_selectedOptionId != null) {
      _showExplanation = true;
    }
  }

  void _submitJudgment() async {
    if (_selectedOptionId == null) return;

    final simulationProvider = Provider.of<SimulationProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final locale = localeProvider.locale.languageCode;
    final isHindi = locale == 'hi';

    // Save selection
    simulationProvider.selectOption(_selectedOptionId!);

    // Calculate score
    final score = simulationProvider.getScoreForCase(
      widget.caseScenario.id,
      locale,
    );

    debugPrint('Score for ${widget.caseScenario.id}: $score');

    if (score != null) {
      await userProvider.updateScore(score['total'] ?? 0);
    }

    setState(() {
      _showExplanation = true;
    });

    // Show reflection dialog after explanation
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _showReflectionDialog(isHindi, score);
  }

  void _showReflectionDialog(bool isHindi, Map<String, int>? score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isHindi ? '📝 चिंतन' : '📝 Reflection',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi
                    ? 'इस मामले से आपने क्या सीखा?'
                    : 'What did you learn from this case?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              if (score != null) ...[
                _buildScoreRow(
                  isHindi ? 'निष्पक्षता' : 'Fairness',
                  score['fairness'] ?? 0,
                  5,
                ),
                _buildScoreRow(
                  isHindi ? 'साक्ष्य विश्लेषण' : 'Evidence Analysis',
                  score['evidence'] ?? 0,
                  5,
                ),
                _buildScoreRow(
                  isHindi ? 'पक्षपात से बचाव' : 'Bias Avoidance',
                  score['bias'] ?? 0,
                  5,
                ),
                const Divider(),
                _buildScoreRow(
                  isHindi ? 'कुल स्कोर' : 'Total Score',
                  score['total'] ?? 0,
                  15,
                  isBold: true,
                ),
              ] else ...[
                Text(
                  isHindi ? 'स्कोर गणना में त्रुटि' : 'Error calculating score',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                isHindi
                    ? '💡 याद रखें: एक अच्छा न्यायाधीश साक्ष्य, कानून और निष्पक्षता को संतुलित करता है।'
                    : '💡 Remember: A good judge balances evidence, law, and fairness.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
            },
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog first
              if (mounted) {
                Navigator.of(context).pop(); // Then go back to case list
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              isHindi ? 'अगला मामला' : 'Next Case',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    String label,
    int score,
    int max, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$score/$max',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: score >= max * 0.6 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final locale = localeProvider.locale.languageCode;
    final isHindi = locale == 'hi';

    final caseScenario = widget.caseScenario;
    final options = caseScenario.getOptions(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(caseScenario.getTitle(locale)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    caseScenario.categoryIcon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caseScenario.getTitle(locale),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          caseScenario.difficultyLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Facts Section
            Text(
              isHindi ? 'तथ्य' : 'Facts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                caseScenario.getFacts(locale),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 20),

            // Evidence Section
            Text(
              isHindi ? 'साक्ष्य' : 'Evidence',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 12),

            ...caseScenario.getEvidence(locale).asMap().entries.map((entry) {
              return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.accentColor.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('📎', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(
                    delay: Duration(milliseconds: 250 + (entry.key * 50)),
                  )
                  .fadeIn()
                  .slideX(begin: 0.1, end: 0);
            }),

            const SizedBox(height: 24),

            // Judgment Section
            Text(
              l10n.makeJudgment,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 12),

            ...options.asMap().entries.map((entry) {
              final option = entry.value;
              final isSelected = _selectedOptionId == option.id;
              final isDisabled =
                  _showExplanation && _selectedOptionId != option.id;

              return GestureDetector(
                    onTap: _showExplanation
                        ? null
                        : () {
                            setState(() {
                              _selectedOptionId = option.id;
                            });
                          },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (_showExplanation
                                  ? (option.id == caseScenario.bestOptionId
                                        ? AppTheme.successColor.withAlpha(30)
                                        : AppTheme.errorColor.withAlpha(30))
                                  : AppTheme.primaryColor.withAlpha(30))
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (_showExplanation
                                    ? (option.id == caseScenario.bestOptionId
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor)
                                    : AppTheme.primaryColor)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? (_showExplanation
                                        ? (option.id ==
                                                  caseScenario.bestOptionId
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor)
                                        : AppTheme.primaryColor)
                                  : Colors.grey.shade200,
                            ),
                            child: Center(
                              child: isSelected && _showExplanation
                                  ? Icon(
                                      option.id == caseScenario.bestOptionId
                                          ? Icons.check
                                          : Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : Text(
                                      String.fromCharCode(
                                        65 + entry.key,
                                      ), // A, B, C
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.text,
                              style: TextStyle(
                                color: isDisabled
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(
                    delay: Duration(milliseconds: 450 + (entry.key * 50)),
                  )
                  .fadeIn();
            }),

            const SizedBox(height: 20),

            // Submit Button or Explanation
            if (!_showExplanation)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedOptionId != null ? _submitJudgment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isHindi ? 'फैसला सुनाएं' : 'Submit Judgment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn()
            else ...[
              // Explanation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(
                          isHindi ? 'व्याख्या' : 'Explanation',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      caseScenario.getExplanation(locale),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // View Score Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ResultScreen(caseScenario: caseScenario),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isHindi ? 'स्कोर देखें' : 'View Score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

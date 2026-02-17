import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/case_scenario_model.dart';

class ResultScreen extends StatelessWidget {
  final CaseScenario caseScenario;

  const ResultScreen({super.key, required this.caseScenario});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final simulationProvider = context.watch<SimulationProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final locale = localeProvider.locale.languageCode;
    final isHindi = locale == 'hi';

    final score = simulationProvider.getScoreForCase(caseScenario.id, locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourScore),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(60),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    isHindi ? 'आपका फैसला' : 'Your Judgment',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${score?['total'] ?? 0}/15',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreMessage(score?['total'] ?? 0, isHindi),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Score Breakdown
            Text(
              isHindi ? 'स्कोर विवरण' : 'Score Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
),

            const SizedBox(height: 16),

            _ScoreCard(
              icon: '⚖️',
              title: l10n.fairness,
              score: score?['fairness'] ?? 0,
              maxScore: 5,
              color: AppTheme.primaryColor,
              description: isHindi
                  ? 'क्या आपने दोनों पक्षों पर विचार किया?'
                  : 'Did you consider both parties?',
),

            const SizedBox(height: 12),

            _ScoreCard(
              icon: '📋',
              title: l10n.evidenceBased,
              score: score?['evidence'] ?? 0,
              maxScore: 5,
              color: AppTheme.accentDark,
              description: isHindi
                  ? 'क्या आपने तथ्यों पर भरोसा किया?'
                  : 'Did you rely on facts?',
),

            const SizedBox(height: 12),

            _ScoreCard(
              icon: '🎯',
              title: l10n.biasAvoidance,
              score: score?['bias'] ?? 0,
              maxScore: 5,
              color: AppTheme.successColor,
              description: isHindi
                  ? 'क्या आपने पूर्वाग्रह से बचा?'
                  : 'Did you avoid bias?',
),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text(l10n.backToHome),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Go back to case list
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isHindi ? 'और केस' : 'More Cases'),
                  ),
                ),
              ],
),
          ],
        ),
      ),
    );
  }

  String _getScoreMessage(int score, bool isHindi) {
    if (score >= 13) {
      return isHindi
          ? 'उत्कृष्ट! आप में न्यायिक प्रतिभा है!'
          : 'Excellent! You have judicial talent!';
    } else if (score >= 9) {
      return isHindi
          ? 'बहुत अच्छा! आप सही रास्ते पर हैं!'
          : 'Very good! You\'re on the right track!';
    } else if (score >= 5) {
      return isHindi
          ? 'अच्छा प्रयास! अभ्यास जारी रखें!'
          : 'Good try! Keep practicing!';
    } else {
      return isHindi
          ? 'कोई बात नहीं! सीखते रहें!'
          : 'No worries! Keep learning!';
    }
  }
}

class _ScoreCard extends StatelessWidget {
  final String icon;
  final String title;
  final int score;
  final int maxScore;
  final Color color;
  final String description;

  const _ScoreCard({
    required this.icon,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$score/$maxScore',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

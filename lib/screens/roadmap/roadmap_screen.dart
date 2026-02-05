import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/roadmap_model.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    final roadmap = userProvider.getRoadmap();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourRoadmap),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: roadmap == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isHindi ? 'आपका लक्ष्य' : 'Your Goal',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    isHindi
                                        ? 'सिविल जज बनना'
                                        : 'Become a Civil Judge',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoChip(
                              icon: '📍',
                              label: userProvider.user?.state ?? '',
                            ),
                            const SizedBox(width: 12),
                            _InfoChip(icon: '⏱️', label: roadmap.totalDuration),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 24),

                  // Entrance Exams
                  Text(
                    isHindi ? 'प्रवेश परीक्षाएं' : 'Entrance Exams',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: roadmap.entranceExams.map((exam) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentColor.withAlpha(100),
                          ),
                        ),
                        child: Text(
                          exam,
                          style: TextStyle(
                            color: AppTheme.accentDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 28),

                  // Eligibility Criteria (Verifiable)
                  if (roadmap.eligibilityCriteria != null) ...[
                    Text(
                      isHindi
                          ? 'पात्रता मानदंड (सत्यापित)'
                          : 'Eligibility Criteria (Verified)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate(delay: 170.ms).fadeIn(),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EligibilityRow(
                            icon: '👤',
                            label: isHindi ? 'आयु सीमा' : 'Age Limit',
                            value:
                                '${roadmap.eligibilityCriteria!.minAge}-${roadmap.eligibilityCriteria!.maxAge} years',
                          ),
                          const SizedBox(height: 8),
                          _EligibilityRow(
                            icon: '🔄',
                            label: isHindi ? 'अधिकतम प्रयास' : 'Max Attempts',
                            value: roadmap.eligibilityCriteria!.maxAttempts == 0
                                ? (isHindi ? 'कोई सीमा नहीं' : 'No Limit')
                                : '${roadmap.eligibilityCriteria!.maxAttempts}',
                          ),
                          const SizedBox(height: 8),
                          _EligibilityRow(
                            icon: '🗣️',
                            label: isHindi
                                ? 'भाषा आवश्यकताएं'
                                : 'Language Requirements',
                            value: roadmap
                                .eligibilityCriteria!
                                .languageRequirements
                                .join(', '),
                            isMultiline: true,
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isHindi
                                      ? 'स्रोत: ${roadmap.eligibilityCriteria!.state} उच्च न्यायालय'
                                      : 'Source: ${roadmap.eligibilityCriteria!.state} High Court',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi
                                ? 'अंतिम सत्यापन: ${roadmap.eligibilityCriteria!.lastVerified}'
                                : 'Last Verified: ${roadmap.eligibilityCriteria!.lastVerified}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 180.ms).fadeIn().slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 28),
                  ],

                  // Timeline
                  Text(
                    isHindi ? 'आपका करियर पथ' : 'Your Career Path',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 16),

                  // Timeline Steps
                  ...roadmap.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == roadmap.steps.length - 1;

                    return _TimelineStep(
                          step: step,
                          isLast: isLast,
                          stepNumber: index + 1,
                          isHindi: isHindi,
                        )
                        .animate(
                          delay: Duration(milliseconds: 250 + (index * 100)),
                        )
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 24),

                  // Motivation Card
                  Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.successColor.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('💪', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isHindi ? 'याद रखें' : 'Remember',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isHindi
                                        ? 'हर साल हजारों छात्र न्यायाधीश बनते हैं। आप भी बन सकते हैं!'
                                        : 'Thousands of students become judges every year. You can too!',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(delay: 600.ms)
                      .fadeIn()
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      ),
                ],
              ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final RoadmapStep step;
  final bool isLast;
  final int stepNumber;
  final bool isHindi;

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.stepNumber,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: AppTheme.primaryColor.withAlpha(50),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          step.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (step.details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...step.details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '•',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                detail,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Eligibility Row Widget
class _EligibilityRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool isMultiline;

  const _EligibilityRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

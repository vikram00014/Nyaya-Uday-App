import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                            _InfoChip(icon: '📍', label: roadmap.state),
                            const SizedBox(width: 12),
                            _InfoChip(icon: '⏱️', label: roadmap.totalDuration),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // Progress Tracking Card
                  Builder(
                    builder: (context) {
                      final totalSteps = roadmap.steps.length;
                      final completedCount = roadmap.steps
                          .where(
                            (s) => userProvider.isStepCompleted(
                              roadmap.steps.indexOf(s) + 1,
                            ),
                          )
                          .length;
                      final progress = totalSteps > 0
                          ? completedCount / totalSteps
                          : 0.0;
                      final percent = (progress * 100).toInt();

                      String motivationText;
                      String motivationEmoji;
                      if (completedCount == 0) {
                        motivationEmoji = '🚀';
                        motivationText = isHindi
                            ? 'अपनी यात्रा शुरू करें! पहला कदम पूरा करें।'
                            : 'Start your journey! Complete your first step.';
                      } else if (completedCount < totalSteps ~/ 2) {
                        motivationEmoji = '💪';
                        motivationText = isHindi
                            ? 'बढ़िया शुरुआत! आप सही रास्ते पर हैं।'
                            : 'Great start! You are on the right track.';
                      } else if (completedCount < totalSteps) {
                        motivationEmoji = '🔥';
                        motivationText = isHindi
                            ? 'शानदार प्रगति! आप लक्ष्य के करीब हैं!'
                            : 'Amazing progress! You are close to the goal!';
                      } else {
                        motivationEmoji = '🏆';
                        motivationText = isHindi
                            ? 'बधाई! आपने सभी चरण पूरे कर लिए हैं!'
                            : 'Congratulations! You have completed all steps!';
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isHindi ? 'आपकी प्रगति' : 'Your Progress',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$completedCount / $totalSteps',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  completedCount == totalSteps
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$percent%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  motivationEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    motivationText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate(delay: 50.ms).fadeIn(),

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
                    Builder(
                      builder: (context) {
                        final criteria = roadmap.eligibilityCriteria!;
                        final isVerified =
                            criteria.verificationLevel ==
                            VerificationLevel.verified;
                        final statusColor = isVerified
                            ? Colors.green
                            : Colors.orange.shade800;
                        final cardColor = isVerified
                            ? Colors.blue.shade50
                            : Colors.orange.shade50;
                        final cardBorder = isVerified
                            ? Colors.blue.shade200
                            : Colors.orange.shade200;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi
                                  ? 'पात्रता स्नैपशॉट (नियम + अधिसूचना जांच)'
                                  : 'Eligibility Snapshot (Rules + Notification Check)',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ).animate(delay: 170.ms).fadeIn(),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _EligibilityRow(
                                    icon: 'A',
                                    label: isHindi ? 'आयु सीमा' : 'Age Limit',
                                    value: _formatAge(criteria, isHindi),
                                  ),
                                  const SizedBox(height: 8),
                                  _EligibilityRow(
                                    icon: 'T',
                                    label: isHindi
                                        ? 'अधिकतम प्रयास'
                                        : 'Max Attempts',
                                    value: _formatAttempts(criteria, isHindi),
                                  ),
                                  const SizedBox(height: 8),
                                  _EligibilityRow(
                                    icon: 'P',
                                    label: isHindi
                                        ? 'अभ्यास आवश्यकता'
                                        : 'Practice Requirement',
                                    value: criteria.practiceRequirement,
                                    isMultiline: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _EligibilityRow(
                                    icon: 'L',
                                    label: isHindi
                                        ? 'भाषा आवश्यकताएं'
                                        : 'Language Requirements',
                                    value: criteria.languageRequirements.join(
                                      ', ',
                                    ),
                                    isMultiline: true,
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      Icon(
                                        isVerified
                                            ? Icons.verified
                                            : Icons.warning_amber,
                                        size: 16,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${isHindi ? 'स्रोत' : 'Source'}: ${criteria.sourceLabel}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isHindi ? 'डेटा स्थिति' : 'Data Status'}: ${isVerified ? (isHindi ? 'सत्यापित' : 'Verified') : (isHindi ? 'सलाहकार' : 'Advisory')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isHindi ? 'अंतिम सत्यापन' : 'Last Verified'}: ${criteria.lastVerified}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () async {
                                      final uri = Uri.parse(criteria.sourceUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          size: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            criteria.sourceUrl,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue.shade700,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    criteria.verificationNote,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(delay: 180.ms).fadeIn().slideX(begin: -0.1, end: 0),

                            const SizedBox(height: 28),
                          ],
                        );
                      },
                    ),
                  ],
                  if (roadmap.eligibilityNotes.trim().isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              roadmap.eligibilityNotes,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 190.ms).fadeIn(),
                    const SizedBox(height: 24),
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
                    final stepNum = index + 1;
                    final completed = userProvider.isStepCompleted(stepNum);

                    return _TimelineStep(
                          step: step,
                          isLast: isLast,
                          stepNumber: stepNum,
                          isHindi: isHindi,
                          isCompleted: completed,
                          onToggleComplete: () {
                            userProvider.toggleStepCompletion(stepNum);
                          },
                        )
                        .animate(
                          delay: Duration(milliseconds: 250 + (index * 100)),
                        )
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 24),

                  // Motivation Card
                  Builder(
                        builder: (context) {
                          final totalSteps = roadmap.steps.length;
                          final completedCount = roadmap.steps
                              .where(
                                (s) => userProvider.isStepCompleted(
                                  roadmap.steps.indexOf(s) + 1,
                                ),
                              )
                              .length;
                          final remaining = totalSteps - completedCount;

                          return Container(
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
                                Text(
                                  completedCount == totalSteps ? '🏆' : '💪',
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        completedCount == 0
                                            ? (isHindi
                                                  ? 'हर साल हजारों छात्र न्यायाधीश बनते हैं। आप भी बन सकते हैं!'
                                                  : 'Thousands of students become judges every year. You can too!')
                                            : completedCount == totalSteps
                                            ? (isHindi
                                                  ? '🎉 आपने सभी चरण पूरे कर लिए हैं! अब अपने सपने को साकार करें!'
                                                  : '🎉 You completed all steps! Now make your dream a reality!')
                                            : (isHindi
                                                  ? 'आपने $completedCount चरण पूरे किए! बस $remaining और बाकी हैं। जारी रखें!'
                                                  : 'You completed $completedCount steps! Just $remaining more to go. Keep going!'),
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  String _formatAge(StateEligibilityCriteria criteria, bool isHindi) {
    if (criteria.minAge != null && criteria.maxAge != null) {
      return isHindi
          ? '${criteria.minAge}-${criteria.maxAge} वर्ष'
          : '${criteria.minAge}-${criteria.maxAge} years';
    }
    if (criteria.maxAge != null) {
      return isHindi
          ? '${criteria.maxAge} वर्ष तक'
          : 'Up to ${criteria.maxAge} years';
    }
    return isHindi
        ? 'नवीनतम आधिकारिक अधिसूचना देखें'
        : 'Check latest official notification';
  }

  String _formatAttempts(StateEligibilityCriteria criteria, bool isHindi) {
    if (criteria.maxAttempts == null) {
      return isHindi
          ? 'नवीनतम आधिकारिक अधिसूचना देखें'
          : 'Check latest official notification';
    }
    if (criteria.maxAttempts == 0) {
      return isHindi ? 'कोई स्पष्ट सीमा नहीं' : 'No explicit limit';
    }
    return '${criteria.maxAttempts}';
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
  final bool isCompleted;
  final VoidCallback onToggleComplete;

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.stepNumber,
    required this.isHindi,
    required this.isCompleted,
    required this.onToggleComplete,
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
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.successColor.withAlpha(80),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
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
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: isCompleted
                        ? AppTheme.successColor.withAlpha(120)
                        : AppTheme.primaryColor.withAlpha(50),
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
                color: isCompleted
                    ? AppTheme.successColor.withAlpha(15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.successColor.withAlpha(60)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          step.getTitle(isHindi ? 'hi' : 'en'),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
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
                    step.getDescription(isHindi ? 'hi' : 'en'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (step.details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...step
                        .getLocalizedDetails(isHindi ? 'hi' : 'en')
                        .map(
                          (detail) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '•',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildClickableText(
                                    detail,
                                    Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                          height: 1.4,
                                        ) ??
                                        const TextStyle(
                                          color: AppTheme.textSecondary,
                                          height: 1.4,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  const SizedBox(height: 10),
                  // Mark complete / undo button
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successColor.withAlpha(25)
                            : AppTheme.primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.replay_rounded
                                : Icons.check_circle_outline,
                            size: 16,
                            color: isCompleted
                                ? AppTheme.successColor
                                : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted
                                ? (isHindi ? 'पूर्ववत करें' : 'Undo')
                                : (isHindi ? 'पूरा हुआ ✓' : 'Mark Complete ✓'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Detects URLs in [text] and renders them as tappable blue links.
  Widget _buildClickableText(String text, TextStyle style) {
    final urlRegex = RegExp(
      r'(https?://[^\s,)]+|www\.[^\s,)]+|[a-zA-Z0-9-]+\.[a-z]{2,}(?:/[^\s,)]*)?)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }
      final urlText = match.group(0)!;
      final fullUrl = urlText.startsWith('http') ? urlText : 'https://$urlText';
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(fullUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              urlText,
              style: style.copyWith(
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return RichText(text: TextSpan(children: spans));
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

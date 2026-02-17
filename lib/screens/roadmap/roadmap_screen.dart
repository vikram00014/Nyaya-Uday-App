import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/llb_pathway_provider.dart';
import '../../models/roadmap_model.dart';
import '../../widgets/external_link_text.dart';

/// Optimized Roadmap Screen with production-grade performance.
/// 
/// Optimizations applied:
/// - CustomScrollView with Slivers instead of ListView(children: [])
/// - SliverList.builder for timeline steps
/// - RepaintBoundary for heavy sections
/// - PageStorageKey for scroll preservation
/// - Separated widgets to minimize rebuilds
/// - No heavy animations during scroll
/// - Const constructors where possible
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourRoadmap),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const _RoadmapBody(),
    );
  }
}

class _RoadmapBody extends StatelessWidget {
  const _RoadmapBody();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final roadmap = userProvider.getRoadmap();

    if (roadmap == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isHindi =
        context.watch<LocaleProvider>().locale.languageCode == 'hi';

    return CustomScrollView(
      key: const PageStorageKey<String>('roadmap_scroll'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: RepaintBoundary(
              child: _HeaderCard(roadmap: roadmap, isHindi: isHindi),
            ),
          ),
        ),

        // LLB Pathway Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: RepaintBoundary(
              child: _LlbPathwayCard(isHindi: isHindi),
            ),
          ),
        ),

        // Progress Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: RepaintBoundary(
              child: _ProgressCard(roadmap: roadmap, isHindi: isHindi),
            ),
          ),
        ),

        // Entrance Exams
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              isHindi ? 'प्रवेश परीक्षाएं' : 'Entrance Exams',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ExamChips(exams: roadmap.entranceExams),
          ),
        ),

        // Eligibility Criteria
        if (roadmap.eligibilityCriteria != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: RepaintBoundary(
                child: _EligibilitySection(
                  criteria: roadmap.eligibilityCriteria!,
                  isHindi: isHindi,
                ),
              ),
            ),
          ),

        // Eligibility Notes
        if (roadmap.eligibilityNotes.trim().isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _EligibilityNotes(notes: roadmap.eligibilityNotes),
            ),
          ),

        // Timeline Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              isHindi ? 'आपका करियर पथ' : 'Your Career Path',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        // Timeline Steps - using SliverList.builder for performance
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: roadmap.steps.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: _TimelineStepItem(
                  step: roadmap.steps[index],
                  stepNumber: index + 1,
                  isLast: index == roadmap.steps.length - 1,
                  isHindi: isHindi,
                ),
              );
            },
          ),
        ),

        // Motivation Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: RepaintBoundary(
              child: _MotivationCard(roadmap: roadmap, isHindi: isHindi),
            ),
          ),
        ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final RoadmapModel roadmap;
  final bool isHindi;

  const _HeaderCard({required this.roadmap, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      isHindi ? 'सिविल जज बनना' : 'Become a Civil Judge',
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

class _ProgressCard extends StatelessWidget {
  final RoadmapModel roadmap;
  final bool isHindi;

  const _ProgressCard({required this.roadmap, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final totalSteps = roadmap.steps.length;
    final completedCount = roadmap.steps
        .where((s) => userProvider.isStepCompleted(roadmap.steps.indexOf(s) + 1))
        .length;
    final progress = totalSteps > 0 ? completedCount / totalSteps : 0.0;
    final percent = (progress * 100).toInt();

    final (motivationEmoji, motivationText) = _getMotivation(
      completedCount,
      totalSteps,
      isHindi,
    );

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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              Text(motivationEmoji, style: const TextStyle(fontSize: 18)),
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
  }

  (String, String) _getMotivation(int completed, int total, bool isHindi) {
    if (completed == 0) {
      return (
        '🚀',
        isHindi
            ? 'अपनी यात्रा शुरू करें! पहला कदम पूरा करें।'
            : 'Start your journey! Complete your first step.',
      );
    } else if (completed < total ~/ 2) {
      return (
        '💪',
        isHindi
            ? 'बढ़िया शुरुआत! आप सही रास्ते पर हैं।'
            : 'Great start! You are on the right track.',
      );
    } else if (completed < total) {
      return (
        '🔥',
        isHindi
            ? 'शानदार प्रगति! आप लक्ष्य के करीब हैं!'
            : 'Amazing progress! You are close to the goal!',
      );
    } else {
      return (
        '🏆',
        isHindi
            ? 'बधाई! आपने सभी चरण पूरे कर लिए हैं!'
            : 'Congratulations! You have completed all steps!',
      );
    }
  }
}

class _ExamChips extends StatelessWidget {
  final List<String> exams;

  const _ExamChips({required this.exams});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: exams.map((exam) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withAlpha(40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accentColor.withAlpha(100)),
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
    );
  }
}

class _EligibilitySection extends StatelessWidget {
  final StateEligibilityCriteria criteria;
  final bool isHindi;

  const _EligibilitySection({
    required this.criteria,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = criteria.verificationLevel == VerificationLevel.verified;
    final statusColor = isVerified ? Colors.green : Colors.orange.shade800;
    final cardColor = isVerified ? Colors.blue.shade50 : Colors.orange.shade50;
    final cardBorder = isVerified ? Colors.blue.shade200 : Colors.orange.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi
              ? 'पात्रता स्नैपशॉट (नियम + अधिसूचना जांच)'
              : 'Eligibility Snapshot (Rules + Notification Check)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
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
                value: _formatAge(),
              ),
              const SizedBox(height: 8),
              _EligibilityRow(
                icon: 'T',
                label: isHindi ? 'अधिकतम प्रयास' : 'Max Attempts',
                value: _formatAttempts(),
              ),
              const SizedBox(height: 8),
              _EligibilityRow(
                icon: 'P',
                label: isHindi ? 'अभ्यास आवश्यकता' : 'Practice Requirement',
                value: criteria.practiceRequirement,
                isMultiline: true,
              ),
              const SizedBox(height: 8),
              _EligibilityRow(
                icon: 'L',
                label: isHindi ? 'भाषा आवश्यकताएं' : 'Language Requirements',
                value: criteria.languageRequirements.join(', '),
                isMultiline: true,
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(
                    isVerified ? Icons.verified : Icons.warning_amber,
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
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                          decoration: TextDecoration.underline,
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
        ),
      ],
    );
  }

  String _formatAge() {
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

  String _formatAttempts() {
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
    // Parse value into structured points for better readability
    final formattedValue = _formatValue(value);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              ...formattedValue.map((line) => Padding(
                padding: EdgeInsets.only(
                  left: line.startsWith('•') ? 0 : 0,
                  bottom: 2,
                ),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: line.startsWith('•') ? FontWeight.w500 : FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Format value into bullet points for better readability
  List<String> _formatValue(String text) {
    // If already contains newlines, split by them
    if (text.contains('\n')) {
      return text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }
    
    // Split by common separators for practice requirements
    final parts = <String>[];
    
    // Split by periods followed by space and capital letter (sentences)
    final sentences = text.split(RegExp(r'\.\s+(?=[A-Z])'));
    
    for (int i = 0; i < sentences.length; i++) {
      var sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;
      
      // Add period back if it was removed (except for last)
      if (i < sentences.length - 1 && !sentence.endsWith('.')) {
        sentence = '$sentence.';
      } else if (!sentence.endsWith('.') && !sentence.endsWith(')')) {
        sentence = '$sentence.';
      }
      
      // Make it a bullet point if there are multiple sentences
      if (sentences.length > 1) {
        parts.add('• $sentence');
      } else {
        parts.add(sentence);
      }
    }
    
    return parts.isEmpty ? [text] : parts;
  }
}

class _EligibilityNotes extends StatelessWidget {
  final String notes;

  const _EligibilityNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(Icons.info_outline, size: 18, color: Colors.brown),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepItem extends StatelessWidget {
  final RoadmapStep step;
  final int stepNumber;
  final bool isLast;
  final bool isHindi;

  const _TimelineStepItem({
    required this.step,
    required this.stepNumber,
    required this.isLast,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isCompleted = userProvider.isStepCompleted(stepNumber);
    final isLocked = !isCompleted && !userProvider.canCompleteStep(stepNumber);
    final isCurrentStep = !isCompleted && userProvider.canCompleteStep(stepNumber);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              GestureDetector(
                onTap: () => _onToggle(context, isLocked, userProvider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor
                        : isLocked
                            ? Colors.grey.shade300
                            : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: isCurrentStep
                        ? Border.all(
                            color: AppTheme.accentColor,
                            width: 3,
                          )
                        : null,
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.successColor.withAlpha(80),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : isCurrentStep
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentColor.withAlpha(80),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : isLocked
                            ? const Icon(Icons.lock_outline,
                                color: Colors.white, size: 20)
                            : Text(
                                '$stepNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCompleted
                            ? [
                                AppTheme.successColor.withAlpha(180),
                                AppTheme.successColor.withAlpha(100),
                              ]
                            : [
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                      ),
                    ),
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
                    : isLocked
                        ? Colors.grey.shade50
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.successColor.withAlpha(60)
                      : isCurrentStep
                          ? AppTheme.accentColor.withAlpha(100)
                          : Colors.grey.shade200,
                  width: isCurrentStep ? 2 : 1,
                ),
              ),
              child: Opacity(
                opacity: isLocked ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isCurrentStep)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isHindi ? 'वर्तमान' : 'CURRENT',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  step.getTitle(isHindi ? 'hi' : 'en'),
                                  style:
                                      Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isLocked
                                                ? Colors.grey.shade600
                                                : null,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLocked
                                ? Colors.grey.shade200
                                : AppTheme.accentColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: isLocked
                                    ? Colors.grey.shade500
                                    : AppTheme.accentDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                step.duration,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLocked
                                      ? Colors.grey.shade500
                                      : AppTheme.accentDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ExternalLinkText(
                    text: step.getDescription(isHindi ? 'hi' : 'en'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ) ??
                        const TextStyle(),
                  ),
                  // Show details if available
                  if (step.getLocalizedDetails(isHindi ? 'hi' : 'en').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...step.getLocalizedDetails(isHindi ? 'hi' : 'en').map((detail) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                detail,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  height: 1.4,
                                  color: AppTheme.textSecondary,
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
          ),
        ],
      ),
    );
  }

  void _onToggle(
      BuildContext context, bool isLocked, UserProvider userProvider) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'पहले पिछले चरण पूरे करें!'
                : 'Complete previous steps first!',
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    userProvider.toggleStepCompletion(stepNumber);
  }
}

class _MotivationCard extends StatelessWidget {
  final RoadmapModel roadmap;
  final bool isHindi;

  const _MotivationCard({required this.roadmap, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final totalSteps = roadmap.steps.length;
    final completedCount = roadmap.steps
        .where((s) => userProvider.isStepCompleted(roadmap.steps.indexOf(s) + 1))
        .length;
    final remaining = totalSteps - completedCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withAlpha(50)),
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
                  _getMessage(completedCount, totalSteps, remaining),
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMessage(int completed, int total, int remaining) {
    if (completed == 0) {
      return isHindi
          ? 'हर साल हजारों छात्र न्यायाधीश बनते हैं। आप भी बन सकते हैं!'
          : 'Thousands of students become judges every year. You can too!';
    } else if (completed == total) {
      return isHindi
          ? '🎉 आपने सभी चरण पूरे कर लिए हैं! अब अपने सपने को साकार करें!'
          : '🎉 You completed all steps! Now make your dream a reality!';
    } else {
      return isHindi
          ? 'आपने $completed चरण पूरे किए! बस $remaining और बाकी हैं। जारी रखें!'
          : 'You completed $completed steps! Just $remaining more to go. Keep going!';
    }
  }
}

// ── LLB Pathway Card ────────────────────────────────────────
class _LlbPathwayCard extends StatelessWidget {
  final bool isHindi;

  const _LlbPathwayCard({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final pathwayProvider = context.watch<LlbPathwayProvider>();

    if (!pathwayProvider.hasSelectedPathway) {
      return const SizedBox.shrink();
    }

    final pathway = pathwayProvider.selectedPathway!;
    final is5Year = pathway == LlbPathway.fiveYear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: is5Year
              ? [Colors.blue.shade50, Colors.indigo.shade50]
              : [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: is5Year
              ? Colors.blue.shade200
              : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: is5Year
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pathway.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isHindi ? 'आपका LLB पाठ्यक्रम' : 'Your LLB Pathway',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: is5Year
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pathway.badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHindi
                          ? pathway.displayNameHindi
                          : pathway.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: is5Year
                            ? Colors.blue.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pathway steps
          _PathwayStepRow(
            icon: is5Year ? '📚' : '🎓',
            step: '1',
            title: is5Year
                ? (isHindi ? 'कक्षा 12 पास करें' : 'Complete Class 12')
                : (isHindi ? 'ग्रेजुएशन पूरी करें' : 'Complete Graduation'),
            color: is5Year ? Colors.blue : Colors.green,
          ),
          _PathwayStepRow(
            icon: '📝',
            step: '2',
            title: is5Year
                ? (isHindi ? 'CLAT / AILET दें' : 'Appear for CLAT / AILET')
                : (isHindi ? 'Law Entrance दें' : 'Appear for Law Entrance'),
            color: is5Year ? Colors.blue : Colors.green,
          ),
          _PathwayStepRow(
            icon: '⚖️',
            step: '3',
            title: is5Year
                ? (isHindi ? '5-वर्षीय LLB करें' : 'Pursue 5-Year LLB')
                : (isHindi ? '3-वर्षीय LLB करें' : 'Pursue 3-Year LLB'),
            color: is5Year ? Colors.blue : Colors.green,
          ),
          _PathwayStepRow(
            icon: '👨‍⚖️',
            step: '4',
            title: isHindi
                ? 'Judicial Service परीक्षा दें'
                : 'Appear for Judicial Exam',
            color: is5Year ? Colors.blue : Colors.green,
            isLast: true,
          ),
          const SizedBox(height: 12),
          // Eligibility info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: is5Year
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHindi
                        ? pathway.eligibilityHindi
                        : pathway.eligibility,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathwayStepRow extends StatelessWidget {
  final String icon;
  final String step;
  final String title;
  final Color color;
  final bool isLast;

  const _PathwayStepRow({
    required this.icon,
    required this.step,
    required this.title,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  step,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: color.withAlpha(100),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

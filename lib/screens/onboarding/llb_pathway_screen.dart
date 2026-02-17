import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/llb_pathway_provider.dart';
import '../../providers/locale_provider.dart';
import 'state_selection_screen.dart';

/// Screen for selecting LLB pathway during onboarding
class LlbPathwayScreen extends StatefulWidget {
  const LlbPathwayScreen({super.key});

  @override
  State<LlbPathwayScreen> createState() => _LlbPathwayScreenState();
}

class _LlbPathwayScreenState extends State<LlbPathwayScreen> {
  LlbPathway? _selectedPathway;

  void _onPathwaySelected(LlbPathway pathway) {
    setState(() {
      _selectedPathway = pathway;
    });
  }

  Future<void> _continue() async {
    if (_selectedPathway == null) return;

    final pathwayProvider = context.read<LlbPathwayProvider>();
    await pathwayProvider.setPathway(_selectedPathway!);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StateSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Toggle
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LanguageButton(
                          label: 'EN',
                          isSelected:
                              localeProvider.locale.languageCode == 'en',
                          onTap: () =>
                              localeProvider.setLocale(const Locale('en')),
                        ),
                        _LanguageButton(
                          label: 'हि',
                          isSelected:
                              localeProvider.locale.languageCode == 'hi',
                          onTap: () =>
                              localeProvider.setLocale(const Locale('hi')),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // Title
                Text(
                  isHindi ? 'LLB पाठ्यक्रम चुनें' : 'Choose Your LLB Pathway',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  isHindi
                      ? 'आप कौन सा LLB कोर्स करना चाहते हैं?'
                      : 'Which LLB course do you want to pursue?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 32),

                // Pathway Options
                _PathwayCard(
                  pathway: LlbPathway.fiveYear,
                  isSelected: _selectedPathway == LlbPathway.fiveYear,
                  isHindi: isHindi,
                  onTap: () => _onPathwaySelected(LlbPathway.fiveYear),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                _PathwayCard(
                  pathway: LlbPathway.threeYear,
                  isSelected: _selectedPathway == LlbPathway.threeYear,
                  isHindi: isHindi,
                  onTap: () => _onPathwaySelected(LlbPathway.threeYear),
                ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isHindi
                              ? 'आप बाद में प्रोफ़ाइल सेटिंग्स से इसे बदल सकते हैं'
                              : 'You can change this later from profile settings',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),

                const Spacer(),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedPathway != null ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isHindi ? 'आगे बढ़ें' : 'Continue',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying a pathway option
class _PathwayCard extends StatelessWidget {
  final LlbPathway pathway;
  final bool isSelected;
  final bool isHindi;
  final VoidCallback onTap;

  const _PathwayCard({
    required this.pathway,
    required this.isSelected,
    required this.isHindi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(25)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  pathway.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isHindi
                              ? pathway.displayNameHindi
                              : pathway.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHindi ? pathway.descriptionHindi : pathway.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Duration badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isHindi
                              ? pathway.durationToJudgeHindi
                              : pathway.durationToJudge,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Language toggle button
class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

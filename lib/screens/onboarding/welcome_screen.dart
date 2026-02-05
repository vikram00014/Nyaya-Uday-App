import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';
import 'state_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

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
                          isSelected: localeProvider.locale.languageCode == 'en',
                          onTap: () => localeProvider.setLocale(const Locale('en')),
                        ),
                        _LanguageButton(
                          label: 'हि',
                          isSelected: localeProvider.locale.languageCode == 'hi',
                          onTap: () => localeProvider.setLocale(const Locale('hi')),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const Spacer(flex: 1),

                // Illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '⚖️',
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                const SizedBox(height: 40),

                // Welcome Title
                Text(
                  l10n.welcomeTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  l10n.welcomeSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: 24),

                // Features List
                _FeatureItem(
                  icon: '🗺️',
                  text: localeProvider.locale.languageCode == 'hi'
                      ? 'अपने राज्य के लिए करियर रोडमैप'
                      : 'Career roadmap for your state',
                ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.2, end: 0),

                const SizedBox(height: 12),

                _FeatureItem(
                  icon: '⚖️',
                  text: localeProvider.locale.languageCode == 'hi'
                      ? 'न्यायाधीश बनने का अनुभव करें'
                      : 'Experience thinking like a judge',
                ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.2, end: 0),

                const SizedBox(height: 12),

                _FeatureItem(
                  icon: '🏆',
                  text: localeProvider.locale.languageCode == 'hi'
                      ? 'बैज और रैंक अर्जित करें'
                      : 'Earn badges and ranks',
                ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.2, end: 0),

                const Spacer(flex: 2),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StateSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.getStarted,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

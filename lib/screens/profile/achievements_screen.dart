import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const List<String> _badgeOrder = [
    'first_case',
    'quick_learner',
    'five_cases',
    'dedicated',
    'expert',
    'rising_star',
    'centurion',
    'judicial_master',
    'fair_judge',
    'perfect_judgment',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    final earnedBadges = userProvider.user?.badges ?? [];
    final badgeInfo = userProvider.badgeInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'बैज संग्रह' : 'Badge Collection',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${earnedBadges.length}/${_badgeOrder.length} ${isHindi ? 'अर्जित' : 'earned'}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textPrimary.withAlpha(180),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _badgeOrder.length,
              itemBuilder: (context, index) {
                final badgeId = _badgeOrder[index];
                final badge = badgeInfo[badgeId];
                if (badge == null) {
                  return const SizedBox.shrink();
                }

                final isEarned = earnedBadges.contains(badgeId);

                return _BadgeCard(
                      icon: badge['icon'] ?? '🏅',
                      title: isHindi
                          ? (badge['titleHi'] ?? badge['title'] ?? '')
                          : (badge['title'] ?? ''),
                      description: isHindi
                          ? (badge['descriptionHi'] ?? badge['description'] ?? '')
                          : (badge['description'] ?? ''),
                      isEarned: isEarned,
                    )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn()
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isEarned;

  const _BadgeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? AppTheme.accentColor.withAlpha(30)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? AppTheme.accentColor : Colors.grey.shade300,
          width: isEarned ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEarned ? AppTheme.accentColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isEarned ? icon : '🔒',
                style: TextStyle(fontSize: isEarned ? 30 : 24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isEarned ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

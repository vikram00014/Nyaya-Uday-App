import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    final user = userProvider.user;
    final earnedBadges = user?.badges ?? [];

    final allBadges = [
      {
        'id': 'first_case',
        'icon': '⚖️',
        'title': 'First Case',
        'titleHi': 'पहला केस',
        'description': 'Complete your first case',
        'descriptionHi': 'अपना पहला केस पूरा करें',
      },
      {
        'id': 'five_cases',
        'icon': '🏆',
        'title': 'Case Expert',
        'titleHi': 'केस विशेषज्ञ',
        'description': 'Complete 5 cases',
        'descriptionHi': '5 केस पूरे करें',
      },
      {
        'id': 'rising_star',
        'icon': '⭐',
        'title': 'Rising Star',
        'titleHi': 'उभरता सितारा',
        'description': 'Score 50+ points',
        'descriptionHi': '50+ अंक प्राप्त करें',
      },
      {
        'id': 'perfect_judgment',
        'icon': '💯',
        'title': 'Perfect Judgment',
        'titleHi': 'सटीक निर्णय',
        'description': 'Get max score in a case',
        'descriptionHi': 'एक केस में अधिकतम अंक प्राप्त करें',
      },
      {
        'id': 'ten_cases',
        'icon': '🎯',
        'title': 'Case Master',
        'titleHi': 'केस मास्टर',
        'description': 'Complete 10 cases',
        'descriptionHi': '10 केस पूरे करें',
      },
      {
        'id': 'century',
        'icon': '💎',
        'title': 'Century',
        'titleHi': 'शतक',
        'description': 'Score 100+ points',
        'descriptionHi': '100+ अंक प्राप्त करें',
      },
    ];

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
            // Progress Header
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${earnedBadges.length}/${allBadges.length} ${isHindi ? 'अर्जित' : 'earned'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

            // Badges Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isEarned = earnedBadges.contains(badge['id']);

                return _BadgeCard(
                  icon: badge['icon']!,
                  title: isHindi ? badge['titleHi']! : badge['title']!,
                  description: isHindi ? badge['descriptionHi']! : badge['description']!,
                  isEarned: isEarned,
                ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().scale(
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
        color: isEarned ? AppTheme.accentColor.withAlpha(30) : Colors.grey.shade100,
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
                style: TextStyle(
                  fontSize: isEarned ? 30 : 24,
                ),
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

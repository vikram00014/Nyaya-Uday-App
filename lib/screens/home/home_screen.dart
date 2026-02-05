import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../roadmap/roadmap_screen.dart';
import '../simulation/case_list_screen.dart';
import '../learn/legal_modules_screen.dart';
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../assistant/faq_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeContent(userProvider: userProvider, isHindi: isHindi),
          const RoadmapScreen(),
          const CaseListScreen(),
          const LegalModulesScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaqAssistantScreen()),
          );
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: Text(
          isHindi ? 'सहायक' : 'Ask',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: isHindi ? 'रोडमैप' : 'Roadmap',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.gavel_outlined),
              activeIcon: const Icon(Icons.gavel),
              label: isHindi ? 'सिमुलेशन' : 'Simulate',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school_outlined),
              activeIcon: const Icon(Icons.school),
              label: l10n.learn,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final UserProvider userProvider;
  final bool isHindi;

  const _HomeContent({
    required this.userProvider,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final user = userProvider.user;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'नमस्ते! 🙏' : 'Namaste! 🙏',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    Text(
                      isHindi ? 'आपकी न्यायिक यात्रा जारी है' : 'Your judicial journey continues',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
                // Language Toggle
                IconButton(
                  onPressed: () {
                    context.read<LocaleProvider>().toggleLocale();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isHindi ? 'EN' : 'हि',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ScoreItem(
                        icon: '⚖️',
                        value: '${user?.totalScore ?? 0}',
                        label: l10n.totalScore,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withAlpha(50),
                      ),
                      _ScoreItem(
                        icon: '📋',
                        value: '${user?.casesCompleted ?? 0}',
                        label: l10n.casesCompleted,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withAlpha(50),
                      ),
                      _ScoreItem(
                        icon: '🏆',
                        value: user?.rank ?? 'Trainee',
                        label: l10n.rank,
                        isSmallValue: true,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              isHindi ? 'तेज़ कार्रवाई' : 'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: '🗺️',
                    title: isHindi ? 'मेरा रोडमैप' : 'My Roadmap',
                    subtitle: isHindi ? 'करियर पथ देखें' : 'View career path',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: '⚖️',
                    title: l10n.juniorJudge,
                    subtitle: l10n.trySimulation,
                    color: AppTheme.accentDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CaseListScreen()),
                      );
                    },
                  ),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: '📚',
                    title: l10n.legalLiteracy,
                    subtitle: l10n.shortModules,
                    color: AppTheme.successColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LegalModulesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: '🏅',
                    title: l10n.leaderboard,
                    subtitle: isHindi ? 'अपनी रैंक देखें' : 'See your rank',
                    color: AppTheme.warningColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                  ),
                ),
              ],
            ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // What is a Judge?
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('👨‍⚖️', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.whatIsJudge,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.judgeRole,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool isSmallValue;

  const _ScoreItem({
    required this.icon,
    required this.value,
    required this.label,
    this.isSmallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallValue ? 14 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(180),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

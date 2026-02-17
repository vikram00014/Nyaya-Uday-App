import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/llb_pathway_provider.dart';
import '../roadmap/roadmap_screen.dart';
import '../simulation/case_list_screen.dart';
import '../learn/legal_modules_screen.dart';
import '../learn/legal_glossary_screen.dart';
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../assistant/faq_assistant_screen.dart';
import '../notes/notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lazy-loaded tab cache: only build tabs when first visited
  final Map<int, Widget> _tabCache = {};

  Widget _buildTab(int index, bool isHindi) {
    if (_tabCache.containsKey(index)) return _tabCache[index]!;

    final userProvider = context.read<UserProvider>();
    late Widget tab;
    switch (index) {
      case 0:
        tab = _HomeContent(userProvider: userProvider, isHindi: isHindi);
        break;
      case 1:
        tab = const RoadmapScreen();
        break;
      case 2:
        tab = const CaseListScreen();
        break;
      case 3:
        tab = const LegalModulesScreen();
        break;
      case 4:
        tab = const ProfileScreen();
        break;
      default:
        tab = const SizedBox.shrink();
    }
    _tabCache[index] = tab;
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    // Always keep home tab updated since it reads provider
    if (_currentIndex == 0) {
      _tabCache[0] = _HomeContent(
        userProvider: context.watch<UserProvider>(),
        isHindi: isHindi,
      );
    }

    return Scaffold(
      body: RepaintBoundary(
        child: _buildTab(_currentIndex, isHindi),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaqAssistantScreen()),
          );
        },
        backgroundColor: AppTheme.accentColor,
        elevation: 6,
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: Text(
          isHindi ? 'सहायक' : 'Ask',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: _currentIndex,
        isHindi: isHindi,
        l10n: l10n,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ── Modern Bottom Navigation Bar ────────────────────────────
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isHindi;
  final AppLocalizations l10n;
  final ValueChanged<int> onTap;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.isHindi,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, l10n.home),
      _NavItem(Icons.map_outlined, Icons.map_rounded,
          isHindi ? 'रोडमैप' : 'Roadmap'),
      _NavItem(Icons.gavel_outlined, Icons.gavel_rounded,
          isHindi ? 'सिमुलेशन' : 'Simulate'),
      _NavItem(Icons.school_outlined, Icons.school_rounded, l10n.learn),
      _NavItem(Icons.person_outline_rounded, Icons.person_rounded, l10n.profile),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: AppTheme.primaryColor.withAlpha(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor.withAlpha(15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            key: ValueKey(selected),
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                            size: selected ? 26 : 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: selected ? 20 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ── Home Content ────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final UserProvider userProvider;
  final bool isHindi;

  const _HomeContent({required this.userProvider, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final user = userProvider.user;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi
                            ? 'नमस्ते${userProvider.displayName != null ? ', ${userProvider.displayName}' : ''}! 🙏'
                            : 'Namaste${userProvider.displayName != null ? ', ${userProvider.displayName}' : ''}! 🙏',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHindi
                            ? 'आपकी न्यायिक यात्रा जारी है'
                            : 'Your judicial journey continues',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      // LLB Pathway Badge
                      _PathwayBadge(isHindi: isHindi),
                    ],
                  ),
                ),
                // Language Toggle
                GestureDetector(
                  onTap: () {
                    context.read<LocaleProvider>().toggleLocale();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withAlpha(20),
                          AppTheme.primaryColor.withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryColor.withAlpha(30),
                      ),
                    ),
                    child: Text(
                      isHindi ? 'EN' : 'हि',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
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
                    color: Colors.white.withAlpha(40),
                  ),
                  _ScoreItem(
                    icon: '📋',
                    value: '${user?.casesCompleted ?? 0}',
                    label: l10n.casesCompleted,
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white.withAlpha(40),
                  ),
                  _ScoreItem(
                    icon: '🏆',
                    value: user?.rank ?? 'Trainee',
                    label: l10n.rank,
                    isSmallValue: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Study Streak + Daily Tip
            _StudyStreakCard(
              streakDays: userProvider.streakDays,
              isHindi: isHindi,
            ),

            const SizedBox(height: 12),

            _DailyTipCard(isHindi: isHindi),

            const SizedBox(height: 22),

            // Quick Actions
            Text(
              isHindi ? 'तेज़ कार्रवाई' : 'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // Quick action grid — 2 columns
            _buildQuickActionRow(context, [
              _QuickActionData(
                icon: '🗺️',
                title: isHindi ? 'मेरा रोडमैप' : 'My Roadmap',
                subtitle: isHindi ? 'करियर पथ देखें' : 'View career path',
                color: AppTheme.primaryColor,
                screen: const RoadmapScreen(),
              ),
              _QuickActionData(
                icon: '⚖️',
                title: l10n.juniorJudge,
                subtitle: l10n.trySimulation,
                color: AppTheme.accentDark,
                screen: const CaseListScreen(),
              ),
            ]),
            const SizedBox(height: 12),
            _buildQuickActionRow(context, [
              _QuickActionData(
                icon: '📚',
                title: l10n.legalLiteracy,
                subtitle: l10n.shortModules,
                color: AppTheme.successColor,
                screen: const LegalModulesScreen(),
              ),
              _QuickActionData(
                icon: '🏅',
                title: l10n.leaderboard,
                subtitle: isHindi ? 'अपनी रैंक देखें' : 'See your rank',
                color: AppTheme.warningColor,
                screen: const LeaderboardScreen(),
              ),
            ]),
            const SizedBox(height: 12),
            _buildQuickActionRow(context, [
              _QuickActionData(
                icon: '📝',
                title: isHindi ? 'मेरे नोट्स' : 'My Notes',
                subtitle: isHindi ? 'नोट्स लिखें' : 'Write notes',
                color: Colors.indigo,
                screen: const NotesScreen(),
              ),
              _QuickActionData(
                icon: '📖',
                title: isHindi ? 'कानूनी शब्दकोश' : 'Glossary',
                subtitle: isHindi ? 'शब्द खोजें' : 'Legal terms',
                color: Colors.brown,
                screen: const LegalGlossaryScreen(),
              ),
            ]),
            const SizedBox(height: 12),
            _buildQuickActionRow(context, [
              _QuickActionData(
                icon: '🤖',
                title: isHindi ? 'AI सहायक' : 'AI Assistant',
                subtitle: isHindi ? 'प्रश्न पूछें' : 'Ask questions',
                color: Colors.deepPurple,
                screen: const FaqAssistantScreen(),
              ),
            ]),

            const SizedBox(height: 22),

            // What is a Judge?
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(25)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('👨‍⚖️',
                              style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.whatIsJudge,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.judgeRole,
                    style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(
      BuildContext context, List<_QuickActionData> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: items[i].icon,
              title: items[i].title,
              subtitle: items[i].subtitle,
              color: items[i].color,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => items[i].screen),
                );
              },
            ),
          ),
        ],
        // If only one item, add a spacer
        if (items.length == 1) ...[
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()),
        ],
      ],
    );
  }
}

class _QuickActionData {
  final String icon, title, subtitle;
  final Color color;
  final Widget screen;
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}

// ── Study Streak Card ───────────────────────────────────────
class _StudyStreakCard extends StatelessWidget {
  final int streakDays;
  final bool isHindi;

  const _StudyStreakCard({required this.streakDays, required this.isHindi});

  String get _streakEmoji {
    if (streakDays >= 30) return '🏆';
    if (streakDays >= 14) return '🔥';
    if (streakDays >= 7) return '⭐';
    if (streakDays >= 3) return '🌟';
    return '✨';
  }

  String _motivationalText() {
    if (isHindi) {
      if (streakDays >= 30) {
        return 'अद्भुत! एक महीने से ज़्यादा! जज बनने का सपना पूरा होगा!';
      }
      if (streakDays >= 14) {
        return 'शानदार! दो सप्ताह की लगन! आप सही राह पर हैं!';
      }
      if (streakDays >= 7) return 'बहुत अच्छा! एक हफ्ते की स्ट्रीक! जारी रखें!';
      if (streakDays >= 3) return 'अच्छी शुरुआत! हर दिन मायने रखता है!';
      return 'आज की शुरुआत बढ़िया है! कल भी आएं!';
    }
    if (streakDays >= 30) {
      return 'Amazing! 30+ days! Your dedication will pay off!';
    }
    if (streakDays >= 14) {
      return 'Brilliant! 2 weeks strong! You\'re on the right path!';
    }
    if (streakDays >= 7) return 'Great! 1 week streak! Keep going!';
    if (streakDays >= 3) return 'Good start! Every day counts!';
    return 'Today is a great start! Come back tomorrow!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(_streakEmoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi
                      ? '$streakDays दिन की स्ट्रीक!'
                      : '$streakDays Day Streak!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _motivationalText(),
                  style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              (streakDays).clamp(0, 5),
              (i) => Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text('🔥', style: const TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Tip Card ──────────────────────────────────────────
class _DailyTipCard extends StatelessWidget {
  final bool isHindi;

  const _DailyTipCard({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final tips = _getDailyTips();
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    final tip = tips[dayOfYear % tips.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'आज का कानूनी ज्ञान' : 'Legal Tip of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.accentDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi ? tip['hi']! : tip['en']!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getDailyTips() {
    return [
      {
        'en':
            'Article 21 of the Constitution guarantees the Right to Life and Personal Liberty — the most expansive fundamental right.',
        'hi':
            'संविधान का अनुच्छेद 21 जीवन और व्यक्तिगत स्वतंत्रता का अधिकार सुनिश्चित करता है — सबसे व्यापक मौलिक अधिकार।',
      },
      {
        'en':
            'The Supreme Court of India was established on 26 January 1950. It replaced the Federal Court of India and the Privy Council.',
        'hi':
            'भारत का सर्वोच्च न्यायालय 26 जनवरी 1950 को स्थापित हुआ। इसने फेडरल कोर्ट और प्रिवी काउंसिल का स्थान लिया।',
      },
      {
        'en':
            'A Civil Judge (Junior Division) is the entry-level judicial post. The exam is conducted by the respective State High Court.',
        'hi':
            'सिविल जज (कनिष्ठ खंड) प्रवेश स्तर का न्यायिक पद है। परीक्षा संबंधित राज्य उच्च न्यायालय द्वारा आयोजित होती है।',
      },
      {
        'en':
            'FIR (First Information Report) can be filed by any person. Police must register it for cognizable offences — refusal is an offence.',
        'hi':
            'FIR कोई भी व्यक्ति दर्ज करा सकता है। संज्ञेय अपराधों के लिए पुलिस को इसे दर्ज करना अनिवार्य है — मना करना अपराध है।',
      },
      {
        'en':
            'The Kesavananda Bharati case (1973) established the Basic Structure Doctrine — Parliament cannot alter the basic structure of the Constitution.',
        'hi':
            'केशवानंद भारती केस (1973) ने मूल संरचना सिद्धांत स्थापित किया — संसद संविधान की मूल संरचना नहीं बदल सकती।',
      },
      {
        'en':
            'India has 25 High Courts. The oldest is the Calcutta High Court, established in 1862.',
        'hi':
            'भारत में 25 उच्च न्यायालय हैं। सबसे पुराना कलकत्ता उच्च न्यायालय है, जो 1862 में स्थापित हुआ।',
      },
      {
        'en':
            'Lok Adalat decisions are final and binding. No appeal lies against them. There is no court fee in Lok Adalat.',
        'hi':
            'लोक अदालत के निर्णय अंतिम और बाध्यकारी होते हैं। कोई अपील नहीं। कोई कोर्ट फीस भी नहीं लगती।',
      },
      {
        'en':
            'BNS (Bharatiya Nyaya Sanhita) replaced the 164-year-old IPC on 1 July 2024 with 358 modern sections.',
        'hi':
            'भारतीय न्याय संहिता (BNS) ने 1 जुलाई 2024 को 164 साल पुरानी IPC को 358 आधुनिक धाराओं से बदल दिया।',
      },
      {
        'en':
            'Free legal aid is a fundamental right under Article 39A. SC/ST, women, children, and disabled persons are eligible regardless of income.',
        'hi':
            'मुफ्त कानूनी सहायता अनुच्छेद 39A के तहत मौलिक अधिकार है। SC/ST, महिला, बच्चे और दिव्यांग बिना आय सीमा के पात्र हैं।',
      },
      {
        'en':
            'The Vishaka Guidelines (1997) were India\'s first rules against sexual harassment at the workplace, later codified as the POSH Act 2013.',
        'hi':
            'विशाखा दिशानिर्देश (1997) कार्यस्थल पर यौन उत्पीड़न के विरुद्ध भारत के पहले नियम थे, बाद में POSH अधिनियम 2013 बना।',
      },
      {
        'en':
            'CLAT (Common Law Admission Test) is the gateway to 22 National Law Universities. Graduates can take the CLAT-PG for LLM admission.',
        'hi':
            'CLAT 22 राष्ट्रीय विधि विश्वविद्यालयों का प्रवेश द्वार है। स्नातक CLAT-PG से LLM में प्रवेश ले सकते हैं।',
      },
      {
        'en':
            'A PIL (Public Interest Litigation) can be filed by any citizen to protect public interest — no personal stake is required.',
        'hi':
            'PIL (जनहित याचिका) कोई भी नागरिक जनहित में दायर कर सकता है — व्यक्तिगत हित की ज़रूरत नहीं।',
      },
      {
        'en':
            'The Preamble declares India a "Sovereign, Socialist, Secular, Democratic Republic." "Socialist" and "Secular" were added by the 42nd Amendment (1976).',
        'hi':
            'प्रस्तावना भारत को "संप्रभु, समाजवादी, धर्मनिरपेक्ष, लोकतांत्रिक गणराज्य" घोषित करती है। 42वें संशोधन (1976) से ये शब्द जोड़े गए।',
      },
      {
        'en':
            'Habeas Corpus ("produce the body") is the most powerful writ — it protects personal liberty against illegal detention.',
        'hi':
            'हैबियस कॉर्पस ("शरीर प्रस्तुत करो") सबसे शक्तिशाली रिट है — यह गैरकानूनी हिरासत से व्यक्तिगत स्वतंत्रता की रक्षा करती है।',
      },
      {
        'en':
            'The Right to Privacy was declared a fundamental right under Article 21 by the Supreme Court in the Puttaswamy case (2017).',
        'hi':
            'सर्वोच्च न्यायालय ने पुट्टस्वामी केस (2017) में निजता के अधिकार को अनुच्छेद 21 के तहत मौलिक अधिकार घोषित किया।',
      },
      {
        'en':
            'DK Basu Guidelines (1997) mandate every arrested person be informed of grounds of arrest and access to a lawyer — enforced as law.',
        'hi':
            'DK बसु दिशानिर्देश (1997) — हर गिरफ्तार व्यक्ति को गिरफ्तारी का कारण बताना और वकील तक पहुंच देना अनिवार्य।',
      },
      {
        'en':
            'NALSA helps over 1 crore people annually through legal aid. Helpline: 15100. Email: nalsa-dla@nic.in.',
        'hi':
            'NALSA सालाना 1 करोड़+ लोगों की कानूनी सहायता करता है। हेल्पलाइन: 15100। ईमेल: nalsa-dla@nic.in।',
      },
      {
        'en':
            'The Right to Education Act 2009 (Article 21A) guarantees free and compulsory education for children aged 6-14 years.',
        'hi':
            'शिक्षा का अधिकार अधिनियम 2009 (अनुच्छेद 21A) 6-14 वर्ष के बच्चों को मुफ्त और अनिवार्य शिक्षा की गारंटी देता है।',
      },
      {
        'en':
            'The Mediation Act 2023 provides a legal framework for mediation in India — promoting out-of-court dispute resolution.',
        'hi':
            'मध्यस्थता अधिनियम 2023 भारत में मध्यस्थता का कानूनी ढांचा प्रदान करता है — अदालत से बाहर विवाद समाधान को बढ़ावा।',
      },
      {
        'en':
            'The Right to Information Act 2005 empowers citizens to access information from public authorities within 30 days.',
        'hi':
            'सूचना का अधिकार अधिनियम 2005 नागरिकों को 30 दिनों में सरकारी प्राधिकरणों से सूचना प्राप्त करने का अधिकार देता है।',
      },
      {
        'en':
            'SC/ST/OBC candidates get 5 years age relaxation in most judicial service exams. PwD candidates get up to 10 years.',
        'hi':
            'SC/ST/OBC उम्मीदवारों को अधिकांश न्यायिक सेवा परीक्षाओं में 5 वर्ष की आयु छूट मिलती है। PwD को 10 वर्ष तक।',
      },
      {
        'en':
            'A High Court judge\'s starting salary is ₹2,50,000/month. Supreme Court judges start at ₹2,80,000/month.',
        'hi':
            'उच्च न्यायालय के न्यायाधीश का प्रारंभिक वेतन ₹2,50,000/माह है। सर्वोच्च न्यायालय के न्यायाधीश ₹2,80,000/माह से शुरू करते हैं।',
      },
      {
        'en':
            'Article 39A mandates "equal justice and free legal aid" — the state must ensure the legal system promotes justice on the basis of equal opportunity.',
        'hi':
            'अनुच्छेद 39A "समान न्याय और मुफ्त कानूनी सहायता" का आदेश देता है — राज्य को समान अवसर पर न्याय सुनिश्चित करना चाहिए।',
      },
      {
        'en':
            'The Triple Talaq (instant oral divorce) was declared unconstitutional by the Supreme Court in Shayara Bano v. Union of India (2017).',
        'hi':
            'तीन तलाक को सर्वोच्च न्यायालय ने शायरा बानो बनाम भारत संघ (2017) में असंवैधानिक घोषित किया।',
      },
      {
        'en':
            'The Olga Tellis case (1985) extended Article 21 to include the Right to Livelihood — pavement dwellers cannot be evicted without due process.',
        'hi':
            'ओल्गा टेलिस केस (1985) ने अनुच्छेद 21 में आजीविका का अधिकार शामिल किया — फुटपाथ निवासियों को बिना उचित प्रक्रिया के नहीं हटाया जा सकता।',
      },
      {
        'en':
            'India follows a three-tier court system: Supreme Court → High Courts → Subordinate Courts (District & lower courts).',
        'hi':
            'भारत में तीन-स्तरीय न्यायालय प्रणाली है: सर्वोच्च न्यायालय → उच्च न्यायालय → अधीनस्थ न्यायालय (जिला और निचली अदालतें)।',
      },
      {
        'en':
            'The Maneka Gandhi case (1978) expanded Article 21 — any law depriving life/liberty must be "just, fair, and reasonable."',
        'hi':
            'मेनका गांधी केस (1978) ने अनुच्छेद 21 का विस्तार किया — जीवन/स्वतंत्रता से वंचित करने वाला कानून "न्यायसंगत, उचित और तर्कसंगत" होना चाहिए।',
      },
      {
        'en':
            'The Nirbhaya case (2012) led to the Criminal Law Amendment Act 2013, which introduced stricter punishments for sexual offences.',
        'hi':
            'निर्भया केस (2012) से आपराधिक कानून (संशोधन) अधिनियम 2013 आया, जिसने यौन अपराधों के लिए कठोर दंड लागू किए।',
      },
      {
        'en':
            'Every District has a District Legal Services Authority (DLSA) that provides free legal aid, legal literacy, and Lok Adalat services.',
        'hi':
            'हर जिले में जिला विधिक सेवा प्राधिकरण (DLSA) है जो मुफ्त कानूनी सहायता, कानूनी साक्षरता और लोक अदालत सेवाएं प्रदान करता है।',
      },
      {
        'en':
            'The Constitution originally had 395 Articles and 8 Schedules. Today it has 470+ Articles and 12 Schedules after 100+ amendments.',
        'hi':
            'संविधान में मूलतः 395 अनुच्छेद और 8 अनुसूचियां थीं। आज 100+ संशोधनों के बाद 470+ अनुच्छेद और 12 अनुसूचियां हैं।',
      },
    ];
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
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallValue ? 14 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(170)),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withAlpha(30),
        highlightColor: color.withAlpha(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withAlpha(35), color.withAlpha(15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── LLB Pathway Badge ────────────────────────────────────────
class _PathwayBadge extends StatelessWidget {
  final bool isHindi;

  const _PathwayBadge({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final pathwayProvider = context.watch<LlbPathwayProvider>();
    
    if (!pathwayProvider.hasSelectedPathway) {
      return const SizedBox.shrink();
    }
    
    final pathway = pathwayProvider.selectedPathway!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha(25),
            AppTheme.accentColor.withAlpha(15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pathway.icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            pathway.badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

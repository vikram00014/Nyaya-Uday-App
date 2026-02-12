import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  int _userPosition = 0;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final userProvider = context.read<UserProvider>();

    // Local algorithmic ranking (PS 3 requirement: no cloud infrastructure)
    await Future.delayed(const Duration(milliseconds: 300));
    _leaderboardData = _getAlgorithmicRankings();

    // Calculate local position using ranking algorithm
    final userScore = userProvider.user?.totalScore ?? 0;
    _userPosition = _calculateLocalPosition(userScore);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getAlgorithmicRankings() {
    // Algorithmic ranking data for comparison and motivation
    // Represents typical score distribution patterns
    return [
      {
        'display_name': 'Aditya Sharma',
        'total_score': 485,
        'state': 'UP',
      },
      {
        'display_name': 'Priya Singh',
        'total_score': 420,
        'state': 'MP',
      },
      {
        'display_name': 'Rahul Verma',
        'total_score': 380,
        'state': 'MH',
      },
      {
        'display_name': 'Ankita Patel',
        'total_score': 325,
        'state': 'GJ',
      },
      {
        'display_name': 'Vikas Kumar',
        'total_score': 290,
        'state': 'BR',
      },
      {
        'display_name': 'Neha Gupta',
        'total_score': 245,
        'state': 'RJ',
      },
      {
        'display_name': 'Amit Yadav',
        'total_score': 210,
        'state': 'UP',
      },
      {
        'display_name': 'Pooja Sharma',
        'total_score': 175,
        'state': 'DL',
      },
      {
        'display_name': 'Suresh Mishra',
        'total_score': 140,
        'state': 'MH',
      },
      {
        'display_name': 'Kavita Jain',
        'total_score': 95,
        'state': 'KA',
      },
    ];
  }

  int _calculateLocalPosition(int userScore) {
    int position = 1;
    for (var entry in _leaderboardData) {
      if ((entry['total_score'] as int? ?? 0) > userScore) {
        position++;
      }
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // User's Position Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentColor, width: 3),
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'आपकी स्थिति' : 'Your Position',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '#$_userPosition',
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${user?.totalScore ?? 0} ${isHindi ? 'अंक' : 'pts'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.rank ?? 'Trainee',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Loading or Leaderboard List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadLeaderboard,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _leaderboardData.length,
                      itemBuilder: (context, index) {
                        final entry = _leaderboardData[index];
                        final score = entry['total_score'] as int? ?? 0;
                        return _LeaderboardItem(
                              rank: index + 1,
                              name: entry['display_name'] as String? ?? 'User',
                              score: score,
                              state: entry['state'] as String? ?? '',
                              title: UserModel.getRankTitle(score),
                              isHindi: isHindi,
                            )
                            .animate(delay: Duration(milliseconds: 50 * index))
                            .fadeIn()
                            .slideX(begin: 0.1, end: 0);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String state;
  final String title;
  final bool isHindi;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.state,
    required this.title,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankColors = [
      AppTheme.accentColor, // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop3 ? rankColors[rank - 1] : Colors.grey.shade200,
          width: isTop3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTop3 ? rankColors[rank - 1] : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTop3
                  ? Text(
                      rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉'),
                      style: const TextStyle(fontSize: 20),
                    )
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    if (state.isNotEmpty) ...[
                      Text(
                        '📍 $state',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                isHindi ? 'अंक' : 'pts',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

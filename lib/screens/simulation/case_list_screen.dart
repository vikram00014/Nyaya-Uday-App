import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/case_scenario_model.dart';
import 'case_detail_screen.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationProvider>().loadCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final simulationProvider = context.watch<SimulationProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.juniorJudge),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: simulationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '⚖️',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.trySimulation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? 'असली मामलों को पढ़ें और अपना फैसला दें'
                            : 'Read real-like cases and give your judgment',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                // Cases List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: simulationProvider.cases.length,
                    itemBuilder: (context, index) {
                      final caseItem = simulationProvider.cases[index];
                      final isCompleted = simulationProvider.isCaseCompleted(caseItem.id);
                      final locale = localeProvider.locale.languageCode;

                      return _CaseCard(
                        caseItem: caseItem,
                        isCompleted: isCompleted,
                        locale: locale,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CaseDetailScreen(
                                caseScenario: caseItem,
                              ),
                            ),
                          );
                        },
                      ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final CaseScenario caseItem;
  final bool isCompleted;
  final String locale;
  final VoidCallback onTap;

  const _CaseCard({
    required this.caseItem,
    required this.isCompleted,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? AppTheme.successColor.withAlpha(100)
              : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successColor.withAlpha(30)
                      : AppTheme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    isCompleted ? '✅' : caseItem.categoryIcon,
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
                            caseItem.getTitle(locale),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              locale == 'hi' ? 'पूर्ण' : 'Done',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caseItem.difficultyLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseItem.getFacts(locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

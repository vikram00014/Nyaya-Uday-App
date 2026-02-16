import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/state_catalog.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/groq_service.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasApiKey = false;
  String _maskedKey = '';

  @override
  void initState() {
    super.initState();
    _loadApiKeyStatus();
  }

  Future<void> _loadApiKeyStatus() async {
    final key = await GroqService.getApiKey();
    if (mounted) {
      setState(() {
        _hasApiKey = key != null;
        if (key != null && key.length > 8) {
          _maskedKey =
              '${key.substring(0, 4)}${'•' * (key.length - 8)}${key.substring(key.length - 4)}';
        } else {
          _maskedKey = '';
        }
      });
    }
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
        title: Text(l10n.profile),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isHindi ? 'EN' : 'हि',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            onPressed: () {
              localeProvider.toggleLocale();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // User Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentColor, width: 3),
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.rank ?? 'Trainee',
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userProvider.displayName ??
                            (isHindi
                                ? 'न्यायिक उम्मीदवार'
                                : 'Judicial Aspirant'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () =>
                            _showEditNameDialog(context, userProvider, isHindi),
                        tooltip: isHindi ? 'नाम संपादित करें' : 'Edit Name',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${user?.state != null && user!.state.isNotEmpty ? StateCatalog.displayName(user.state) : 'India'}',
                    style: TextStyle(color: Colors.white.withAlpha(200)),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: '⚖️',
                    value: '${user?.totalScore ?? 0}',
                    label: l10n.totalScore,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: '📋',
                    value: '${user?.casesCompleted ?? 0}',
                    label: l10n.casesCompleted,
                  ),
                ),
              ],
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: '🏅',
                    value: '${user?.badges.length ?? 0}',
                    label: l10n.badges,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: '🎓',
                    value: _getEducationLabel(
                      user?.educationLevel ?? '',
                      isHindi,
                    ),
                    label: isHindi ? 'शिक्षा' : 'Education',
                    isSmallValue: true,
                  ),
                ),
              ],
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 24),

            // Achievements Section
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.achievements,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isHindi
                                ? '${user?.badges.length ?? 0} बैज अर्जित'
                                : '${user?.badges.length ?? 0} badges earned',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 24),

            // Quick Badges Preview
            if ((user?.badges.length ?? 0) > 0) ...[
              Text(
                isHindi ? 'हाल के बैज' : 'Recent Badges',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ).animate(delay: 250.ms).fadeIn(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: (user?.badges ?? []).take(4).map((badgeId) {
                  final badge = userProvider.badgeInfo[badgeId];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentColor.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          badge?['icon'] ?? '🏅',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHindi
                              ? (badge?['titleHi'] ?? badge?['title'] ?? '')
                              : (badge?['title'] ?? ''),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ).animate(delay: 300.ms).fadeIn(),
            ],

            const SizedBox(height: 24),

            // ── Settings Section ────────────────────────────
            _buildSettingsSection(context, isHindi),
          ],
        ),
      ),
    );
  }

  // ── Settings Section UI ───────────────────────────────────
  Widget _buildSettingsSection(BuildContext context, bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? '⚙️ सेटिंग्स' : '⚙️ Settings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate(delay: 350.ms).fadeIn(),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // ── API Key Tile ───────────────────────────────
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hasApiKey
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _hasApiKey ? Icons.vpn_key : Icons.key_off,
                    color: _hasApiKey
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                title: Text(
                  isHindi ? 'Groq API Key' : 'Groq API Key',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _hasApiKey
                      ? _maskedKey
                      : (isHindi
                            ? 'AI चैटबॉट के लिए key सेट करें'
                            : 'Set key to enable AI chatbot'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _hasApiKey
                        ? AppTheme.textSecondary
                        : Colors.orange.shade700,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasApiKey)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        tooltip: isHindi ? 'Key हटाएं' : 'Remove Key',
                        onPressed: () => _confirmRemoveKey(context, isHindi),
                      ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                onTap: () => _showApiKeyDialog(context, isHindi),
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              // Status indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hasApiKey ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _hasApiKey
                            ? (isHindi
                                  ? 'AI मोड सक्रिय — इंटरनेट होने पर AI जवाब देगा'
                                  : 'AI mode active — will use AI when online')
                            : (isHindi
                                  ? 'ऑफ़लाइन मोड — सिर्फ़ नियम-आधारित उत्तर'
                                  : 'Offline mode — rule-based answers only'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              // Info tile
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'Groq का free tier API key groq.com से बनाएं। '
                                  'Limit खत्म होने पर नई key यहां बदल सकते हैं — '
                                  'app दोबारा build करने की ज़रूरत नहीं।'
                            : 'Get a free Groq API key from groq.com. '
                                  'When the free tier limit runs out, just swap '
                                  'the key here — no need to rebuild the app.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  void _showApiKeyDialog(BuildContext context, bool isHindi) async {
    final existingKey = await GroqService.getApiKey();
    final keyController = TextEditingController(text: existingKey ?? '');
    bool obscure = true;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            _hasApiKey
                ? (isHindi ? 'API Key बदलें' : 'Change API Key')
                : (isHindi ? 'API Key जोड़ें' : 'Add API Key'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi
                    ? 'groq.com से free Groq API key पेस्ट करें:'
                    : 'Paste your free Groq API key from groq.com:',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keyController,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'gsk_...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
                autofocus: true,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                isHindi
                    ? 'Key सिर्फ आपके फ़ोन में सेव होगी, कहीं भेजी नहीं जाएगी।'
                    : 'Key is stored locally on your device only.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(ctx);
                  await GroqService.saveApiKey(key);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  _loadApiKeyStatus();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi ? '✅ API Key सेव हो गई!' : '✅ API Key saved!',
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save, size: 18),
              label: Text(
                isHindi ? 'सहेजें' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveKey(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHindi ? 'Key हटाएं?' : 'Remove Key?'),
        content: Text(
          isHindi
              ? 'API key हटाने पर AI चैटबॉट बंद हो जाएगा और सिर्फ़ ऑफ़लाइन मोड काम करेगा।'
              : 'Removing the API key will disable AI chatbot. Only offline rule-based mode will work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              await GroqService.removeApiKey();
              if (ctx.mounted) Navigator.of(ctx).pop();
              _loadApiKeyStatus();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi ? '🗑️ API Key हटा दी गई' : '🗑️ API Key removed',
                  ),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text(
              isHindi ? 'हां, हटाएं' : 'Yes, Remove',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getEducationLabel(String code, bool isHindi) {
    switch (code) {
      case 'class_10':
        return isHindi ? '10वीं' : '10th';
      case 'class_12':
        return isHindi ? '12वीं' : '12th';
      case 'graduate':
        return isHindi ? 'स्नातक' : 'Graduate';
      default:
        return code;
    }
  }

  void _showEditNameDialog(
    BuildContext context,
    UserProvider userProvider,
    bool isHindi,
  ) {
    final nameController = TextEditingController(
      text: userProvider.displayName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHindi ? 'नाम संपादित करें' : 'Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: isHindi ? 'अपना नाम दर्ज करें' : 'Enter your name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                userProvider.updateDisplayName(nameController.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              isHindi ? 'सहेजें' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool isSmallValue;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.isSmallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallValue ? 16 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../home/home_screen.dart';

class EducationLevelScreen extends StatefulWidget {
  final String selectedState;

  const EducationLevelScreen({super.key, required this.selectedState});

  @override
  State<EducationLevelScreen> createState() => _EducationLevelScreenState();
}

class _EducationLevelScreenState extends State<EducationLevelScreen> {
  String? _selectedLevel;
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedGender;
  bool _hasDisability = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  final List<Map<String, dynamic>> _educationLevels = [
    {
      'code': 'class_10',
      'icon': '🎒',
      'description': 'Currently in or completed Class 10',
      'descriptionHi': 'वर्तमान में कक्षा 10 में या पूर्ण',
      'duration': '9-10 years to become a judge',
      'durationHi': 'न्यायाधीश बनने में 9-10 वर्ष',
    },
    {
      'code': 'class_12',
      'icon': '📚',
      'description': 'Currently in or completed Class 12',
      'descriptionHi': 'वर्तमान में कक्षा 12 में या पूर्ण',
      'duration': '7-8 years to become a judge',
      'durationHi': 'न्यायाधीश बनने में 7-8 वर्ष',
    },
    {
      'code': 'graduate',
      'icon': '🎓',
      'description': 'Completed graduation in any field',
      'descriptionHi': 'किसी भी क्षेत्र में स्नातक पूर्ण',
      'duration': '4-5 years to become a judge',
      'durationHi': 'न्यायाधीश बनने में 4-5 वर्ष',
    },
  ];

  Future<void> _completeOnboarding() async {
    if (_selectedLevel == null) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final localeProvider = context.read<LocaleProvider>();

    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await userProvider.updateDisplayName(name);
    }

    await userProvider.saveUser(
      state: widget.selectedState,
      educationLevel: _selectedLevel!,
      preferredLanguage: localeProvider.locale.languageCode,
      age: int.tryParse(_ageController.text),
      category: _selectedCategory,
      gender: _selectedGender,
      annualIncome: double.tryParse(_incomeController.text),
      hasDisability: _hasDisability ? true : null,
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                l10n.selectEducation,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),

              const SizedBox(height: 8),

              Text(
                isHindi
                    ? 'यह आपके व्यक्तिगत रोडमैप को अनुकूलित करने में मदद करेगा'
                    : 'This will help customize your personalized roadmap',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 24),

              // ── Name Input ─────────────────────────
              Text(
                isHindi ? 'आपका नाम' : 'Your Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: isHindi
                        ? 'अपना नाम दर्ज करें'
                        : 'Enter your name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Education Level Options
              ...List.generate(_educationLevels.length, (index) {
                final level = _educationLevels[index];
                final isSelected = _selectedLevel == level['code'];

                return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLevel = level['code'];
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withAlpha(25)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withAlpha(
                                        30,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
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
                                    level['icon'],
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level['code'] == 'class_10'
                                          ? l10n.class10
                                          : level['code'] == 'class_12'
                                          ? l10n.class12
                                          : l10n.graduate,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isHindi
                                          ? level['descriptionHi']
                                          : level['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withAlpha(
                                          50,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isHindi
                                            ? level['durationHi']
                                            : level['duration'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.accentDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Check Icon
                              if (isSelected)
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0);
              }),

              const SizedBox(height: 16),

              // ── Age Input ─────────────────────────
              Text(
                isHindi ? 'आपकी आयु (वैकल्पिक)' : 'Your Age (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: isHindi ? 'उदा. 18' : 'e.g. 18',
                    prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Category Selection ─────────────────
              Text(
                isHindi ? 'श्रेणी (वैकल्पिक)' : 'Category (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: ['General', 'SC', 'ST', 'OBC', 'EWS'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 13)),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor.withAlpha(30),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ── Gender Selection ────────────────────
              Text(
                isHindi ? 'लिंग (वैकल्पिक)' : 'Gender (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                    [
                      {
                        'code': 'Male',
                        'label': isHindi ? 'पुरुष' : 'Male',
                        'icon': '👨',
                      },
                      {
                        'code': 'Female',
                        'label': isHindi ? 'महिला' : 'Female',
                        'icon': '👩',
                      },
                      {
                        'code': 'Other',
                        'label': isHindi ? 'अन्य' : 'Other',
                        'icon': '🧑',
                      },
                    ].map((g) {
                      final isSelected = _selectedGender == g['code'];
                      return ChoiceChip(
                        avatar: Text(
                          g['icon']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        label: Text(
                          g['label']!,
                          style: const TextStyle(fontSize: 13),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryColor.withAlpha(30),
                        onSelected: (selected) {
                          setState(() {
                            _selectedGender = selected ? g['code'] : null;
                          });
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),

              // ── Annual Income ────────────────────
              Text(
                isHindi
                    ? 'वार्षिक आय - लाख में (वैकल्पिक)'
                    : 'Annual Income in Lakhs (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isHindi
                    ? '💡 यह मुफ्त कानूनी सहायता पात्रता जांचने के लिए है'
                    : '💡 This helps check free legal aid eligibility',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: isHindi ? 'उदा. 2.5' : 'e.g. 2.5',
                    prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                    suffixText: isHindi ? 'लाख/वर्ष' : 'Lakh/yr',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Disability Status ────────────────────
              Row(
                children: [
                  Checkbox(
                    value: _hasDisability,
                    onChanged: (val) =>
                        setState(() => _hasDisability = val ?? false),
                    activeColor: AppTheme.primaryColor,
                  ),
                  Expanded(
                    child: Text(
                      isHindi
                          ? 'दिव्यांगजन (PwD) श्रेणी'
                          : 'Person with Disability (PwD)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Complete Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null && !_isLoading
                      ? _completeOnboarding
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isHindi ? 'रोडमैप देखें' : 'View My Roadmap',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

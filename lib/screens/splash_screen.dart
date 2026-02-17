import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/llb_pathway_provider.dart';
import 'onboarding/llb_pathway_screen.dart';
import 'home/home_screen.dart';

/// Splash background color — matches native launch_background.xml
const _splashBg = Color(0xFFF5F7FA);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _ringScale;
  late final Animation<double> _iconFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _shimmerProgress;

  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();

    // Single controller drives all animations via Intervals — no jank
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Ring expands 0–40%
    _ringScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Icon fades in 10–35%
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.35, curve: Curves.easeOut),
      ),
    );

    // Title slides up 20–50%
    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
      ),
    );

    // Tagline + pill fade in 35–60%
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.60, curve: Curves.easeOut),
      ),
    );

    // Shimmer loops from 50–100% of the controller
    _shimmerProgress = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 1.0, curve: Curves.linear),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      precacheImage(const AssetImage('assets/images/app_icon.png'), context);
    }
  }

  Future<void> _initializeApp() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      final pathwayProvider =
          Provider.of<LlbPathwayProvider>(context, listen: false);

      await Future.wait([
        userProvider.initialize(),
        localeProvider.initialize(),
        pathwayProvider.initialize(),
        // Minimum splash display — enough for animations to complete
        Future.delayed(const Duration(milliseconds: 2200)),
      ]);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              userProvider.isOnboarded
                  ? const HomeScreen()
                  : const LlbPathwayScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LlbPathwayScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _splashBg,
              Color(0xFFE8EDF5),
              Color(0xFFF0F3F9),
              Color(0xFFE8EDF5),
              _splashBg,
            ],
            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated rings + icon
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring 3
                          _buildRing(
                            size: 200 * _ringScale.value,
                            color: AppTheme.primaryColor.withAlpha(25),
                            strokeWidth: 1.5,
                          ),
                          // Outer ring 2
                          _buildRing(
                            size: 170 * _ringScale.value,
                            color: AppTheme.primaryLight.withAlpha(40),
                            strokeWidth: 1.5,
                          ),
                          // Inner ring
                          _buildRing(
                            size: 145 * _ringScale.value,
                            color: AppTheme.accentColor.withAlpha(50),
                            strokeWidth: 2,
                          ),
                          // Icon glow
                          Opacity(
                            opacity: _iconFade.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryLight.withAlpha(30),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // App icon
                          Opacity(
                            opacity: _iconFade.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withAlpha(25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Hindi title
                    Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _iconFade.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.accentDark,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            '\u0928\u094D\u092F\u093E\u092F-\u0909\u0926\u092F',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // English subtitle
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        'NYAYA-UDAY',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryColor.withAlpha(140),
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.w300,
                                ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tagline pill
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.accentColor.withAlpha(100),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          color: AppTheme.accentColor.withAlpha(15),
                        ),
                        child: const Text(
                          '\u2696\uFE0F  Your Path to the Bench',
                          style: TextStyle(
                            color: AppTheme.accentDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Shimmer loading bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 3,
                          child: Stack(
                            children: [
                              Container(
                                color: AppTheme.primaryColor.withAlpha(20),
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.35,
                                alignment: Alignment(
                                  _shimmerProgress.value,
                                  0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppTheme.accentColor.withAlpha(180),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Version
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        'v3.1.0',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withAlpha(100),
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRing({
    required double size,
    required Color color,
    required double strokeWidth,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: strokeWidth),
      ),
    );
  }
}

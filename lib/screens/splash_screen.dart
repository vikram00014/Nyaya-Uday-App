import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/locale_provider.dart';
import 'onboarding/welcome_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize providers
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );

      await Future.wait([
        userProvider.initialize(),
        localeProvider.initialize(),
      ]);

      // Wait for splash animation
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      // Navigate based on onboarding status
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => userProvider.isOnboarded
              ? const HomeScreen()
              : const WelcomeScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      if (!mounted) return;
      // Navigate to welcome screen on error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 32),

                // App Name
                Text(
                      'न्याय-उदय',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Nyaya-Uday',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withAlpha(200),
                    letterSpacing: 2,
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 16),

                // Tagline
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Your Path to the Bench',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 60),

                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                    strokeWidth: 3,
                  ),
                ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

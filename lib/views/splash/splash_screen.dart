import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';

/// A fully branded startup/splash screen that is shown while the app
/// initialises (database loads, profile is fetched, etc.).
///
/// It fades in immediately to mask the native Android splash transition,
/// and provides an animated "breathing" indicator so the user knows the
/// app is working rather than frozen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Fade-in for the whole screen content
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // Subtle vertical float for the mascot
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Pulsing dots loading indicator
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    // --- Fade-in (0 → 1 over 600 ms) ---
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // --- Float (up 8 px and back, looping, 2 s period) ---
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // --- Dots (cycles 0 → 1, looping, 1.2 s period) ---
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.bgSurfaceDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top spacer ──────────────────────────────────────────────
              const Spacer(flex: 2),

              // ── Mascot ──────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: child,
                ),
                child: Image.asset(
                  'assets/images/robot_mascot.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 32),

              // ── App name ────────────────────────────────────────────────
              Text(
                'DiaMetrics',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // ── Tagline ─────────────────────────────────────────────────
              Text(
                'Smart Diabetes Management',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppThemeTokens.brandAccent,
                  letterSpacing: 0.2,
                ),
              ),

              // ── Middle spacer ───────────────────────────────────────────
              const Spacer(flex: 3),

              // ── Animated dots ───────────────────────────────────────────
              _AnimatedDots(controller: _dotsCtrl),

              const SizedBox(height: 8),

              Text(
                'Loading your health data…',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three bouncing dots — a lightweight, friendly loading indicator
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 0.2 of the total duration
            final double offset = i * 0.2;
            final double progress = ((controller.value - offset) % 1.0 + 1.0) % 1.0;
            // Bounce up then back (0→1→0)
            final double scale = progress < 0.5
                ? 1.0 + progress * 0.8
                : 1.0 + (1.0 - progress) * 0.8;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: AppThemeTokens.brandAccent.withValues(
                  alpha: 0.4 + progress * 0.6,
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

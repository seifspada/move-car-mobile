// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _formFocused = false;

  // Quand l'animation est finie ET focused → on retire complètement le logo du tree
  bool _logoVisible = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset>  _logoSlide;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _logoOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.2), // monte vers le haut et sort de l'écran
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );

    // Quand l'animation "disparition" est terminée → retirer du layout
    _animCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _logoVisible = false);
      } else if (status == AnimationStatus.reverse ||
                 status == AnimationStatus.dismissed) {
        setState(() => _logoVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onFormFocus(bool focused) {
    if (focused == _formFocused) return;
    setState(() => _formFocused = focused);

    if (focused) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.isAuthenticated) {
        // Navigation gérée par GoRouter
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _onFormFocus(false);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Halo top-right ────────────────────────────
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Halo bottom-left ──────────────────────────
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ── Logo : présent dans le layout seulement si visible ──
                      if (_logoVisible)
                        SlideTransition(
                          position: _logoSlide,
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Column(
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.22),
                                          blurRadius: 28,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.directions_car_rounded,
                                            size: 60,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ── Form card ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: LoginForm(
                          onFocusChanged: _onFormFocus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
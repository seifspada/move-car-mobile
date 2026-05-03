// lib/features/auth/presentation/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  /// Appelé quand un champ reçoit ou perd le focus
  final ValueChanged<bool>? onFocusChanged;

  const LoginForm({super.key, this.onFocusChanged});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _emailFocus.hasFocus || _passwordFocus.hasFocus;
    widget.onFocusChanged?.call(focused);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible d\'ouvrir le lien'),
            backgroundColor: AppColors.errorDark,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.isAuthenticated) {
        if (context.mounted) context.go('/home');
        return;
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textPrimary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(state.errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.errorDark,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── En-tête ────────────────────────────────────
          Text('Connexion', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Entrez vos identifiants pour accéder à votre compte',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // ── Email ──────────────────────────────────────
          _buildLabel('Adresse e-mail'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            cursorColor: AppColors.primary,
            decoration: const InputDecoration(
              hintText: 'exemple@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // ── Mot de passe ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Mot de passe'),
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://move-car-one.vercel.app/auth/forget-password',
                ),
                child: Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
          const SizedBox(height: 28),

          // ── Bouton Se connecter ─────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              gradient: authState.isLoading
                  ? null
                  : LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: authState.isLoading ? AppColors.overlay : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: authState.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: authState.isLoading ? null : _submit,
                child: Center(
                  child: authState.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          'Se connecter',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Divider ─────────────────────────────────────
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 20),

          // ── Inscription ─────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () => _launchUrl(
                'https://move-car-one.vercel.app/formulaire/adherent/inscription-formulaire',
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13),
                  children: [
                    TextSpan(
                      text: "Pas encore de compte ? ",
                      style: TextStyle(color: AppColors.textHint),
                    ),
                    TextSpan(
                      text: "S'inscrire",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
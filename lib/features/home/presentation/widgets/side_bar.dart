// lib/features/home/presentation/widgets/side_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/nav_provider.dart';

final sideBarOpenProvider = StateProvider<bool>((ref) => false);

class SideBar extends ConsumerWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen  = ref.watch(sideBarOpenProvider);
    final screenW = MediaQuery.of(context).size.width;

    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // ── Backdrop flouté ───────────────────────
        GestureDetector(
          onTap: () => ref.read(sideBarOpenProvider.notifier).state = false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.45),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // ── Panneau sidebar ───────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {},
            child: AnimatedSlide(
              offset: isOpen ? Offset.zero : const Offset(-1, 0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: Container(
                width: screenW * 0.78,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(8, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SideBarHeader(),   // ✅ plus de user
                      Divider(
                        color: AppColors.border,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      const _ScoreCard(),        // ✅ plus de user
                      Divider(
                        color: AppColors.border,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SideBarSection(
                                label: 'Suivi missions',
                                icon: Icons.route_rounded,
                              ),
                              const _SideBarNavItem(
                                icon: Icons.dashboard_customize_outlined,
                                activeIcon: Icons.dashboard_customize_rounded,
                                label: 'Tableau de bord',
                                navIndex: 0,
                              ),
                              const _SideBarNavItem(
                                icon: Icons.route_outlined,
                                activeIcon: Icons.route_rounded,
                                label: 'Mes missions',
                                navIndex: 1,
                              ),
                              const _SideBarNavItem(
                                icon: Icons.edit_calendar_outlined,
                                activeIcon: Icons.edit_calendar_rounded,
                                label: 'Réservations',
                                navIndex: 2,
                              ),
                              const SizedBox(height: 8),
                              _SideBarSection(
                                label: 'Paramètres',
                                icon: Icons.settings_rounded,
                              ),
                              const _SideBarNavItem(
                                icon: Icons.person_pin_outlined,
                                activeIcon: Icons.person_pin_rounded,
                                label: 'Mon profil',
                                navIndex: 3,
                              ),
                              _SideBarActionItem(
                                icon: Icons.notifications_outlined,
                                label: 'Notifications',
                                onTap: () {},
                              ),
                              _SideBarActionItem(
                                icon: Icons.help_outline_rounded,
                                label: 'Aide & Support',
                                onTap: () {},
                              ),
                              _SideBarActionItem(
                                icon: Icons.info_outline_rounded,
                                label: 'À propos',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      const _SideBarLogout(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────
class _SideBarHeader extends StatelessWidget {
  const _SideBarHeader();   // ✅ plus de user

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16);
  }
}

// ── Score card (valeurs statiques) ────────────────────────
class _ScoreCard extends StatelessWidget {
  const _ScoreCard();       // ✅ plus de user

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.primaryLight.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _ScoreStat(
              value: '4.8',
              label: 'Score',
              icon: Icons.star_rounded,
              color: Color(0xFFEAB308),
            ),
            _VerticalDivider(),
            _ScoreStat(
              value: '24',
              label: 'Missions',
              icon: Icons.route_rounded,
              color: AppColors.primary,
            ),
            _VerticalDivider(),
            const _ScoreStat(
              value: '98%',
              label: 'Évaluation',
              icon: Icons.thumb_up_rounded,
              color: Color(0xFF22C55E),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat item ──────────────────────────────────────────────
class _ScoreStat extends StatelessWidget {
  final String   value;
  final String   label;
  final IconData icon;
  final Color    color;

  const _ScoreStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Diviseur vertical ──────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: AppColors.border,
    );
  }
}

// ── Section label ──────────────────────────────────────────
class _SideBarSection extends StatelessWidget {
  final String   label;
  final IconData icon;
  const _SideBarSection({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 12),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item de navigation ─────────────────────────────────────
class _SideBarNavItem extends ConsumerWidget {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  final int      navIndex;

  const _SideBarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.navIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final isSelected   = currentIndex == navIndex;

    return GestureDetector(
      onTap: () {
        ref.read(navIndexProvider.notifier).state = navIndex;
        ref.read(sideBarOpenProvider.notifier).state = false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : AppColors.textHint,
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Item action ────────────────────────────────────────────
class _SideBarActionItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _SideBarActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textHint, size: 17),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton déconnexion ─────────────────────────────────────
class _SideBarLogout extends ConsumerWidget {
  const _SideBarLogout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () async {
                ref.read(sideBarOpenProvider.notifier).state = false;
                await ref.read(authProvider.notifier).logout();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
              ),
              const SizedBox(width: 14),
              Text(
                isLoading ? 'Déconnexion...' : 'Déconnexion',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
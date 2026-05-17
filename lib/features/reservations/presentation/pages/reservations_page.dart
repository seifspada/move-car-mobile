// lib/features/reservations/presentation/pages/reservations_page.dart

import 'package:convoyeur_mobile/features/reservations/presentation/providers/reservation_providers.dart';
import 'package:convoyeur_mobile/features/reservations/presentation/widgets/reservation-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../../domain/entities/reservation_entity.dart';
// ✅ Doit pointer vers le bon provider


class _Filter {
  final String value;
  final String label;
  const _Filter(this.value, this.label);
}

const _filters = [
  _Filter('ALL',                   'Toutes'),
  _Filter('EN_ATTENTE',            'En attente'),
  _Filter('ACCEPTED_BY_AGENT',     'À confirmer'),
  _Filter('CONFIRMED_BY_ADHERENT', 'Confirmées'),
  _Filter('ANNULATION_DEMANDEE',   'Annul. en cours'),
  _Filter('REFUSEE',               'Refusées'),
  _Filter('ANNULEE',               'Annulées'),
  _Filter('TERMINEE',              'Terminées'),
];

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'ALL';

  late final AnimationController _headerCtrl;
  late final Animation<Offset>   _headerSlide;
  late final Animation<double>   _headerFade;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    // ✅ Déclencher le fetch ici — le token est déjà disponible
    // car on arrive sur cette page APRÈS le login réussi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationProvider.notifier).fetchMyReservations();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  List<ReservationEntity> _filtered(List<ReservationEntity> all) {
    if (_activeFilter == 'ALL') return all;
    return all.where((r) => r.statut == _activeFilter).toList();
  }

  int _countByStatut(List<ReservationEntity> all, String statut) =>
      all.where((r) => r.statut == statut).length;

  Future<void> _handleCancel(String id, String? motif) async {
    final error = await ref
        .read(reservationProvider.notifier)
        .cancelReservation(id, motif: motif);
    if (mounted) _showSnack(error ?? 'Réservation annulée', success: error == null);
  }

  Future<void> _handleRequestCancellation(String id, String motif) async {
    final error = await ref
        .read(reservationProvider.notifier)
        .requestCancellation(id, motif);
    if (mounted) _showSnack(error ?? "Demande d'annulation envoyée", success: error == null);
  }

  Future<void> _handleConfirm(String id) async {
    final error = await ref.read(reservationProvider.notifier).confirm(id);
    if (mounted) _showSnack(error ?? 'Réservation confirmée ! ✅', success: error == null);
  }

  Future<void> _handleCancelPending(String id) async {
    final error = await ref.read(reservationProvider.notifier).cancelPending(id);
    if (mounted) _showSnack(error ?? 'Réservation annulée', success: error == null);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF22C55E) : AppColors.errorDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state        = ref.watch(reservationProvider);
    final reservations = state.reservations;
    final filtered     = _filtered(reservations);
    final nbAConfirmer = _countByStatut(reservations, 'ACCEPTED_BY_AGENT');
debugPrint('🔍 state.reservations.length = ${state.reservations.length}');
debugPrint('🔍 state.isLoading = ${state.isLoading}');
debugPrint('🔍 state.errorMessage = ${state.errorMessage}');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(reservations, nbAConfirmer),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? _buildSkeletons()
                  : state.errorMessage != null
                      ? _buildError(state.errorMessage!)
                      : CustomScrollView(
                          slivers: [
                            if (reservations.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: _StatsBar(reservations: reservations),
                                ),
                              ),
                            SliverToBoxAdapter(child: _buildFilters(reservations)),
                            if (filtered.isEmpty)
                              SliverFillRemaining(child: _EmptyState(filter: _activeFilter))
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final r = filtered[index];
                                      return ReservationCard(
                                        reservation: r,
                                        isActionLoading: state.actionLoadingId == r.id,
                                        onCancel: _handleCancel,
                                        onRequestCancellation: _handleRequestCancellation,
                                        onConfirm: _handleConfirm,
                                        onCancelPending: _handleCancelPending,
                                      );
                                    },
                                    childCount: filtered.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<ReservationEntity> all, int nbAConfirmer) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes réservations',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${all.length} réservation${all.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                ],
              ),
              GestureDetector(
                onTap: () => ref.read(reservationProvider.notifier).fetchMyReservations(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: AppColors.textHint, size: 20),
                ),
              ),
            ],
          ),
          if (nbAConfirmer > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$nbAConfirmer',
                          style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Réservation${nbAConfirmer > 1 ? 's' : ''} en attente de votre confirmation',
                          style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        const Text("L'agent a accepté — confirmez pour finaliser",
                            style: TextStyle(color: Color(0x993B82F6), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(List<ReservationEntity> all) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: _filters.map((f) {
          final count   = f.value == 'ALL' ? all.length : all.where((r) => r.statut == f.value).length;
          final isActive = _activeFilter == f.value;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                '${f.label} ($count)',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Impossible de charger vos réservations',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.read(reservationProvider.notifier).fetchMyReservations(),
                child: const Text('Réessayer',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.8).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _box(160, 14), _box(80, 22, radius: 20),
              ]),
              const SizedBox(height: 10),
              _box(120, 10),
              const SizedBox(height: 10),
              Row(children: [_box(80, 10), const SizedBox(width: 12), _box(80, 10)]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _box(double.infinity, 36, radius: 12)),
                const SizedBox(width: 8),
                _box(38, 36, radius: 10),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 8}) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ── Stats bar ──────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final List<ReservationEntity> reservations;
  const _StatsBar({required this.reservations});
  int _count(String s) => reservations.where((r) => r.statut == s).length;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'En attente',   value: _count('EN_ATTENTE'),            color: const Color(0xFFEAB308)),
      (label: 'À confirmer',  value: _count('ACCEPTED_BY_AGENT'),     color: const Color(0xFF3B82F6)),
      (label: 'Confirmées',   value: _count('CONFIRMED_BY_ADHERENT'), color: const Color(0xFF22C55E)),
      (label: 'Annul. cours', value: _count('ANNULATION_DEMANDEE'),   color: AppColors.primary),
    ];
    if (stats.every((s) => s.value == 0)) return const SizedBox.shrink();
    return Row(
      children: stats.map((s) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: s.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Text('${s.value}', style: TextStyle(color: s.color, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(s.label, style: const TextStyle(color: AppColors.textHint, fontSize: 9), textAlign: TextAlign.center),
          ]),
        ),
      )).toList(),
    );
  }
}

// ── Empty state ────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.surfaceElevated, shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, color: AppColors.textHint, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Aucune réservation',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            filter == 'ALL'
                ? "Vous n'avez pas encore effectué de réservation."
                : 'Aucune réservation avec ce statut.',
            style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
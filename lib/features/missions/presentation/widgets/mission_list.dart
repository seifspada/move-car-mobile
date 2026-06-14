// lib/features/missions/presentation/widgets/mission_list.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mission_card.dart';
import 'package:go_router/go_router.dart';

typedef MissionOnTap = void Function(String missionId);

class MissionList extends ConsumerStatefulWidget {
  final List<MissionModel> missions;
  final bool loading;
  final MissionOnTap? onMissionTap;
  final ScrollController? scrollController;

  const MissionList({
    super.key,
    required this.missions,
    this.loading = false,
    this.onMissionTap,
    this.scrollController,
  });

  @override
  ConsumerState<MissionList> createState() => _MissionListState();
}

class _MissionListState extends ConsumerState<MissionList> {
  // ✅ Source de vérité unique pour les favoris
  late Set<String> _favoriteIds;
  _Tab _activeTab = _Tab.all;

  @override
  void initState() {
    super.initState();
    // Initialisé depuis les données backend
    _favoriteIds = widget.missions
        .where((m) => m.isFavori == true)
        .map((m) => m.id)
        .toSet();
  }

  // ✅ Callback appelé par MissionCard à chaque toggle
  void _handleFavoriteToggle(String missionId, bool newValue) {
    setState(() {
      if (newValue) {
        _favoriteIds.add(missionId);
      } else {
        _favoriteIds.remove(missionId);
      }
    });
  }

  List<MissionModel> get _displayedMissions {
    if (_activeTab == _Tab.favorites) {
      return widget.missions.where((m) => _favoriteIds.contains(m.id)).toList();
    }
    return widget.missions;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return _buildLoadingGrid(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Onglets Toutes / Favoris ──
        _buildTabs(),
        const SizedBox(height: 16),

        // ── Contenu ──
        if (_displayedMissions.isEmpty)
          _buildEmptyState(context)
        else
          _buildMissionsGrid(context),
      ],
    );
  }

  // ─── Tabs ────────────────────────────────────────────────
  Widget _buildTabs() {
    final favCount = _favoriteIds.length;

    return Row(
      children: [
        _TabButton(
          label: 'Toutes',
          isActive: _activeTab == _Tab.all,
          onTap: () => setState(() => _activeTab = _Tab.all),
        ),
        const SizedBox(width: 8),
        _TabButton(
          label: 'Favoris',
          isActive: _activeTab == _Tab.favorites,
          onTap: () => setState(() => _activeTab = _Tab.favorites),
          icon: Icons.star_rounded,
          badge: favCount > 0 ? favCount : null,
        ),
      ],
    );
  }

  // ─── Loading Grid ─────────────────────────────────────────
  Widget _buildLoadingGrid(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmall ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isSmall ? 0.58 : 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Shimmer(),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    final isFavTab = _activeTab == _Tab.favorites;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                isFavTab ? Icons.star_border_rounded : Icons.search_rounded,
                color: Colors.grey[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFavTab ? 'Aucun favori pour l\'instant' : 'Aucune mission trouvée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isFavTab
                  ? 'Appuyez sur l\'étoile d\'une mission pour l\'ajouter'
                  : 'Ajustez vos filtres et réessayez',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Missions Grid ────────────────────────────────────────
  Widget _buildMissionsGrid(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmall ? 2 : 3;
    final missions = _displayedMissions;

    return GridView.builder(
      controller: widget.scrollController,
      shrinkWrap: true,
      physics: widget.scrollController == null
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isSmall ? 0.58 : 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return MissionCard(
          mission: mission,
          // ✅ État favori contrôlé par le parent
          isFavoriOverride: _favoriteIds.contains(mission.id),
          onFavoriteToggle: _handleFavoriteToggle,
          onTap: () => context.push('/mission/${mission.id}'),
        );
      },
    );
  }
}

// ─── Enum onglets ─────────────────────────────────────────
enum _Tab { all, favorites }

// ─── Bouton onglet ────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final int? badge;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFF97316).withOpacity(0.12)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? const Color(0xFFF97316).withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isActive
                    ? const Color(0xFFF97316)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFFF97316)
                    : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFF97316).withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFFFFB07A)
                        : const Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Loading Animation ────────────────────────────
class Shimmer extends StatefulWidget {
  final Duration duration;

  const Shimmer({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[800]!.withOpacity(0.5),
                Colors.grey[700]!,
                Colors.grey[800]!.withOpacity(0.5),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
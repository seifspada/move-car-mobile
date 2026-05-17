// lib/features/missions/presentation/widgets/mission_list.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mission_card.dart';

typedef MissionOnTap = void Function(String missionId);

class MissionList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Loading State ──
    if (loading) {
      return _buildLoadingGrid(context);
    }

    // ── Empty State ──
    if (missions.isEmpty) {
      return _buildEmptyState(context);
    }

    // ── Missions Grid ──
    return _buildMissionsGrid(context);
  }

  // ─── Loading Grid ───────────────────────────────────────
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
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Shimmer(
            duration: Duration(milliseconds: 1800),
          ),
        );
      },
    );
  }

  // ─── Empty State ────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
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
                Icons.search_rounded,
                color: Colors.grey[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune mission trouvée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajustez vos filtres et réessayez',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Missions Grid ──────────────────────────────────────
  Widget _buildMissionsGrid(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmall ? 2 : 3;

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: scrollController == null
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
          onTap: onMissionTap != null ? () => onMissionTap!(mission.id) : null,
        );
      },
    );
  }
}

// ─── Shimmer Loading Animation ──────────────────────────
class Shimmer extends StatefulWidget {
  final Duration duration;

  const Shimmer({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
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
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

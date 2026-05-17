import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import 'package:convoyeur_mobile/core/config/mission_icons.dart';
import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MissionCard extends ConsumerStatefulWidget {
  final MissionModel mission;
  final VoidCallback? onTap;

  const MissionCard({Key? key, required this.mission, this.onTap})
      : super(key: key);

  @override
  ConsumerState<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends ConsumerState<MissionCard>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  /// Corrige les chaînes avec encodage Latin-1 corrompu + fallback vide
  String _decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw
        .replaceAll('Ã‰', 'É')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã ', 'à')
        .replaceAll('Ã¨', 'è')
        .replaceAll('Ãª', 'ê')
        .replaceAll('Ã®', 'î')
        .replaceAll('Ã´', 'ô')
        .replaceAll('Ã¹', 'ù')
        .replaceAll('Ã»', 'û')
        .replaceAll('Ã§', 'ç')
        .replaceAll('mÂ³', 'm³')
        .replaceAll('m3', 'm³');
  }

  @override
  Widget build(BuildContext context) {
    final vehicleConfig = getVehicleConfig(widget.mission.typeVehicule);
    final fuelConfig = getFuelConfig(widget.mission.typeCarburant);

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 220;
                final radius = isCompact ? 20.0 : 26.0;
                final padding = isCompact
                    ? const EdgeInsets.fromLTRB(10, 22, 10, 12)
                    : const EdgeInsets.fromLTRB(24, 52, 24, 18);

                return Container(
                  // FIX: clipBehavior empêche tout débordement visible
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111217),
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Color.lerp(
                        const Color(0xFF6F370F),
                        AppColors.primaryLight,
                        _hoverController.value,
                      )!,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.34 + (_hoverController.value * 0.08),
                        ),
                        blurRadius: 14 + (_hoverController.value * 5),
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MissionCardAccentPainter(),
                        ),
                      ),
                      Padding(
                        padding: padding,
                        child: _buildContent(
                          vehicleConfig,
                          fuelConfig,
                          isCompact,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    Map<String, dynamic> vehicleConfig,
    Map<String, dynamic> fuelConfig,
    bool isCompact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopSection(vehicleConfig, isCompact),
        SizedBox(height: isCompact ? 14 : 20),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                label: 'Total',
                value: _formatPrice(widget.mission.montantTotal),
                isPrimary: true,
                isCompact: isCompact,
              ),
            ),
            SizedBox(width: isCompact ? 6 : 12),
            Expanded(
              child: _buildMetricBox(
                label: 'Km',
                value: widget.mission.distanceKm.toStringAsFixed(0),
                icon: Icons.route_rounded,
                isCompact: isCompact,
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 14 : 20),
        _buildBottomDetails(vehicleConfig, fuelConfig, isCompact),
      ],
    );
  }

  Widget _buildTopSection(
    Map<String, dynamic> vehicleConfig,
    bool isCompact,
  ) {
    final iconSize = isCompact ? 48.0 : 72.0;
    final favoriteButtonSize = isCompact ? 34.0 : 42.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ligne 1 : icône véhicule (gauche) + étoile (droite)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  vehicleConfig['icon'] as String,
                  width: isCompact ? 30 : 42,
                  height: isCompact ? 30 : 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.local_shipping_outlined,
                    size: isCompact ? 26 : 36,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: favoriteButtonSize,
              height: favoriteButtonSize,
              child: _buildFavoriteButton(isCompact),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 4 : 6),
        // Ligne 2 : villes sur toute la largeur
        _buildRoute(isCompact),
      ],
    );
  }

  Widget _buildRoute(bool isCompact) {
    final depart = _decode(widget.mission.villeDepart);
    final arrivee = _decode(widget.mission.villeArrivee);

    final departDisplay = depart.isNotEmpty ? depart : '—';
    final arriveeDisplay = arrivee.isNotEmpty ? arrivee : '—';
    final fontSize = isCompact ? 16.0 : 22.0;

    // Pleine largeur garantie par le parent Column(stretch)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          departDisplay,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isCompact ? 5 : 8),
        Row(
          children: [
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color.fromARGB(255, 0, 0, 0),
              size: isCompact ? 13 : 20,
            ),
            SizedBox(width: isCompact ? 4 : 6),
            Expanded(
              child: Text(
                arriveeDisplay,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(bool isCompact) {
    return GestureDetector(
      onTap: () => setState(() => _isFavorite = !_isFavorite),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCompact ? 34 : 42,
        height: isCompact ? 34 : 42,
        decoration: BoxDecoration(
          color: _isFavorite
              ? AppColors.primaryLight.withOpacity(0.15)
              : const Color(0xFF16171D),
          border: Border.all(
            color: _isFavorite
                ? AppColors.primaryLight.withOpacity(0.6)
                : Colors.white.withOpacity(0.14),
            width: 1.2,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
          color:
              _isFavorite ? AppColors.primaryLight : const Color(0xFF9CA3AF),
          size: isCompact ? 18 : 22,
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    IconData? icon,
    bool isPrimary = false,
    bool isCompact = false,
  }) {
    return Container(
      height: isCompact ? 58 : 72,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withOpacity(0.08)
            : const Color(0xFF101116),
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withOpacity(0.7)
              : Colors.white.withOpacity(0.14),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: const Color(0xFF9CA3AF),
                    size: isCompact ? 13 : 16),
                SizedBox(width: isCompact ? 3 : 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFB3B3BF),
                  fontSize: isCompact ? 11 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 2 : 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      color:
                          isPrimary ? AppColors.primaryLight : Colors.white,
                      fontSize: isCompact ? 17 : 24,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDetails(
    Map<String, dynamic> vehicleConfig,
    Map<String, dynamic> fuelConfig,
    bool isCompact,
  ) {
    // FIX: decode les labels
    final fuelLabel = _decode(fuelConfig['label'] as String?);
    final vehicleLabel = _decode(vehicleConfig['label'] as String?);

    if (isCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailLine(
                  icon: Icons.local_shipping_outlined,
                  isCompact: true,
                  child: Text(
                    vehicleLabel.isNotEmpty ? vehicleLabel : '—',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailLine(
                  icon: Icons.local_gas_station_rounded,
                  iconColor: AppColors.primaryLight,
                  isCompact: true,
                  // FIX: FittedBox évite le word-wrap sur "Essence"
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fuelLabel.isNotEmpty ? fuelLabel : '—',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailLine(
                  icon: Icons.calendar_month_outlined,
                  isCompact: true,
                  child: Text(
                    _formatDateRange(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetailLine(
                  icon: Icons.toll_outlined,
                  isCompact: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Péage',
                        style: TextStyle(
                          color: Color(0xFF8C8D98),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatPrice(widget.mission.fraisPeage),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Mode normal (non compact)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailLine(
                icon: Icons.local_shipping_outlined,
                child: Text(
                  vehicleLabel.isNotEmpty ? vehicleLabel : '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 18),
              _buildDetailLine(
                icon: Icons.calendar_month_outlined,
                child: Text(
                  _formatDateRange(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailLine(
                icon: Icons.local_gas_station_rounded,
                iconColor: AppColors.primaryLight,
                child: Text(
                  fuelLabel.isNotEmpty ? fuelLabel : '—',
                  style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailLine(
                icon: Icons.toll_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Péage',
                      style: TextStyle(
                        color: Color(0xFF8C8D98),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(widget.mission.fraisPeage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailLine({
    IconData? icon,
    String? iconAsset,
    Color iconColor = const Color(0xFF8C8D98),
    bool isCompact = false,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isCompact ? 20 : 28,
          height: isCompact ? 18 : 24,
          child: Align(
            alignment: Alignment.topCenter,
            child: iconAsset != null
                ? Image.asset(
                    iconAsset,
                    width: isCompact ? 13 : 18,
                    height: isCompact ? 13 : 18,
                    color: iconColor,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_gas_station_rounded,
                      color: iconColor,
                      size: isCompact ? 13 : 18,
                    ),
                  )
                : Icon(icon, color: iconColor, size: isCompact ? 14 : 20),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  String _formatPrice(double value) {
    return '${value.toStringAsFixed(2)}€';
  }

  String _formatDateRange() {
    final start = widget.mission.dateDebut;
    if (start == null) return 'N/A';

    final formatter = DateFormat('dd/MM');
    final startDate = formatter.format(start);
    final end = widget.mission.dateDepartMax;

    if (end == null) return startDate;
    return '$startDate\n${formatter.format(end)}';
  }
}

class _MissionCardAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFF4B0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.72, 0)
      ..lineTo(0, size.height * 0.55)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
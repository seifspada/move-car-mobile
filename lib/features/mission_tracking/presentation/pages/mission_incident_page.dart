import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';

import '../../../../core/utils/geolocator_service.dart';
import '../widgets/incident_bottom_sheet.dart';

class MissionIncidentPage extends StatefulWidget {
  final String missionId;
  final String sessionId;
  final String reservationId;
  final double fallbackLatitude;
  final double fallbackLongitude;

  const MissionIncidentPage({
    super.key,
    required this.missionId,
    required this.sessionId,
    required this.reservationId,
    required this.fallbackLatitude,
    required this.fallbackLongitude,
  });

  @override
  State<MissionIncidentPage> createState() => _MissionIncidentPageState();
}

class _MissionIncidentPageState extends State<MissionIncidentPage> {
  double? _latitude;
  double? _longitude;
  bool _isLoading = true;
  String? _warning;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    setState(() {
      _isLoading = true;
      _warning = null;
    });

    final hasPermission = await GeolocatorService.requestLocationPermission();
    final position = hasPermission
        ? await GeolocatorService.getCurrentPosition()
        : null;

    if (!mounted) return;

    setState(() {
      _latitude  = position?.latitude  ?? widget.fallbackLatitude;
      _longitude = position?.longitude ?? widget.fallbackLongitude;
      _isLoading = false;
      if (position == null) {
        _warning =
            'Position GPS actuelle indisponible. La position de départ est utilisée.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Signaler un incident',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.border,
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_warning != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _WarningBanner(
                            message: _warning!,
                            onRetry: _loadPosition,
                          ),
                        ),
                      IncidentBottomSheet(
                        sessionId: widget.sessionId,
                        latitude: _latitude!,
                        longitude: _longitude!,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WarningBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.30),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Réessayer',
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
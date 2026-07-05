import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/platform_utils.dart';

/// Clés utilisées pour communiquer entre isolate background et UI
const String kBgUpdateLocation = 'update_location';
const String kBgCheckArrival = 'check_arrival';
const String kBgStopService = 'stop_service';
const String kBgPositionUpdate = 'position_update';
const String kBgArrivalResult = 'arrival_result';

/// À appeler au démarrage de l'app (main.dart ou app.dart)
Future<void> initBackgroundService() async {
  if (!PlatformUtils.supportsBackgroundService) return;

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'mission_tracking_channel',
      initialNotificationTitle: 'Mission en cours',
      initialNotificationContent: 'Suivi GPS actif',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  String? currentMissionId;
  String? currentSessionId;

  // Recevoir la config depuis l'UI
  service.on('set_mission').listen((data) {
    currentMissionId = data?['missionId'];
    currentSessionId = data?['sessionId'];
  });

  // Arrêter le service proprement
  service.on(kBgStopService).listen((_) async {
    await service.stopSelf();
  });

  // Boucle GPS toutes les secondes pour alimenter l’API en temps réel
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (currentMissionId == null || currentSessionId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Envoyer la position vers l'UI
      service.invoke(kBgPositionUpdate, {
        'missionId': currentMissionId,
        'sessionId': currentSessionId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        if (position.speed >= 0) 'speed': position.speed,
        'timestamp': (position.timestamp ?? DateTime.now())
            .toUtc()
            .toIso8601String(),
      });
    } catch (e) {
      // Pas de position disponible — on ignore silencieusement
    }
  });
}

/// Démarre le service avec missionId et sessionId
Future<void> startMissionTracking({
  required String missionId,
  required String sessionId,
}) async {
  if (!PlatformUtils.supportsBackgroundService) return;

  final service = FlutterBackgroundService();
  await service.startService();
  service.invoke('set_mission', {
    'missionId': missionId,
    'sessionId': sessionId,
  });
}

/// Arrête le service background
Future<void> stopMissionTracking() async {
  if (!PlatformUtils.supportsBackgroundService) return;

  final service = FlutterBackgroundService();
  service.invoke(kBgStopService);
}

Stream<Map<String, dynamic>?> backgroundPositionUpdates() {
  if (!PlatformUtils.supportsBackgroundService) {
    return const Stream.empty();
  }

  return FlutterBackgroundService().on(kBgPositionUpdate);
}

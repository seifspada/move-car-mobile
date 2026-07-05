import 'package:flutter_test/flutter_test.dart';
import 'package:convoyeur_mobile/features/mission_tracking/data/repositories/mission_tracking_repository_impl.dart';

void main() {
  group('MissionTrackingRepositoryImpl', () {
    test('builds update location input with speed and timestamp', () {
      final input = MissionTrackingRepositoryImpl.buildUpdateLocationInput(
        missionId: 'mission-1',
        latitude: 36.8123,
        longitude: 10.1654,
        accuracy: 5.2,
        timestamp: DateTime.utc(2026, 7, 2, 12, 0, 0),
        speed: 3.5,
      );

      expect(input['missionId'], 'mission-1');
      expect(input['latitude'], 36.8123);
      expect(input['longitude'], 10.1654);
      expect(input['accuracy'], 5.2);
      expect(input['timestamp'], '2026-07-02T12:00:00.000Z');
      expect(input['speed'], 3.5);
    });
  });
}

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// 위치 권한·현재 위치·역지오코딩(주소 조회).
class LocationService {
  Future<bool> requestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  Future<Position?> getCurrentPosition() async {
    final ok = await requestPermission();
    if (!ok) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  /// 위·경도 → 주소 문자열 (한국어 우선).
  Future<String?> addressFromLatLng(double lat, double lng) async {
    try {
      final list = await placemarkFromCoordinates(lat, lng);
      if (list.isEmpty) return null;
      final p = list.first;
      final parts = <String>[];
      void addIfNew(String? value) {
        if (value != null && value.isNotEmpty && !parts.contains(value)) {
          parts.add(value);
        }
      }
      addIfNew(p.country);
      addIfNew(p.administrativeArea);
      addIfNew(p.locality);
      addIfNew(p.subLocality);
      addIfNew(p.street);
      return parts.isEmpty ? null : parts.join(' ');
    } catch (_) {
      return null;
    }
  }
}

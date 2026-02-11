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
      final parts = <String>[
        if (p.country?.isNotEmpty == true) p.country!,
        if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
        if (p.locality?.isNotEmpty == true) p.locality!,
        if (p.street?.isNotEmpty == true) p.street!,
      ];
      return parts.isEmpty ? null : parts.join(' ');
    } catch (_) {
      return null;
    }
  }
}

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../constants/weather.dart';

/// 위치 기반으로 Open-Meteo API에서 현재 날씨(온도·습도) 조회.
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// 현재 위치 권한 요청 후 위·경도 반환. 실패 시 null.
  Future<Position?> getCurrentPosition() async {
    final ok = await Geolocator.checkPermission();
    if (ok == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested != LocationPermission.whileInUse &&
          requested != LocationPermission.always) return null;
    }
    if (ok == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  /// 위·경도로 현재 날씨 조회. 반환 형식: "맑음 23°C 습도 60%" 등.
  Future<String?> fetchWeatherFromLocation(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('', 408),
      );
      if (response.statusCode != 200) return null;
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final current = map['current'] as Map<String, dynamic>?;
      if (current == null) return null;
      final temp = (current['temperature_2m'] as num?)?.toDouble();
      final humidity = (current['relative_humidity_2m'] as int?)?.toInt();
      final code = (current['weather_code'] as int?)?.toInt() ?? 0;
      final condition = _weatherCodeToLabel(code);
      final parts = <String>[condition];
      if (temp != null) parts.add('${temp.round()}°C');
      if (humidity != null) parts.add('습도 ${humidity}%');
      return parts.join(' ');
    } catch (_) {
      return null;
    }
  }

  String _weatherCodeToLabel(int code) {
    if (code == 0) return weatherOptionClear;
    if (code >= 1 && code <= 3) return weatherOptionCloudy;
    if (code >= 51 && code <= 67) return weatherOptionRain;
    if (code >= 71 && code <= 77) return weatherOptionSnow;
    if (code >= 80 && code <= 82) return weatherOptionRain;
    if (code >= 85 && code <= 86) return weatherOptionSnow;
    if (code >= 95 && code <= 99) return weatherOptionRain;
    return weatherOptionCloudy;
  }
}

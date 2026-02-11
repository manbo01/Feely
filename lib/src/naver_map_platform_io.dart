import 'dart:io' show Platform;

/// Android / iOS 에서만 네이버 지도 지원
bool get isNaverMapSupported => Platform.isAndroid || Platform.isIOS;

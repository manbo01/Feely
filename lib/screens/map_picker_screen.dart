import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../services/location_service.dart';
import '../src/naver_map_platform_io.dart' if (dart.library.html) '../src/naver_map_platform_stub.dart' as naver_platform;

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  NaverMapController? _mapController;
  final LocationService _location = LocationService();
  NLatLng? _selectedLatLng;
  NLatLng? _initialCenter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await _location.getCurrentPosition();
    if (mounted) {
      setState(() {
        if (pos != null) {
          _initialCenter = NLatLng(pos.latitude, pos.longitude);
          _selectedLatLng = _initialCenter;
        } else {
          _initialCenter = const NLatLng(37.5665, 126.9780);
          _selectedLatLng = _initialCenter;
          _error = '위치를 불러올 수 없어 서울 중심으로 표시합니다.';
        }
        _loading = false;
      });
    }
  }

  void _onMapTapped(NPoint point, NLatLng latLng) {
    setState(() => _selectedLatLng = latLng);
    _updateMarker();
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _updateMarker();
  }

  Future<void> _updateMarker() async {
    final c = _mapController;
    if (c == null || _selectedLatLng == null) return;
    await c.clearOverlays();
    final marker = NMarker(
      id: 'picked',
      position: _selectedLatLng!,
    );
    await c.addOverlay(marker);
  }

  void _zoomIn() {
    _mapController?.updateCamera(NCameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.updateCamera(NCameraUpdate.zoomOut());
  }

  Future<void> _confirm() async {
    if (_selectedLatLng == null) return;
    final address = await _location.addressFromLatLng(
      _selectedLatLng!.latitude,
      _selectedLatLng!.longitude,
    );
    if (!mounted) return;
    Navigator.pop(
      context,
      address ??
          '${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!FlutterNaverMap.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('장소 선택'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  naver_platform.isNaverMapSupported
                      ? '네이버 지도 초기화에 실패했습니다.'
                      : '네이버 지도는 Android·iOS 앱에서만 사용할 수 있습니다.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  naver_platform.isNaverMapSupported
                      ? 'lib/config/naver_map_config.dart에 올바른 Client ID를 넣었는지 확인하고, 앱을 완전히 종료한 뒤 다시 실행해 주세요.'
                      : '실기 또는 시뮬레이터(iOS/Android)에서 실행하면 장소 지도를 사용할 수 있습니다.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final center = _initialCenter ?? const NLatLng(37.5665, 126.9780);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 선택'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: center,
                      zoom: 15,
                    ),
                    locationButtonEnable: true,
                    zoomGesturesEnable: true,
                    scrollGesturesEnable: true,
                  ),
                  onMapReady: _onMapReady,
                  onMapTapped: _onMapTapped,
                ),
                if (_error != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomButton(icon: Icons.add, onPressed: _zoomIn),
                      const SizedBox(height: 8),
                      _ZoomButton(icon: Icons.remove, onPressed: _zoomOut),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '지도를 탭해 위치에 핑을 꽂은 뒤 아래 "선택" 버튼을 누르세요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _selectedLatLng != null ? _confirm : null,
                      child: const Text('선택'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

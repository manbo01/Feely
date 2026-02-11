import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/weather.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../services/weather_service.dart';
import '../widgets/emotion_chip_grid.dart';
import '../widgets/intensity_slider.dart';
import 'map_picker_screen.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key, this.entryId, this.initialDate});

  final String? entryId;
  final DateTime? initialDate;

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  final _weatherController = TextEditingController();
  final _placeController = TextEditingController();
  final _contentController = TextEditingController();
  late List<String> _selectedEmotions;
  late int _intensity;
  String? _imagePath;
  DiaryEntry? _existing;
  bool _loading = true;
  String _weatherDropdownValue = weatherOptionClear;
  final WeatherService _weatherService = WeatherService();
  bool _weatherAutoLoading = false;
  bool _placeAutoLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initialDate ?? now;
    _selectedEmotions = [];
    _intensity = 5;
    if (widget.entryId != null) {
      _loadEntry();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadEntry() async {
    final provider = context.read<DiaryProvider>();
    final entry = await provider.getEntry(widget.entryId!);
    if (entry != null && mounted) {
      setState(() {
        _existing = entry;
        _date = entry.date;
        _applyWeatherFromText(entry.weatherText);
        _placeController.text = entry.placeText;
        _contentController.text = entry.content;
        _selectedEmotions = List.from(entry.emotionTags);
        _intensity = entry.intensity;
        _imagePath = entry.imagePath;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _weatherController.dispose();
    _placeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<DiaryProvider>();
    final now = DateTime.now();

    final entry = _existing != null
        ? _existing!.copyWith(
            date: _date,
            updatedAt: now,
            emotionTags: _selectedEmotions,
            intensity: _intensity,
            content: _contentController.text.trim(),
            weatherText: _getWeatherText(),
            placeText: _placeController.text.trim(),
            imagePath: _imagePath,
          )
        : DiaryEntry(
            id: const Uuid().v4(),
            date: _date,
            createdAt: now,
            updatedAt: now,
            emotionTags: _selectedEmotions,
            intensity: _intensity,
            content: _contentController.text.trim(),
            weatherText: _getWeatherText(),
            placeText: _placeController.text.trim(),
            imagePath: _imagePath,
          );

    await provider.saveEntry(entry);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final diaryProvider = context.watch<DiaryProvider>();
    final allTags = diaryProvider.allEmotionTags;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('일기 쓰기'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDateField(theme),
            const SizedBox(height: 16),
            _buildSectionLabel(theme, '날씨'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _weatherDropdownValue,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.wb_sunny_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: weatherDropdownOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _weatherDropdownValue = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: _WeatherAutoButton(
                    loading: _weatherAutoLoading,
                    onPressed: _onWeatherAuto,
                  ),
                ),
              ],
            ),
            if (_weatherDropdownValue == weatherOptionCustom) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _weatherController,
                decoration: const InputDecoration(
                  hintText: '날씨를 직접 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildSectionLabel(theme, '장소'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      hintText: '장소를 입력하세요',
                      prefixIcon: Icon(Icons.place_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: _PlaceAutoButton(
                    loading: _placeAutoLoading,
                    onPressed: _onPlaceAuto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(theme, '감정 선택'),
            const SizedBox(height: 8),
            EmotionChipGrid(
              availableTags: allTags,
              selectedTags: _selectedEmotions,
              onChanged: (v) => setState(() => _selectedEmotions = v),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(theme, '감정 강도'),
            const SizedBox(height: 8),
            IntensitySlider(
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(theme, '내용'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '오늘의 감정을 자유롭게 적어보세요.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('첨부된 사진'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _imagePath = null),
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('사진 첨부 (선택)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_date.year}년 ${_date.month}월 ${_date.day}일',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _applyWeatherFromText(String text) {
    if (text == weatherOptionClear || text == weatherOptionCloudy ||
        text == weatherOptionRain || text == weatherOptionSnow) {
      _weatherDropdownValue = text;
      _weatherController.clear();
    } else {
      _weatherDropdownValue = weatherOptionCustom;
      _weatherController.text = text;
    }
  }

  String _getWeatherText() {
    if (_weatherDropdownValue == weatherOptionCustom) {
      return _weatherController.text.trim();
    }
    return _weatherDropdownValue;
  }

  Future<void> _onWeatherAuto() async {
    if (_weatherAutoLoading) return;
    setState(() => _weatherAutoLoading = true);
    try {
      final pos = await _weatherService.getCurrentPosition();
      if (pos == null || !mounted) {
        if (mounted) _showSnackBar('위치를 가져올 수 없습니다.');
        return;
      }
      final text = await _weatherService.fetchWeatherFromLocation(
        pos.latitude,
        pos.longitude,
      );
      if (mounted && text != null) {
        setState(() {
          _weatherDropdownValue = weatherOptionCustom;
          _weatherController.text = text;
        });
      } else if (mounted) {
        _showSnackBar('날씨를 가져올 수 없습니다.');
      }
    } catch (_) {
      if (mounted) _showSnackBar('날씨를 가져올 수 없습니다.');
    } finally {
      if (mounted) setState(() => _weatherAutoLoading = false);
    }
  }

  Future<void> _onPlaceAuto() async {
    if (_placeAutoLoading) return;
    setState(() => _placeAutoLoading = true);
    try {
      final address = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const MapPickerScreen(),
        ),
      );
      if (address != null && mounted) {
        setState(() => _placeController.text = address);
      }
    } finally {
      if (mounted) setState(() => _placeAutoLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage() async {
    try {
      final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picker != null && mounted) setState(() => _imagePath = picker.path);
    } catch (_) {}
  }
}

class _WeatherAutoButton extends StatelessWidget {
  const _WeatherAutoButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('자동'),
    );
  }
}

class _PlaceAutoButton extends StatelessWidget {
  const _PlaceAutoButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('자동'),
    );
  }
}


import 'package:flutter/material.dart';
import 'image_preview_io.dart' if (dart.library.html) 'image_preview_stub.dart' as image_preview;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/weather.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
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
  List<String> _imagePaths = [];
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
    if (widget.entryId != null) {
      _date = widget.initialDate ?? now;
    } else {
      // 일기 생성 시 현재 날짜·시간을 초기값으로
      final base = widget.initialDate ?? now;
      _date = DateTime(base.year, base.month, base.day, now.hour, now.minute);
    }
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
        _imagePaths = List.from(entry.imagePaths);
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
            imagePaths: _imagePaths,
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
            imagePaths: _imagePaths,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.entryId != null ? '일기 수정' : '일기 생성',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
            _buildSectionLabel(theme, '날짜'),
            const SizedBox(height: 8),
            _buildDateLine(theme),
            const SizedBox(height: 20),
            _buildSectionLabel(theme, '시간'),
            const SizedBox(height: 8),
            _buildTimeLine(theme),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '날씨',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _WeatherAutoButton(
                  loading: _weatherAutoLoading,
                  onPressed: _onWeatherAuto,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _weatherDropdownValue,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.08),
              ),
              items: weatherDropdownOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _weatherDropdownValue = v);
              },
            ),
            if (_weatherDropdownValue == weatherOptionCustom) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _weatherController,
                decoration: InputDecoration(
                  hintText: '오늘의 날씨는 어떤가요?',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: theme.colorScheme.primary.withOpacity(0.08),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '장소',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _PlaceAutoButton(
                  loading: _placeAutoLoading,
                  onPressed: _onPlaceAuto,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: '어디에 계신가요?',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.08),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionLabel(theme, '감정'),
            const SizedBox(height: 8),
            EmotionChipGrid(
              availableTags: allTags,
              selectedTags: _selectedEmotions,
              onChanged: (v) => setState(() => _selectedEmotions = v),
              onAddNew: () => _showAddEmotionDialog(theme),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  '강도 ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$_intensity',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: intensityColor(_intensity),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            IntensitySlider(
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
            const SizedBox(height: 24),
            _buildSectionLabel(theme, '일기'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '어떤 감정을 느끼고 계신가요? 그 이유는 무엇인지 알려주세요.',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.08),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(theme, '사진'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Material(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 28, color: theme.colorScheme.primary),
                          const SizedBox(height: 6),
                          Text(
                            'ADD',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_imagePaths.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildImagePreviews(theme)),
                ],
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(Icons.check, size: 22, color: theme.colorScheme.onPrimary),
                label: Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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

  Widget _buildDateLine(ThemeData theme) {
    const weekdays = '월화수목금토일';
    final dateStr = '${_date.year}년 ${_date.month}월 ${_date.day}일 (${weekdays.substring(_date.weekday - 1, _date.weekday)})';
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _date.hour,
            _date.minute,
          ));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: theme.colorScheme.primary.withOpacity(0.08),
        ),
        child: Text(dateStr, style: theme.textTheme.bodyLarge),
      ),
    );
  }

  Widget _buildTimeLine(ThemeData theme) {
    final isAm = _date.hour < 12;
    final hour12 = _date.hour == 0 ? 12 : (_date.hour > 12 ? _date.hour - 12 : _date.hour);
    final timeStr = '${isAm ? '오전' : '오후'} $hour12:${_date.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () async {
        final picked = await _showScrollTimePicker(context, theme);
        if (picked != null) {
          setState(() => _date = DateTime(
            _date.year,
            _date.month,
            _date.day,
            picked.hour,
            picked.minute,
          ));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.access_time),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: theme.colorScheme.primary.withOpacity(0.08),
        ),
        child: Text(timeStr, style: theme.textTheme.bodyLarge),
      ),
    );
  }

  Future<TimeOfDay?> _showScrollTimePicker(BuildContext context, ThemeData theme) async {
    final initialHour12 = _date.hour == 0 ? 12 : (_date.hour > 12 ? _date.hour - 12 : _date.hour);
    final initialMinute = _date.minute;
    final initialIsPm = _date.hour >= 12;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _ScrollTimePickerDialog(
        theme: theme,
        initialHour12: initialHour12,
        initialMinute: initialMinute,
        initialIsPm: initialIsPm,
      ),
    );
  }

  Widget _buildImagePreviews(ThemeData theme) {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _imagePaths.asMap().entries.map((e) {
        final index = e.key;
        final path = e.value;
        return SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              image_preview.buildImageThumbnail(path),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _imagePaths.removeAt(index)),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  Future<void> _showAddEmotionDialog(ThemeData theme) async {
    final controller = TextEditingController();
    final provider = context.read<DiaryProvider>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('새 감정 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '감정을 입력하세요',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              final t = value.trim();
              if (t.isNotEmpty) Navigator.pop(dialogContext, t);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                final t = controller.text.trim();
                if (t.isNotEmpty) Navigator.pop(dialogContext, t);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty || !mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
      return;
    }
    final text = result;
    final customTags = [...provider.customEmotionTags];
    final isNewTag = !customTags.contains(text);
    if (isNewTag) {
      await provider.setCustomEmotionTags([...customTags, text]);
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
      if (mounted) setState(() => _selectedEmotions = [..._selectedEmotions, text]);
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage();
      if (files.isNotEmpty && mounted) {
        setState(() {
          for (final f in files) {
            if (f.path.isNotEmpty) _imagePaths.add(f.path);
          }
        });
      }
    } catch (_) {}
  }
}

class _ScrollTimePickerDialog extends StatefulWidget {
  const _ScrollTimePickerDialog({
    required this.theme,
    required this.initialHour12,
    required this.initialMinute,
    required this.initialIsPm,
  });

  final ThemeData theme;
  final int initialHour12;
  final int initialMinute;
  final bool initialIsPm;

  @override
  State<_ScrollTimePickerDialog> createState() => _ScrollTimePickerDialogState();
}

class _ScrollTimePickerDialogState extends State<_ScrollTimePickerDialog> {
  late int _hour12;
  late int _minute;
  late bool _isPm;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  @override
  void initState() {
    super.initState();
    _hour12 = widget.initialHour12;
    _minute = widget.initialMinute;
    _isPm = widget.initialIsPm;
    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _amPmController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  TimeOfDay _toTimeOfDay() {
    var h = _hour12;
    if (_isPm && h != 12) h += 12;
    if (!_isPm && h == 12) h = 0;
    return TimeOfDay(hour: h, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    const itemExtent = 44.0;
    const wheelHeight = 180.0;
    final hours = List.generate(12, (i) => i + 1);
    final minutes = List.generate(60, (i) => i);
    final amPm = ['오전', '오후'];

    return AlertDialog(
      title: const Text('시간 선택'),
      content: SizedBox(
        width: 260,
        height: wheelHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ListWheelScrollView(
                controller: _hourController,
                itemExtent: itemExtent,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => setState(() => _hour12 = hours[i]),
                children: hours
                    .map((h) => Center(child: Text('$h', style: widget.theme.textTheme.titleLarge)))
                    .toList(),
              ),
            ),
            Text(':', style: widget.theme.textTheme.titleLarge?.copyWith(color: widget.theme.colorScheme.onSurface)),
            Expanded(
              child: ListWheelScrollView(
                controller: _minuteController,
                itemExtent: itemExtent,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => setState(() => _minute = minutes[i]),
                children: minutes
                    .map((m) => Center(child: Text(m.toString().padLeft(2, '0'), style: widget.theme.textTheme.titleLarge)))
                    .toList(),
              ),
            ),
            Expanded(
              child: ListWheelScrollView(
                controller: _amPmController,
                itemExtent: itemExtent,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => setState(() => _isPm = i == 1),
                children: amPm
                    .map((s) => Center(child: Text(s, style: widget.theme.textTheme.titleMedium)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _toTimeOfDay()),
          child: const Text('확인'),
        ),
      ],
    );
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
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: primary),
                      const SizedBox(width: 4),
                      Text('자동', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
          ),
        ),
      ),
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
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: primary),
                      const SizedBox(width: 4),
                      Text('자동', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}


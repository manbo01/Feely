/// 감정 일기 한 건을 나타내는 모델.
class DiaryEntry {
  final String id;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> emotionTags;
  final int intensity; // 1..10
  final String content;
  final String weatherText;
  final String placeText;
  /// 첨부 사진 경로 목록 (여러 장 지원)
  final List<String> imagePaths;

  const DiaryEntry({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.emotionTags,
    required this.intensity,
    required this.content,
    this.weatherText = '',
    this.placeText = '',
    this.imagePaths = const [],
  });

  /// 이전 단일 imagePath 필드와 호환용 (첫 번째 사진 반환)
  String? get imagePath =>
      imagePaths.isNotEmpty ? imagePaths.first : null;

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? emotionTags,
    int? intensity,
    String? content,
    String? weatherText,
    String? placeText,
    List<String>? imagePaths,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emotionTags: emotionTags ?? List.from(this.emotionTags),
      intensity: intensity ?? this.intensity,
      content: content ?? this.content,
      weatherText: weatherText ?? this.weatherText,
      placeText: placeText ?? this.placeText,
      imagePaths: imagePaths ?? List.from(this.imagePaths),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'emotionTags': emotionTags,
      'intensity': intensity,
      'content': content,
      'weatherText': weatherText,
      'placeText': placeText,
      'imagePaths': imagePaths,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    List<String> paths = [];
    if (json['imagePaths'] != null) {
      paths = List<String>.from(json['imagePaths'] as List);
    } else if (json['imagePath'] != null) {
      paths = [json['imagePath'] as String];
    }
    return DiaryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      emotionTags: List<String>.from(json['emotionTags'] as List? ?? []),
      intensity: (json['intensity'] as num?)?.toInt() ?? 5,
      content: json['content'] as String? ?? '',
      weatherText: json['weatherText'] as String? ?? '',
      placeText: json['placeText'] as String? ?? '',
      imagePaths: paths,
    );
  }
}

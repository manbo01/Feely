import 'package:flutter/material.dart';

/// Web 등: 파일 경로로 이미지를 표시할 수 없을 때 플레이스홀더
Widget buildImagePreview(String path, VoidCallback onRemove) {
  return Stack(
    alignment: Alignment.topRight,
    children: [
      Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      ),
      IconButton.filled(
        icon: const Icon(Icons.close, size: 20),
        onPressed: onRemove,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
        ),
      ),
    ],
  );
}

/// 100x100 썸네일용 플레이스홀더
Widget buildImageThumbnail(String path) {
  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image, size: 32, color: Colors.grey),
  );
}

/// 상세 화면 히어로용 단일 이미지 (웹 플레이스홀더)
Widget buildHeroImage(String path, double height) {
  return Container(
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: const Center(
      child: Icon(Icons.image, size: 64, color: Colors.grey),
    ),
  );
}

/// 상세 화면용 이미지 목록 (웹 플레이스홀더)
List<Widget> buildDetailImages(List<String> paths) {
  if (paths.isEmpty) return [];
  return paths
      .map(
        (path) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      )
      .toList();
}

import 'dart:io';

import 'package:flutter/material.dart';

/// iOS/Android: 실제 파일 경로로 이미지 미리보기 표시 (단일, 큰 미리보기)
Widget buildImagePreview(String path, VoidCallback onRemove) {
  return Stack(
    alignment: Alignment.topRight,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
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

/// 100x100 썸네일용 이미지 위젯 (다중 첨부 시 사용)
Widget buildImageThumbnail(String path) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.file(
      File(path),
      fit: BoxFit.cover,
      width: 100,
      height: 100,
    ),
  );
}

/// 상세 화면 히어로용 단일 이미지 (고정 높이)
Widget buildHeroImage(String path, double height) {
  return ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 48),
        ),
      ),
    ),
  );
}

/// 상세 화면용 이미지 목록 (여러 장)
List<Widget> buildDetailImages(List<String> paths) {
  if (paths.isEmpty) return [];
  return paths
      .map(
        (path) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const ListTile(
                leading: Icon(Icons.broken_image),
                title: Text('이미지를 불러올 수 없습니다'),
              ),
            ),
          ),
        ),
      )
      .toList();
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/emotions.dart';
import '../providers/diary_provider.dart';

class EmotionTagsManagementScreen extends StatelessWidget {
  const EmotionTagsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '감정 태그 관리',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, _) {
          final visibleDefaults = defaultEmotionTags
              .where((t) => !provider.hiddenDefaultTags.contains(t))
              .toList();
          final customTags = provider.customEmotionTags;
          final hiddenDefaults = provider.hiddenDefaultTags;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _sectionTitle(theme, '기본 감정 태그'),
              const SizedBox(height: 8),
              if (visibleDefaults.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '표시 중인 기본 태그가 없습니다. 아래에서 숨긴 태그를 복원할 수 있습니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...visibleDefaults.map(
                  (tag) => _tagTile(
                    context,
                    theme,
                    tag: tag,
                    isDefault: true,
                    onDelete: () => _hideDefaultTag(context, provider, tag),
                  ),
                ),
              const SizedBox(height: 24),
              _sectionTitle(theme, '추가한 감정 태그'),
              const SizedBox(height: 8),
              if (customTags.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '추가한 태그가 없습니다. 하단 버튼으로 새 태그를 추가하세요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...customTags.map(
                  (tag) => _tagTile(
                    context,
                    theme,
                    tag: tag,
                    isDefault: false,
                    onDelete: () => _removeCustomTag(context, provider, tag),
                  ),
                ),
              if (hiddenDefaults.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle(theme, '숨긴 기본 태그'),
                const SizedBox(height: 8),
                ...hiddenDefaults.map(
                  (tag) => _tagTile(
                    context,
                    theme,
                    tag: tag,
                    isDefault: true,
                    showRestore: true,
                    onRestore: () => _restoreDefaultTag(context, provider, tag),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddTagDialog(context, theme, provider),
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text('감정 태그 추가'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _tagTile(
    BuildContext context,
    ThemeData theme, {
    required String tag,
    required bool isDefault,
    bool showRestore = false,
    VoidCallback? onDelete,
    VoidCallback? onRestore,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          tag,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: isDefault && !showRestore
            ? Text(
                '기본 태그',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: showRestore
            ? TextButton(
                onPressed: onRestore,
                child: const Text('복원'),
              )
            : IconButton(
                icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
                onPressed: onDelete,
                tooltip: isDefault ? '목록에서 숨기기' : '삭제',
              ),
      ),
    );
  }

  void _hideDefaultTag(BuildContext context, DiaryProvider provider, String tag) async {
    final next = [...provider.hiddenDefaultTags, tag];
    await provider.setHiddenDefaultEmotionTags(next);
  }

  void _removeCustomTag(BuildContext context, DiaryProvider provider, String tag) async {
    final next = provider.customEmotionTags.where((t) => t != tag).toList();
    await provider.setCustomEmotionTags(next);
  }

  void _restoreDefaultTag(BuildContext context, DiaryProvider provider, String tag) async {
    final next = provider.hiddenDefaultTags.where((t) => t != tag).toList();
    await provider.setHiddenDefaultEmotionTags(next);
  }

  void _showAddTagDialog(BuildContext context, ThemeData theme, DiaryProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('감정 태그 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '새 감정 태그를 입력하세요',
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
      ),
    ).then((result) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
      if (result == null || result is! String) return;
      final text = (result as String).trim();
      if (text.isEmpty) return;
      final custom = [...provider.customEmotionTags];
      if (custom.contains(text)) return;
      provider.setCustomEmotionTags([...custom, text]);
    });
  }
}

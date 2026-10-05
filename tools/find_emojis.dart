// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final prohibited = [
    '⚡', '🔥', '🚀', '🚨', '✅', '🕒', '📄', '👤', '📊', '👶', '💙', '💡', '🎯', '🔍', '✨', '⭐'
  ];
  final regex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}]',
    unicode: true,
  );
  int count = 0;
  for (final dir in [Directory('lib'), Directory('test')]) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final hasProhibited = prohibited.any((p) => line.contains(p));
          final hasUnicodeEmoji = regex.hasMatch(line);
          if (hasProhibited || hasUnicodeEmoji) {
            print('${entity.path}:${i + 1}: ${line.trim()}');
            count++;
          }
        }
      }
    }
  }
  print('Total occurrences: $count');
}

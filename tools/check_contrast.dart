// ignore_for_file: avoid_print
import 'dart:ui';

void main() {
  double ratio(Color a, Color b) {
    final first = a.computeLuminance();
    final second = b.computeLuminance();
    return first > second
        ? (first + 0.05) / (second + 0.05)
        : (second + 0.05) / (first + 0.05);
  }

  print('0xFF0284C7 on white: ${ratio(const Color(0xFF0284C7), const Color(0xFFFFFFFF))}');
  print('0xFF0369A1 on white: ${ratio(const Color(0xFF0369A1), const Color(0xFFFFFFFF))}');
  print('0xFF4F46E5 on white: ${ratio(const Color(0xFF4F46E5), const Color(0xFFFFFFFF))}');
  print('0xFF64748B on white: ${ratio(const Color(0xFF64748B), const Color(0xFFFFFFFF))}');
  print('0xFF475569 on white: ${ratio(const Color(0xFF475569), const Color(0xFFFFFFFF))}');
  print('White on 0xFF0284C7: ${ratio(const Color(0xFFFFFFFF), const Color(0xFF0284C7))}');
  print('White on 0xFF0369A1: ${ratio(const Color(0xFFFFFFFF), const Color(0xFF0369A1))}');
  print('0xFF38BDF8 on 0xFF111318: ${ratio(const Color(0xFF38BDF8), const Color(0xFF111318))}');
}

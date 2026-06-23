/// Small formatting helpers shared across modules.
class FormatUtils {
  FormatUtils._();

  static String two(int n) => n.toString().padLeft(2, '0');

  /// Human-friendly timestamp: `2026-06-21 22:38`.
  static String dateTime(DateTime dt) =>
      '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}

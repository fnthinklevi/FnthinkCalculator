String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatDuration(int totalSeconds) {
  final negative = totalSeconds < 0;
  final absolute = totalSeconds.abs();
  final days = absolute ~/ 86400;
  final hours = (absolute % 86400) ~/ 3600;
  final minutes = (absolute % 3600) ~/ 60;
  final seconds = absolute % 60;
  final buffer = StringBuffer();
  if (negative) {
    buffer.write('-');
  }
  if (days > 0) {
    buffer.write('$days天 ');
  }
  buffer.write(
    '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}',
  );
  return buffer.toString();
}

String formatDurationVerbose(int totalSeconds) {
  final negative = totalSeconds < 0;
  final absolute = totalSeconds.abs();
  final days = absolute ~/ 86400;
  final hours = (absolute % 86400) ~/ 3600;
  final minutes = (absolute % 3600) ~/ 60;
  final seconds = absolute % 60;
  final parts = <String>[];
  if (days > 0) parts.add('$days 天');
  if (hours > 0) parts.add('$hours 小时');
  if (minutes > 0) parts.add('$minutes 分');
  if (seconds > 0 || parts.isEmpty) parts.add('$seconds 秒');
  return '${negative ? '负' : ''}${parts.join(' ')}';
}

bool isValidClockPart(int value, {required bool allowAny}) {
  if (value < 0) return false;
  return allowAny || value < 60;
}

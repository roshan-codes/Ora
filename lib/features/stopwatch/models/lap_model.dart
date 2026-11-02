class LapModel {
  final int lapIndex;
  final Duration lapDuration;
  final Duration totalElapsed;
  final Duration? differenceFromPrevious;

  const LapModel({
    required this.lapIndex,
    required this.lapDuration,
    required this.totalElapsed,
    this.differenceFromPrevious,
  });

  String get formattedLapTime => _formatDuration(lapDuration);
  String get formattedTotalTime => _formatDuration(totalElapsed);
  String get formattedDifference {
    if (differenceFromPrevious == null) return '--';
    final diff = differenceFromPrevious!;
    final sign = diff.isNegative ? '-' : '+';
    final abs = diff.abs();
    final ms = (abs.inMilliseconds % 1000) ~/ 10;
    return '$sign${abs.inMinutes.toString().padLeft(2, '0')}:${(abs.inSeconds % 60).toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centiseconds = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    if (d.inHours > 0) {
      final hours = d.inHours.toString();
      return '$hours:$minutes:$seconds.$centiseconds';
    }
    return '$minutes:$seconds.$centiseconds';
  }
}


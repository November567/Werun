/// Formatting helpers for run tracking display values.
/// Extracted from RunTrackingScreen to avoid duplication.

String formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String formatPace(double? pace) {
  if (pace == null) return "--'--\"";
  final min = pace.floor();
  final sec = ((pace - min) * 60).round();
  return "$min'${sec.toString().padLeft(2, '0')}\"";
}

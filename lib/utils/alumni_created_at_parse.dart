/// Parses [AlumniModel.createdAt] values such as `dd-MM-yyyy` into a calendar date.
DateTime? parseAlumniCreatedAtDay(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;

  final parts = s.split(RegExp(r'[-/]'));
  if (parts.length != 3) return null;

  final d = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  final y = int.tryParse(parts[2].trim());
  if (d == null || m == null || y == null) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;

  try {
    return DateTime(y, m, d);
  } catch (_) {
    return null;
  }
}

/// Parses [AlumniModel.createdAt] strings formatted as `dd-MM-yyyy`.
DateTime? parseAlumniCreatedAt(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final parts = s.split('-');
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final y = int.tryParse(parts[2]);
  if (d == null || m == null || y == null) return null;
  try {
    return DateTime(y, m, d);
  } on Object {
    return null;
  }
}

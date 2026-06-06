/// Filter + search state for the alumni directory.
class AlumniDirectoryFilters {
  const AlumniDirectoryFilters({
    this.search = '',
    this.department,
    this.year,
  });

  final String search;
  final String? department;
  final String? year;

  AlumniDirectoryFilters copyWith({
    String? search,
    String? department,
    String? year,
    bool clearDepartment = false,
    bool clearYear = false,
  }) {
    return AlumniDirectoryFilters(
      search: search ?? this.search,
      department: clearDepartment ? null : (department ?? this.department),
      year: clearYear ? null : (year ?? this.year),
    );
  }
}

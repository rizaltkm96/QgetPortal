import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_directory_filters.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/widgets/glass.dart';

class AlumniDirectoryFiltersSheet {
  AlumniDirectoryFiltersSheet._();

  static Future<AlumniDirectoryFilters?> show(
    BuildContext context, {
    required AlumniDirectoryFilters initial,
    required List<String> departments,
    required List<String> years,
  }) {
    return showModalBottomSheet<AlumniDirectoryFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProviderScope(
        overrides: [
          directoryFilterModalInitialProvider.overrideWithValue(initial),
        ],
        child: _AlumniDirectoryFiltersSheetBody(
          departments: departments,
          years: years,
        ),
      ),
    );
  }
}

class _AlumniDirectoryFiltersSheetBody extends ConsumerWidget {
  const _AlumniDirectoryFiltersSheetBody({
    required this.departments,
    required this.years,
  });

  final List<String> departments;
  final List<String> years;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(directoryFilterModalNotifierProvider);
    ref.watch(directoryFilterModalSearchControllerProvider);
    final modal = ref.read(directoryFilterModalNotifierProvider.notifier);
    final searchCtrl = ref.read(directoryFilterModalSearchControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
        top: 8,
      ),
      child: GlassPanel(
        borderRadius: 24,
        strongBlur: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Name, email, company…',
              ),
            ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            key: ValueKey<String?>(draft.department),
            width: MediaQuery.sizeOf(context).width - 40,
            label: const Text('Department'),
            initialSelection: draft.department ?? '',
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: '', label: 'Any department'),
              ...departments.map(
                (d) => DropdownMenuEntry(value: d, label: d),
              ),
            ],
            onSelected: (v) => modal.updateDept(v),
          ),
          const SizedBox(height: 12),
          DropdownMenu<String>(
            key: ValueKey<String?>(draft.year),
            width: MediaQuery.sizeOf(context).width - 40,
            label: const Text('Graduation year'),
            initialSelection: draft.year ?? '',
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: '', label: 'Any year'),
              ...years.map(
                (y) => DropdownMenuEntry(value: y, label: y),
              ),
            ],
            onSelected: (v) => modal.updateYear(v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, const AlumniDirectoryFilters()),
                child: const Text('Clear all'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context, draft),
                child: const Text('Apply'),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

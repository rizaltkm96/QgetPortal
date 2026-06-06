import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_directory_filters.dart';
import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/providers/ui_state_providers.dart';
import 'package:qget_portal/services/alumni_excel_export_service.dart';
import 'package:qget_portal/services/firebase_service.dart';
import 'package:qget_portal/widgets/alumni_card.dart';
import 'package:qget_portal/widgets/alumni_directory_filters_sheet.dart';
import 'package:qget_portal/screens/alumni_profile_screen.dart';
import 'package:qget_portal/screens/alumni_member_form_screen.dart';

class AlumniDirectoryTab extends ConsumerWidget {
  const AlumniDirectoryTab({super.key});

  List<AlumniModel> _visible(
    List<AlumniModel> all,
    AlumniDirectoryFilters filters,
  ) {
    var list = FirebaseService.searchMembers(all, filters.search);
    if (filters.department != null && filters.department!.isNotEmpty) {
      list = list.where((a) => a.branchName == filters.department).toList();
    }
    if (filters.year != null && filters.year!.isNotEmpty) {
      list = list.where((a) => a.year == filters.year).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumniAsync = ref.watch(alumniStreamProvider);
    final filters = ref.watch(alumniDirectoryFiltersProvider);
    final filtersNotifier = ref.read(alumniDirectoryFiltersProvider.notifier);
    final searchCtrl = ref.watch(directorySearchControllerProvider);
    final exporting = ref.watch(alumniDirectoryExportingProvider);

    return alumniAsync.when(
      data: (all) {
        final depts = all
            .map((a) => a.branchName)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final years = all
            .map((a) => a.year)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final visible = _visible(all, filters);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search name, email, company, department…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            searchCtrl.clear();
                            filtersNotifier.setSearchIfChanged('');
                          },
                        ),
                ),
                onChanged: filtersNotifier.setSearchIfChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${visible.length} alumni',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add member',
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const AlumniMemberFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                  ),
                  IconButton(
                    tooltip: 'Filters',
                    onPressed: () async {
                      final next = await AlumniDirectoryFiltersSheet.show(
                        context,
                        initial: filters,
                        departments: depts,
                        years: years,
                      );
                      if (next == null || !context.mounted) return;
                      filtersNotifier.apply(next);
                      if (searchCtrl.text != next.search) {
                        searchCtrl.value = TextEditingValue(
                          text: next.search,
                          selection: TextSelection.collapsed(
                            offset: next.search.length,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.filter_list_rounded),
                  ),
                  IconButton(
                    tooltip: 'Export Excel',
                    onPressed: exporting
                        ? null
                        : () async {
                            ref
                                .read(alumniDirectoryExportingProvider.notifier)
                                .state = true;
                            try {
                              await AlumniExcelExportService.exportMembers(
                                visible,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Export started'),
                                  ),
                                );
                              }
                            } on Object catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Export failed: $e')),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                ref
                                    .read(
                                      alumniDirectoryExportingProvider.notifier,
                                    )
                                    .state = false;
                              }
                            }
                          },
                    icon: exporting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(alumniStreamProvider);
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) {
                    final a = visible[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AlumniCard(
                        alumni: a,
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => AlumniProfileScreen(alumni: a),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Directory error: $e')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_directory_filters.dart';
import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/services/firebase_service.dart';
import 'package:qget_portal/utils/pick_image_file.dart';

// --- Splash ---

final splashNavigationHandledProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// --- Home tabs ---

final homeTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

final homePageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final c = PageController();
  ref.onDispose(c.dispose);
  return c;
});

// --- Alumni directory ---

class AlumniDirectoryFiltersNotifier
    extends Notifier<AlumniDirectoryFilters> {
  @override
  AlumniDirectoryFilters build() => const AlumniDirectoryFilters();

  void setSearchIfChanged(String s) {
    if (state.search == s) return;
    state = state.copyWith(search: s);
  }

  void apply(AlumniDirectoryFilters f) => state = f;
}

final alumniDirectoryFiltersProvider = NotifierProvider<
    AlumniDirectoryFiltersNotifier, AlumniDirectoryFilters>(
  AlumniDirectoryFiltersNotifier.new,
);

final directorySearchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final notifier = ref.read(alumniDirectoryFiltersProvider.notifier);
  final c = TextEditingController(
    text: ref.read(alumniDirectoryFiltersProvider).search,
  );
  ref.listen<AlumniDirectoryFilters>(
    alumniDirectoryFiltersProvider,
    (previous, next) {
      if (previous?.search != next.search && c.text != next.search) {
        c.value = TextEditingValue(
          text: next.search,
          selection: TextSelection.collapsed(offset: next.search.length),
        );
      }
    },
  );
  c.addListener(() {
    final t = c.text;
    final current = ref.read(alumniDirectoryFiltersProvider);
    if (current.search != t) {
      notifier.setSearchIfChanged(t);
    }
  });
  ref.onDispose(c.dispose);
  return c;
});

final alumniDirectoryExportingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// --- Directory filter modal (override initial in ProviderScope) ---

final directoryFilterModalInitialProvider =
    Provider<AlumniDirectoryFilters>((ref) {
  throw StateError(
    'directoryFilterModalInitialProvider must be overridden for the modal',
  );
});

class DirectoryFilterModalNotifier
    extends AutoDisposeNotifier<AlumniDirectoryFilters> {
  @override
  AlumniDirectoryFilters build() =>
      ref.watch(directoryFilterModalInitialProvider);

  void updateSearch(String s) {
    if (state.search == s) return;
    state = state.copyWith(search: s);
  }

  void updateDept(String? v) {
    if (v == null || v.isEmpty) {
      state = state.copyWith(clearDepartment: true);
    } else {
      state = state.copyWith(department: v);
    }
  }

  void updateYear(String? v) {
    if (v == null || v.isEmpty) {
      state = state.copyWith(clearYear: true);
    } else {
      state = state.copyWith(year: v);
    }
  }
}

final directoryFilterModalNotifierProvider = NotifierProvider.autoDispose<
    DirectoryFilterModalNotifier, AlumniDirectoryFilters>(
  DirectoryFilterModalNotifier.new,
);

final directoryFilterModalSearchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final notifier = ref.read(directoryFilterModalNotifierProvider.notifier);
  final c = TextEditingController(
    text: ref.read(directoryFilterModalNotifierProvider).search,
  );
  ref.listen<AlumniDirectoryFilters>(
    directoryFilterModalNotifierProvider,
    (previous, next) {
      if (previous?.search != next.search && c.text != next.search) {
        c.value = TextEditingValue(
          text: next.search,
          selection: TextSelection.collapsed(offset: next.search.length),
        );
      }
    },
  );
  c.addListener(() {
    final t = c.text;
    final current = ref.read(directoryFilterModalNotifierProvider);
    if (current.search != t) {
      notifier.updateSearch(t);
    }
  });
  ref.onDispose(c.dispose);
  return c;
});

// --- Login ---

final loginFormKeyProvider = Provider.autoDispose<GlobalKey<FormState>>(
  (ref) => GlobalKey<FormState>(),
);

final loginEmailControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final loginPasswordControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final loginRegisterModeProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final loginObscurePasswordProvider =
    StateProvider.autoDispose<bool>((ref) => true);

final loginBusyProvider = StateProvider.autoDispose<bool>((ref) => false);

// --- Create post ---

class CreatePostUi {
  const CreatePostUi({this.busy = false});

  final bool busy;
}

class CreatePostNotifier extends AutoDisposeNotifier<CreatePostUi> {
  late final TextEditingController content;
  late final TextEditingController imageUrl;

  @override
  CreatePostUi build() {
    content = TextEditingController();
    imageUrl = TextEditingController();
    ref.onDispose(() {
      content.dispose();
      imageUrl.dispose();
    });
    return const CreatePostUi();
  }

  Future<void> submit(BuildContext context) async {
    final text = content.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something to share')),
      );
      return;
    }
    state = const CreatePostUi(busy: true);
    try {
      await FirebaseService.createPost(
        content: text,
        imageUrl: imageUrl.text.trim(),
      );
      if (context.mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post failed: $e')),
        );
      }
    } finally {
      state = const CreatePostUi();
    }
  }
}

final createPostNotifierProvider =
    NotifierProvider.autoDispose<CreatePostNotifier, CreatePostUi>(
  CreatePostNotifier.new,
);

// --- Add / edit member form ---

final memberFormAlumniProvider = Provider<AlumniModel?>((ref) => null);

final memberFormStandaloneProvider = Provider<bool>((ref) => false);

class MemberFormUi {
  const MemberFormUi({
    this.busy = false,
    this.pickedPhotoLabel,
    this.spouseIsQgetMember,
    this.submitSuccess = false,
    this.submitError,
  });

  final bool busy;
  final String? pickedPhotoLabel;
  final bool? spouseIsQgetMember;
  final bool submitSuccess;
  final String? submitError;
}

class MemberFormNotifier extends AutoDisposeNotifier<MemberFormUi> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController year;
  late final TextEditingController branch;
  late final TextEditingController company;
  late final TextEditingController position;
  late final TextEditingController contact;
  late final TextEditingController whatsapp;
  late final TextEditingController blood;
  late final TextEditingController spouseName;
  late final TextEditingController social;

  String? _pickedPhotoExtension;
  late final TextEditingController efNumber;
  late final TextEditingController child1Name;
  late final TextEditingController child1Dob;
  late final TextEditingController child2Name;
  late final TextEditingController child2Dob;
  late final TextEditingController child3Name;
  late final TextEditingController child3Dob;
  late final TextEditingController child4Name;
  late final TextEditingController child4Dob;

  @override
  MemberFormUi build() {
    final editing = ref.watch(memberFormAlumniProvider);

    name = TextEditingController(text: editing?.memberName ?? '');
    email = TextEditingController(text: editing?.email ?? '');
    year = TextEditingController(text: editing?.year ?? '');
    branch = TextEditingController(text: editing?.branchName ?? '');
    company = TextEditingController(text: editing?.companyName ?? '');
    position = TextEditingController(text: editing?.position ?? '');
    contact = TextEditingController(text: editing?.contactNumber ?? '');
    whatsapp = TextEditingController(text: editing?.whatsappNumber ?? '');
    blood = TextEditingController(text: editing?.bloodGroup ?? '');
    spouseName = TextEditingController(text: editing?.spouseName ?? '');
    social = TextEditingController(text: editing?.socialMediaLink ?? '');
    efNumber = TextEditingController(text: editing?.efNumber ?? '');
    child1Name = TextEditingController(text: editing?.child1Name ?? '');
    child1Dob = TextEditingController(text: editing?.child1Dob ?? '');
    child2Name = TextEditingController(text: editing?.child2Name ?? '');
    child2Dob = TextEditingController(text: editing?.child2Dob ?? '');
    child3Name = TextEditingController(text: editing?.child3Name ?? '');
    child3Dob = TextEditingController(text: editing?.child3Dob ?? '');
    child4Name = TextEditingController(text: editing?.child4Name ?? '');
    child4Dob = TextEditingController(text: editing?.child4Dob ?? '');

    name.addListener(_onFormFieldChanged);

    ref.onDispose(() {
      name.removeListener(_onFormFieldChanged);
      name.dispose();
      email.dispose();
      year.dispose();
      branch.dispose();
      company.dispose();
      position.dispose();
      contact.dispose();
      whatsapp.dispose();
      blood.dispose();
      spouseName.dispose();
      social.dispose();
      efNumber.dispose();
      child1Name.dispose();
      child1Dob.dispose();
      child2Name.dispose();
      child2Dob.dispose();
      child3Name.dispose();
      child3Dob.dispose();
      child4Name.dispose();
      child4Dob.dispose();
    });

    final existingImage = editing?.imageName.trim();
    return MemberFormUi(
      spouseIsQgetMember: editing != null
          ? _spouseFromString(editing.spouseIsMember)
          : null,
      pickedPhotoLabel: existingImage?.isNotEmpty == true
          ? 'Current image: $existingImage'
          : null,
    );
  }

  bool get isEditing => ref.read(memberFormAlumniProvider) != null;

  void _clearControllers() {
    name.clear();
    email.clear();
    year.clear();
    branch.clear();
    company.clear();
    position.clear();
    contact.clear();
    whatsapp.clear();
    blood.clear();
    spouseName.clear();
    social.clear();
    efNumber.clear();
    child1Name.clear();
    child1Dob.clear();
    child2Name.clear();
    child2Dob.clear();
    child3Name.clear();
    child3Dob.clear();
    child4Name.clear();
    child4Dob.clear();
    _pickedPhotoExtension = null;
  }

  void resetStandaloneForm() {
    _clearControllers();
    state = const MemberFormUi();
    formKey.currentState?.reset();
  }

  void _onFormFieldChanged() {
    state = MemberFormUi(
      busy: state.busy,
      pickedPhotoLabel: state.pickedPhotoLabel,
      spouseIsQgetMember: state.spouseIsQgetMember,
      submitSuccess: state.submitSuccess,
      submitError: state.submitError,
    );
  }

  void setSpouseIsQgetMember(bool? value) {
    state = MemberFormUi(
      busy: state.busy,
      pickedPhotoLabel: state.pickedPhotoLabel,
      spouseIsQgetMember: value,
      submitSuccess: state.submitSuccess,
      submitError: state.submitError,
    );
  }

  String? previewImageName() {
    final ext = _pickedPhotoExtension;
    if (ext == null) return null;
    final base = _memberNameForImageFile(name.text.trim());
    if (base.isEmpty) return null;
    return '$base$ext';
  }

  static String _memberNameForImageFile(String memberName) {
    return memberName
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\w]'), '');
  }

  static String _extensionFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) return '.jpg';
    return fileName.substring(dot).toLowerCase();
  }

  static String _formatDob(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d-$m-$y';
  }

  Future<void> pickPhoto(BuildContext context) async {
    try {
      final picked = await pickImageFile();
      if (picked == null) return;

      _pickedPhotoExtension = _extensionFromFileName(picked.name);
      state = MemberFormUi(
        busy: state.busy,
        pickedPhotoLabel: picked.name,
        spouseIsQgetMember: state.spouseIsQgetMember,
        submitSuccess: state.submitSuccess,
        submitError: state.submitError,
      );
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
  }

  Future<void> pickChildDob(BuildContext context, TextEditingController controller) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _parseDob(controller.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      controller.text = _formatDob(picked);
    }
  }

  static DateTime? _parseDob(String raw) {
    final parts = raw.trim().split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  static String _spouseMemberLabel(bool? value) {
    if (value == true) return 'Yes';
    if (value == false) return 'No';
    return '';
  }

  static bool? _spouseFromString(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'yes') return true;
    if (v == 'no') return false;
    return null;
  }

  Map<String, dynamic> _memberPayload({AlumniModel? editing}) {
    final newImageName = previewImageName();
    return <String, dynamic>{
      'Member_Name': name.text.trim(),
      'Email': email.text.trim(),
      'Year': year.text.trim(),
      'Branch_Name': branch.text.trim(),
      'Company_Name': company.text.trim(),
      'Position': position.text.trim(),
      'ImgURL': editing?.imgUrl ?? '',
      'ImageName': newImageName ?? editing?.imageName ?? '',
      'Contact_Number': contact.text.trim(),
      'Whatsapp_Number': whatsapp.text.trim(),
      'Blood_Group': blood.text.trim(),
      'Spouse_Name': spouseName.text.trim(),
      'Spouse_Is_Member': _spouseMemberLabel(state.spouseIsQgetMember),
      'Social_Media_Link': social.text.trim(),
      'EF_Number': efNumber.text.trim(),
      'Child1_Name': child1Name.text.trim(),
      'Child1_DOB': child1Dob.text.trim(),
      'Child2_Name': child2Name.text.trim(),
      'Child2_DOB': child2Dob.text.trim(),
      'Child3_Name': child3Name.text.trim(),
      'Child3_DOB': child3Dob.text.trim(),
      'Child4_Name': child4Name.text.trim(),
      'Child4_DOB': child4Dob.text.trim(),
    };
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    final standalone = ref.read(memberFormStandaloneProvider);
    state = MemberFormUi(
      busy: true,
      pickedPhotoLabel: state.pickedPhotoLabel,
      spouseIsQgetMember: state.spouseIsQgetMember,
    );
    try {
      final editing = ref.read(memberFormAlumniProvider);
      if (editing != null) {
        await FirebaseService.updateMemberProfile(
          editing.id,
          _memberPayload(editing: editing),
        );
      } else {
        final map = _memberPayload();
        map['CreatedAt'] = AlumniModel.createdAtStringNow();
        await FirebaseService.createMember(map);
      }
      if (!context.mounted) return;
      final container = ProviderScope.containerOf(context);
      container.invalidate(alumniStreamProvider);
      container.invalidate(currentAlumniProvider);

      if (standalone) {
        state = const MemberFormUi(submitSuccess: true);
        return;
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editing != null
                  ? 'Member updated'
                  : 'Member added to directory',
            ),
          ),
        );
      }
    } on Object catch (e) {
      if (standalone) {
        state = MemberFormUi(
          submitError: e.toString(),
          pickedPhotoLabel: state.pickedPhotoLabel,
          spouseIsQgetMember: state.spouseIsQgetMember,
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (state.busy) {
        state = MemberFormUi(
          pickedPhotoLabel: state.pickedPhotoLabel,
          spouseIsQgetMember: state.spouseIsQgetMember,
          submitSuccess: state.submitSuccess,
          submitError: state.submitError,
        );
      }
    }
  }
}

final memberFormNotifierProvider =
    NotifierProvider.autoDispose<MemberFormNotifier, MemberFormUi>(
  MemberFormNotifier.new,
  dependencies: [memberFormAlumniProvider, memberFormStandaloneProvider],
);

// --- Edit profile (override alumni in ProviderScope) ---

final editProfileAlumniProvider = Provider<AlumniModel>((ref) {
  throw StateError('editProfileAlumniProvider must be overridden');
});

class EditProfileUi {
  const EditProfileUi({this.busy = false});

  final bool busy;
}

class EditProfileNotifier extends AutoDisposeNotifier<EditProfileUi> {
  late final TextEditingController name;
  late final TextEditingController company;
  late final TextEditingController position;
  late final TextEditingController phone;
  late final TextEditingController img;

  @override
  EditProfileUi build() {
    final a = ref.watch(editProfileAlumniProvider);
    name = TextEditingController(text: a.memberName);
    company = TextEditingController(text: a.companyName);
    position = TextEditingController(text: a.position);
    phone = TextEditingController(text: a.contactNumber);
    img = TextEditingController(text: a.imgUrl);
    ref.onDispose(() {
      name.dispose();
      company.dispose();
      position.dispose();
      phone.dispose();
      img.dispose();
    });
    return const EditProfileUi();
  }

  Future<void> save(BuildContext context) async {
    final id = ref.read(editProfileAlumniProvider).id;
    state = const EditProfileUi(busy: true);
    try {
      await FirebaseService.updateMemberProfile(id, {
        'Member_Name': name.text.trim(),
        'Company_Name': company.text.trim(),
        'Position': position.text.trim(),
        'Contact_Number': phone.text.trim(),
        'ImgURL': img.text.trim(),
      });
      if (context.mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      state = const EditProfileUi();
    }
  }
}

final editProfileNotifierProvider =
    NotifierProvider.autoDispose<EditProfileNotifier, EditProfileUi>(
  EditProfileNotifier.new,
);

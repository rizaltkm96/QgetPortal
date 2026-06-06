import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/models/alumni_directory_filters.dart';
import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/providers/app_providers.dart';
import 'package:qget_portal/services/firebase_service.dart';

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

// --- Add member form ---

class MemberFormUi {
  const MemberFormUi({this.busy = false});

  final bool busy;
}

class MemberFormNotifier extends AutoDisposeNotifier<MemberFormUi> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController year;
  late final TextEditingController branch;
  late final TextEditingController company;
  late final TextEditingController position;
  late final TextEditingController imgUrl;
  late final TextEditingController imageName;
  late final TextEditingController contact;
  late final TextEditingController whatsapp;
  late final TextEditingController blood;
  late final TextEditingController spouseName;
  late final TextEditingController spouseIsMember;
  late final TextEditingController social;
  late final TextEditingController uid;
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
    name = TextEditingController();
    email = TextEditingController();
    year = TextEditingController();
    branch = TextEditingController();
    company = TextEditingController();
    position = TextEditingController();
    imgUrl = TextEditingController();
    imageName = TextEditingController();
    contact = TextEditingController();
    whatsapp = TextEditingController();
    blood = TextEditingController();
    spouseName = TextEditingController();
    spouseIsMember = TextEditingController();
    social = TextEditingController();
    uid = TextEditingController();
    efNumber = TextEditingController();
    child1Name = TextEditingController();
    child1Dob = TextEditingController();
    child2Name = TextEditingController();
    child2Dob = TextEditingController();
    child3Name = TextEditingController();
    child3Dob = TextEditingController();
    child4Name = TextEditingController();
    child4Dob = TextEditingController();

    ref.onDispose(() {
      name.dispose();
      email.dispose();
      year.dispose();
      branch.dispose();
      company.dispose();
      position.dispose();
      imgUrl.dispose();
      imageName.dispose();
      contact.dispose();
      whatsapp.dispose();
      blood.dispose();
      spouseName.dispose();
      spouseIsMember.dispose();
      social.dispose();
      uid.dispose();
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
    return const MemberFormUi();
  }

  static Object? _uidForRtdb(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final n = int.tryParse(t);
    return n ?? t;
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    state = const MemberFormUi(busy: true);
    try {
      final map = <String, dynamic>{
        'Member_Name': name.text.trim(),
        'Email': email.text.trim(),
        'Year': year.text.trim(),
        'Branch_Name': branch.text.trim(),
        'Company_Name': company.text.trim(),
        'Position': position.text.trim(),
        'ImgURL': imgUrl.text.trim(),
        'ImageName': imageName.text.trim(),
        'Contact_Number': contact.text.trim(),
        'Whatsapp_Number': whatsapp.text.trim(),
        'Blood_Group': blood.text.trim(),
        'Spouse_Name': spouseName.text.trim(),
        'Spouse_Is_Member': spouseIsMember.text.trim(),
        'Social_Media_Link': social.text.trim(),
        'UID': _uidForRtdb(uid.text),
        'EF_Number': efNumber.text.trim(),
        'Child1_Name': child1Name.text.trim(),
        'Child1_DOB': child1Dob.text.trim(),
        'Child2_Name': child2Name.text.trim(),
        'Child2_DOB': child2Dob.text.trim(),
        'Child3_Name': child3Name.text.trim(),
        'Child3_DOB': child3Dob.text.trim(),
        'Child4_Name': child4Name.text.trim(),
        'Child4_DOB': child4Dob.text.trim(),
        'CreatedAt': AlumniModel.createdAtStringNow(),
      };
      await FirebaseService.createMember(map);
      ref.invalidate(alumniStreamProvider);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added to directory')),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      state = const MemberFormUi();
    }
  }
}

final memberFormNotifierProvider =
    NotifierProvider.autoDispose<MemberFormNotifier, MemberFormUi>(
  MemberFormNotifier.new,
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

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:qget_portal/models/alumni_model.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.alumni,
    this.radius = 20,
  });

  final AlumniModel alumni;
  final double radius;

  static bool _isFirebaseStorageDownloadUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  @override
  Widget build(BuildContext context) {
    final url = alumni.imgUrl.trim();
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        child: Text(
          alumni.initials,
          style: TextStyle(
            fontSize: radius * 0.55,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (_isFirebaseStorageDownloadUrl(url)) {
      return _StorageBytesAvatar(url: url, radius: radius, alumni: alumni);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(context),
          errorWidget: (_, __, ___) => _initials(context),
        ),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    return Center(
      child: Text(
        alumni.initials,
        style: TextStyle(
          fontSize: radius * 0.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Loads photo bytes via the Firebase Storage SDK (works when HTTP image load fails,
/// e.g. CORS on web for download URLs).
class _StorageBytesAvatar extends StatefulWidget {
  const _StorageBytesAvatar({
    required this.url,
    required this.radius,
    required this.alumni,
  });

  final String url;
  final double radius;
  final AlumniModel alumni;

  @override
  State<_StorageBytesAvatar> createState() => _StorageBytesAvatarState();
}

class _StorageBytesAvatarState extends State<_StorageBytesAvatar> {
  Uint8List? _bytes;
  bool _triedFallback = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.url);
      final data = await ref.getData(20 * 1024 * 1024);
      if (!mounted) return;
      if (data != null && data.isNotEmpty) {
        setState(() => _bytes = data);
      } else {
        setState(() => _triedFallback = true);
      }
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _triedFallback = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    if (_bytes != null && _bytes!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.radius,
        child: ClipOval(
          child: Image.memory(
            _bytes!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _fallback(context),
          ),
        ),
      );
    }
    if (!_triedFallback) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SizedBox(
            width: widget.radius * 0.9,
            height: widget.radius * 0.9,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.url,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(context),
          errorWidget: (_, __, ___) => _initials(context),
        ),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    return Center(
      child: Text(
        widget.alumni.initials,
        style: TextStyle(
          fontSize: widget.radius * 0.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

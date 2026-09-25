import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../widgets.dart';

/// In-app camera with a framing guide. Any lighting and background is accepted; falls back to the
/// system picker when no camera is available. Pops with the photo bytes.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  static Future<Uint8List?> capture(BuildContext context) =>
      Navigator.of(context).push<Uint8List>(MaterialPageRoute(builder: (_) => const CameraScreen(), fullscreenDialog: true));

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _c;
  bool failed = false, busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw StateError('no camera');
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      if (!mounted) return;
      setState(() => _c = c);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    if (_c == null || busy) return;
    setState(() => busy = true);
    try {
      final f = await _c!.takePicture();
      final bytes = await f.readAsBytes();
      if (mounted) Navigator.pop(context, bytes);
    } catch (_) {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _pick(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, maxWidth: 1800, imageQuality: 85);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (mounted) Navigator.pop(context, bytes);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: SS.cream, title: Text(l.takePhoto)),
      body: failed
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                FilledButton.icon(
                    onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: Text(l.takePhoto)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: SS.cream),
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l.addMorePhotos),
                ),
              ]),
            )
          : _c == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(fit: StackFit.expand, children: [
                  Center(child: CameraPreview(_c!)),
                  // framing guide
                  IgnorePointer(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.78,
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: SS.marigold.withValues(alpha: 0.9), width: 3),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Text(l.anyBackground, textAlign: TextAlign.center, style: const TextStyle(color: SS.cream, fontSize: 16)),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      IconButton(
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, color: SS.cream, size: 32),
                      ),
                      GestureDetector(
                        onTap: _shoot,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SS.cream,
                            border: Border.all(color: SS.marigold, width: 5),
                          ),
                          child: busy ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()) : null,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ]),
                  ),
                ]),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../widgets.dart';

/// Pure view of the "Add a Product" screen (mockup screen 2), driven entirely by its inputs.
class CaptureView extends StatelessWidget {
  const CaptureView({
    super.key,
    required this.listening,
    required this.languageName,
    required this.transcript,
    required this.levels,
    required this.photos,
    this.hint,
    this.onMicTap,
    this.onHoldStart,
    this.onHoldEnd,
    this.onTakePhoto,
    this.onSubmit,
    this.onBack,
    this.subtitleOverride,
    this.syncBanner,
  });

  final bool listening;
  final String languageName;
  final String transcript;
  final List<double> levels;
  final List<Uint8List> photos;
  final String? hint;
  final VoidCallback? onMicTap;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onSubmit;
  final VoidCallback? onBack;
  final String? subtitleOverride;
  final Widget? syncBanner;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hasPhoto = photos.isNotEmpty;
    final canSubmit = (transcript.isNotEmpty || hasPhoto) && !listening;
    return Scaffold(
      backgroundColor: SS.tealDeep,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 32),
              child: Column(children: [
                Row(children: [
                  IconButton(
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: SS.cream),
                    tooltip: l.back,
                  ),
                  const Spacer(),
                  if (syncBanner != null) Flexible(flex: 4, child: syncBanner!),
                ]),
                const SizedBox(height: 8),
                Text(l.addProductTitle,
                    style: const TextStyle(fontFamily: SS.poppins, fontSize: 28, fontWeight: FontWeight.w700, color: SS.cream)),
                const SizedBox(height: 4),
                Text(subtitleOverride ?? l.speakOwnLanguage,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: SS.sand)),
                const SizedBox(height: 18),
                MicButton(
                  active: listening,
                  onTap: onMicTap,
                  onHoldStart: onHoldStart,
                  onHoldEnd: onHoldEnd,
                  label: listening ? l.stopRecording : l.tapToSpeak,
                ),
                Waveform(levels: levels, active: listening),
                const SizedBox(height: 6),
                Text(listening ? l.stopRecording : '${l.tapToSpeak} · ${l.upTo60s}',
                    style: TextStyle(color: SS.sand, fontSize: 14)),
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(SS.radius),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.listeningIn(languageName),
                          style: const TextStyle(color: SS.marigold, fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(transcript.isEmpty ? '…' : transcript,
                          style: const TextStyle(color: SS.cream, fontSize: 21, fontWeight: FontWeight.w500, height: 1.35)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(SS.radius),
                  child: InkWell(
                    onTap: onTakePhoto,
                    borderRadius: BorderRadius.circular(SS.radius),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: SS.teal,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: SS.sand.withValues(alpha: 0.5)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasPhoto
                              ? Image.memory(photos.first, fit: BoxFit.cover)
                              : const Icon(Icons.photo_camera_rounded, color: SS.cream, size: 34),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(hasPhoto ? l.photoCaptured : l.takePhoto,
                                style: const TextStyle(color: SS.cream, fontSize: 16, fontWeight: FontWeight.w500, height: 1.35)),
                            if (!hasPhoto)
                              Text(l.anyBackground, style: TextStyle(color: SS.sand, fontSize: 13)),
                            if (hasPhoto && photos.length < 5)
                              Text('${l.addMorePhotos} (${photos.length}/5)', style: TextStyle(color: SS.sand, fontSize: 13)),
                            if (hint != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(hint!, style: const TextStyle(color: SS.marigold, fontSize: 13)),
                              ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: FilledButton.icon(
                    onPressed: canSubmit ? onSubmit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: SS.marigold,
                      foregroundColor: SS.tealDeep,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                      disabledForegroundColor: SS.cream.withValues(alpha: 0.5),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(l.makeListing),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

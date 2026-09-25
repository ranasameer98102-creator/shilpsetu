import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'languages.dart';

/// Why the microphone could not take the user's voice (shown and spoken by the app).
enum VoiceProblem { permission, unavailable, insecure, noSpeech, network }

/// Audio-first I/O: every label can be spoken (TTS), and the artisan can answer by voice (on-device STT
/// where the phone has it; otherwise the recording is transcribed on the server after sync).
class Voice extends ChangeNotifier {
  Voice({FlutterTts? tts, SpeechToText? stt})
      : _tts = tts, // ignore: prefer_initializing_formals
        _stt = stt; // ignore: prefer_initializing_formals

  FlutterTts? _tts;
  SpeechToText? _stt;
  bool sttAvailable = false;
  bool listening = false;
  bool speaking = false;
  String partial = '';
  double level = 0;
  String language = 'hi';

  /// Called whenever the microphone fails, so the app can explain what to do (set once in main/app).
  void Function(VoiceProblem problem)? onProblem;

  /// Android and iOS let only one thing use the microphone at a time: recording and live recognition
  /// cannot run together there (browsers allow it).
  static bool get canRecordWhileListening => kIsWeb;

  List<LocaleName>? _locales;
  void Function(String)? _onFinal;
  bool _finalSent = false;
  bool _retriedLocale = false;

  FlutterTts get tts => _tts ??= FlutterTts();

  /// Browsers only give pages the microphone over https (or on localhost).
  static bool get insecureWeb =>
      kIsWeb && Uri.base.scheme == 'http' && !{'localhost', '127.0.0.1'}.contains(Uri.base.host);

  Future<void> speak(String text, {String? lang}) async {
    if (text.trim().isEmpty) return;
    try {
      final l = languageFor(lang ?? language);
      await tts.stop();
      await tts.setLanguage(l.ttsLocale);
      await tts.setSpeechRate(kIsWeb ? 0.9 : 0.45); // slow and clear
      speaking = true;
      notifyListeners();
      await tts.speak(text);
    } catch (_) {
      // TTS voice for this language may be missing on the device; the text is still on screen.
    } finally {
      speaking = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await tts.stop();
    } catch (_) {}
  }

  void _problem(VoiceProblem p) => onProblem?.call(p);

  /// Sets up speech recognition. Retries on every call until it works (e.g. after the user allows the
  /// microphone), instead of giving up after the first failure.
  Future<bool> initStt({bool quiet = false}) async {
    if (sttAvailable) return true;
    if (insecureWeb) {
      if (!quiet) _problem(VoiceProblem.insecure);
      return false;
    }
    try {
      if (!kIsWeb) {
        // Ask for the microphone first so the permission dialog always appears.
        final rec = AudioRecorder();
        final allowed = await rec.hasPermission();
        await rec.dispose();
        if (!allowed) {
          if (!quiet) _problem(VoiceProblem.permission);
          return false;
        }
      }
      _stt ??= SpeechToText();
      sttAvailable = await _stt!.initialize(onError: _onError, onStatus: _onStatus);
      if (sttAvailable) {
        try {
          _locales = await _stt!.locales();
        } catch (_) {}
      }
    } catch (_) {
      sttAvailable = false;
    }
    if (!sttAvailable && !quiet) _problem(VoiceProblem.unavailable);
    notifyListeners();
    return sttAvailable;
  }

  /// The recogniser locale for [code]: the phone's own entry for that language, else Indian English,
  /// else the phone's default (null).
  String? _localeFor(String code) {
    final want = languageFor(code).sttLocale.split(RegExp('[_-]')).first.toLowerCase();
    final all = _locales ?? const <LocaleName>[];
    if (all.isEmpty) return languageFor(code).sttLocale;
    String? pick(String lang) {
      final same = all.where((l) => l.localeId.toLowerCase().startsWith(lang)).toList();
      if (same.isEmpty) return null;
      return same.firstWhere((l) => l.localeId.toLowerCase().contains('in'), orElse: () => same.first).localeId;
    }

    return pick(want) ?? pick('en') ?? (all.isNotEmpty ? null : languageFor(code).sttLocale);
  }

  void _onStatus(String s) {
    if (s == 'done' || s == 'notListening') _finish();
  }

  void _onError(SpeechRecognitionError e) {
    final m = e.errorMsg.toLowerCase();
    if (m.contains('language') && !_retriedLocale) {
      // This phone cannot recognise the chosen language: try again in its default language.
      _retriedLocale = true;
      _locales = const [];
      _listenNow(null);
      return;
    }
    if (m.contains('permission') || m.contains('not-allowed') || m.contains('audio-capture')) {
      sttAvailable = false;
      _problem(VoiceProblem.permission);
    } else if (m.contains('network') || m.contains('server')) {
      _problem(VoiceProblem.network);
    } else if (m.contains('no_match') || m.contains('no-speech') || m.contains('timeout')) {
      if (partial.trim().isEmpty) _problem(VoiceProblem.noSpeech);
    }
    _finish();
  }

  /// End of a session: if the recogniser never marked a result final, hand over what it heard so far.
  void _finish() {
    if (!listening) return;
    listening = false;
    if (!_finalSent && partial.trim().isNotEmpty) {
      _finalSent = true;
      _onFinal?.call(partial);
    }
    notifyListeners();
  }

  Duration _max = const Duration(seconds: 60);

  Future<void> _listenNow(String? localeId) async {
    await _stt!.listen(
      onResult: (SpeechRecognitionResult r) {
        partial = r.recognizedWords;
        notifyListeners();
        if (r.finalResult && !_finalSent) {
          _finalSent = true;
          _onFinal?.call(r.recognizedWords);
        }
      },
      onSoundLevelChange: (l) {
        level = l;
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: _max,
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      ),
    );
  }

  /// Start live recognition. [onFinal] gets the full transcript once; partial words update [partial].
  /// Returns false when this device cannot recognise speech (the caller may record audio instead).
  Future<bool> listen({String? lang, void Function(String)? onFinal, Duration max = const Duration(seconds: 60),
      bool quiet = false}) async {
    if (!await initStt(quiet: quiet)) return false;
    if (_stt!.isListening) await _stt!.cancel();
    partial = '';
    _onFinal = onFinal;
    _finalSent = false;
    _retriedLocale = false;
    _max = max;
    listening = true;
    notifyListeners();
    try {
      await _listenNow(_localeFor(lang ?? language));
      return true;
    } catch (_) {
      listening = false;
      notifyListeners();
      if (!quiet) _problem(VoiceProblem.unavailable);
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt?.stop();
    } catch (_) {}
    // give the recogniser a moment to deliver the last words, then hand them over
    await Future.delayed(const Duration(milliseconds: 350));
    _finish();
  }
}

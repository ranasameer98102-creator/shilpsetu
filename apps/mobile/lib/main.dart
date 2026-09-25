import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/recorder.dart';
import 'core/session.dart';
import 'core/voice.dart';
import 'offline/database.dart';
import 'offline/media_store.dart';
import 'offline/sync_queue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final session = Session(prefs);
  final db = LocalDb();
  final queue = SyncQueue(db: db, media: MediaStore(db), api: HttpSyncApi(session.api), deviceId: session.deviceId);
  final voice = Voice()..language = session.language;
  await queue.load();

  // Offline-first: resume the upload queue whenever connectivity returns, and every 30 s as a fallback.
  Connectivity().onConnectivityChanged.listen((r) {
    queue.online = !r.contains(ConnectivityResult.none);
    if (queue.online) queue.run();
  });
  Timer.periodic(const Duration(seconds: 30), (_) {
    queue.chunkSize = session.lowData ? 16 * 1024 : 64 * 1024;
    queue.online = true;
    queue.run();
  });
  session.addListener(() => voice.language = session.language);
  unawaited(Future(() async {
    try {
      session.publicConfig = Map<String, dynamic>.from(await session.api.get('/config/public'));
    } catch (_) {} // offline start is fine
  }));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider.value(value: queue),
      ChangeNotifierProvider.value(value: voice),
      ChangeNotifierProvider(create: (_) => VoiceRecorder()),
    ],
    child: const ShilpSetuApp(),
  ));
}

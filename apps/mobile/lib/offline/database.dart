import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// One product captured on the phone (voice + photos + voice answers), waiting to sync.
class Captures extends Table {
  TextColumn get id => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get actAsArtisanId => text().nullable()(); // kiosk: artisan this capture belongs to
  TextColumn get language => text().withDefault(const Constant('hi'))();
  TextColumn get audioRef => text().nullable()();
  TextColumn get photoRefs => text().withDefault(const Constant('[]'))(); // JSON list of media refs
  TextColumn get deviceTranscript => text().nullable()();
  TextColumn get answers => text().withDefault(const Constant('[]'))(); // JSON [{field, text?, ref?}]
  TextColumn get uploads => text().withDefault(const Constant('{}'))(); // JSON ref -> upload id (resumable)
  TextColumn get edits => text().withDefault(const Constant('{}'))(); // artisan edits (device wins)
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  // queued | uploading | processing | needs_review | ready | live | failed
  TextColumn get productId => text().nullable()();
  TextColumn get title => text().nullable()();
  RealColumn get price => real().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Media bytes on platforms without a file system (web kiosk / buyer web).
class MediaBlobs extends Table {
  TextColumn get ref => text()();
  BlobColumn get bytes => blob()();
  TextColumn get contentType => text()();

  @override
  Set<Column> get primaryKey => {ref};
}

@DriftDatabase(tables: [Captures, MediaBlobs])
class LocalDb extends _$LocalDb {
  LocalDb([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'shilpsetu',
              web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
            ));

  @override
  int get schemaVersion => 1;
}

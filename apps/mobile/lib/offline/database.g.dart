// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CapturesTable extends Captures with TableInfo<$CapturesTable, Capture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _actAsArtisanIdMeta = const VerificationMeta(
    'actAsArtisanId',
  );
  @override
  late final GeneratedColumn<String> actAsArtisanId = GeneratedColumn<String>(
    'act_as_artisan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('hi'),
  );
  static const VerificationMeta _audioRefMeta = const VerificationMeta(
    'audioRef',
  );
  @override
  late final GeneratedColumn<String> audioRef = GeneratedColumn<String>(
    'audio_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoRefsMeta = const VerificationMeta(
    'photoRefs',
  );
  @override
  late final GeneratedColumn<String> photoRefs = GeneratedColumn<String>(
    'photo_refs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _deviceTranscriptMeta = const VerificationMeta(
    'deviceTranscript',
  );
  @override
  late final GeneratedColumn<String> deviceTranscript = GeneratedColumn<String>(
    'device_transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _uploadsMeta = const VerificationMeta(
    'uploads',
  );
  @override
  late final GeneratedColumn<String> uploads = GeneratedColumn<String>(
    'uploads',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _editsMeta = const VerificationMeta('edits');
  @override
  late final GeneratedColumn<String> edits = GeneratedColumn<String>(
    'edits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idempotencyKey,
    actAsArtisanId,
    language,
    audioRef,
    photoRefs,
    deviceTranscript,
    answers,
    uploads,
    edits,
    capturedAt,
    status,
    productId,
    title,
    price,
    attempts,
    nextAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Capture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('act_as_artisan_id')) {
      context.handle(
        _actAsArtisanIdMeta,
        actAsArtisanId.isAcceptableOrUnknown(
          data['act_as_artisan_id']!,
          _actAsArtisanIdMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('audio_ref')) {
      context.handle(
        _audioRefMeta,
        audioRef.isAcceptableOrUnknown(data['audio_ref']!, _audioRefMeta),
      );
    }
    if (data.containsKey('photo_refs')) {
      context.handle(
        _photoRefsMeta,
        photoRefs.isAcceptableOrUnknown(data['photo_refs']!, _photoRefsMeta),
      );
    }
    if (data.containsKey('device_transcript')) {
      context.handle(
        _deviceTranscriptMeta,
        deviceTranscript.isAcceptableOrUnknown(
          data['device_transcript']!,
          _deviceTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    }
    if (data.containsKey('uploads')) {
      context.handle(
        _uploadsMeta,
        uploads.isAcceptableOrUnknown(data['uploads']!, _uploadsMeta),
      );
    }
    if (data.containsKey('edits')) {
      context.handle(
        _editsMeta,
        edits.isAcceptableOrUnknown(data['edits']!, _editsMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Capture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Capture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      actAsArtisanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}act_as_artisan_id'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      audioRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_ref'],
      ),
      photoRefs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_refs'],
      )!,
      deviceTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_transcript'],
      ),
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      uploads: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploads'],
      )!,
      edits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edits'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $CapturesTable createAlias(String alias) {
    return $CapturesTable(attachedDatabase, alias);
  }
}

class Capture extends DataClass implements Insertable<Capture> {
  final String id;
  final String idempotencyKey;
  final String? actAsArtisanId;
  final String language;
  final String? audioRef;
  final String photoRefs;
  final String? deviceTranscript;
  final String answers;
  final String uploads;
  final String edits;
  final DateTime capturedAt;
  final String status;
  final String? productId;
  final String? title;
  final double? price;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;
  const Capture({
    required this.id,
    required this.idempotencyKey,
    this.actAsArtisanId,
    required this.language,
    this.audioRef,
    required this.photoRefs,
    this.deviceTranscript,
    required this.answers,
    required this.uploads,
    required this.edits,
    required this.capturedAt,
    required this.status,
    this.productId,
    this.title,
    this.price,
    required this.attempts,
    this.nextAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || actAsArtisanId != null) {
      map['act_as_artisan_id'] = Variable<String>(actAsArtisanId);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || audioRef != null) {
      map['audio_ref'] = Variable<String>(audioRef);
    }
    map['photo_refs'] = Variable<String>(photoRefs);
    if (!nullToAbsent || deviceTranscript != null) {
      map['device_transcript'] = Variable<String>(deviceTranscript);
    }
    map['answers'] = Variable<String>(answers);
    map['uploads'] = Variable<String>(uploads);
    map['edits'] = Variable<String>(edits);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  CapturesCompanion toCompanion(bool nullToAbsent) {
    return CapturesCompanion(
      id: Value(id),
      idempotencyKey: Value(idempotencyKey),
      actAsArtisanId: actAsArtisanId == null && nullToAbsent
          ? const Value.absent()
          : Value(actAsArtisanId),
      language: Value(language),
      audioRef: audioRef == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRef),
      photoRefs: Value(photoRefs),
      deviceTranscript: deviceTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceTranscript),
      answers: Value(answers),
      uploads: Value(uploads),
      edits: Value(edits),
      capturedAt: Value(capturedAt),
      status: Value(status),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory Capture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Capture(
      id: serializer.fromJson<String>(json['id']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      actAsArtisanId: serializer.fromJson<String?>(json['actAsArtisanId']),
      language: serializer.fromJson<String>(json['language']),
      audioRef: serializer.fromJson<String?>(json['audioRef']),
      photoRefs: serializer.fromJson<String>(json['photoRefs']),
      deviceTranscript: serializer.fromJson<String?>(json['deviceTranscript']),
      answers: serializer.fromJson<String>(json['answers']),
      uploads: serializer.fromJson<String>(json['uploads']),
      edits: serializer.fromJson<String>(json['edits']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      status: serializer.fromJson<String>(json['status']),
      productId: serializer.fromJson<String?>(json['productId']),
      title: serializer.fromJson<String?>(json['title']),
      price: serializer.fromJson<double?>(json['price']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'actAsArtisanId': serializer.toJson<String?>(actAsArtisanId),
      'language': serializer.toJson<String>(language),
      'audioRef': serializer.toJson<String?>(audioRef),
      'photoRefs': serializer.toJson<String>(photoRefs),
      'deviceTranscript': serializer.toJson<String?>(deviceTranscript),
      'answers': serializer.toJson<String>(answers),
      'uploads': serializer.toJson<String>(uploads),
      'edits': serializer.toJson<String>(edits),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'status': serializer.toJson<String>(status),
      'productId': serializer.toJson<String?>(productId),
      'title': serializer.toJson<String?>(title),
      'price': serializer.toJson<double?>(price),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  Capture copyWith({
    String? id,
    String? idempotencyKey,
    Value<String?> actAsArtisanId = const Value.absent(),
    String? language,
    Value<String?> audioRef = const Value.absent(),
    String? photoRefs,
    Value<String?> deviceTranscript = const Value.absent(),
    String? answers,
    String? uploads,
    String? edits,
    DateTime? capturedAt,
    String? status,
    Value<String?> productId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<double?> price = const Value.absent(),
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => Capture(
    id: id ?? this.id,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    actAsArtisanId: actAsArtisanId.present
        ? actAsArtisanId.value
        : this.actAsArtisanId,
    language: language ?? this.language,
    audioRef: audioRef.present ? audioRef.value : this.audioRef,
    photoRefs: photoRefs ?? this.photoRefs,
    deviceTranscript: deviceTranscript.present
        ? deviceTranscript.value
        : this.deviceTranscript,
    answers: answers ?? this.answers,
    uploads: uploads ?? this.uploads,
    edits: edits ?? this.edits,
    capturedAt: capturedAt ?? this.capturedAt,
    status: status ?? this.status,
    productId: productId.present ? productId.value : this.productId,
    title: title.present ? title.value : this.title,
    price: price.present ? price.value : this.price,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  Capture copyWithCompanion(CapturesCompanion data) {
    return Capture(
      id: data.id.present ? data.id.value : this.id,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      actAsArtisanId: data.actAsArtisanId.present
          ? data.actAsArtisanId.value
          : this.actAsArtisanId,
      language: data.language.present ? data.language.value : this.language,
      audioRef: data.audioRef.present ? data.audioRef.value : this.audioRef,
      photoRefs: data.photoRefs.present ? data.photoRefs.value : this.photoRefs,
      deviceTranscript: data.deviceTranscript.present
          ? data.deviceTranscript.value
          : this.deviceTranscript,
      answers: data.answers.present ? data.answers.value : this.answers,
      uploads: data.uploads.present ? data.uploads.value : this.uploads,
      edits: data.edits.present ? data.edits.value : this.edits,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      status: data.status.present ? data.status.value : this.status,
      productId: data.productId.present ? data.productId.value : this.productId,
      title: data.title.present ? data.title.value : this.title,
      price: data.price.present ? data.price.value : this.price,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Capture(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('actAsArtisanId: $actAsArtisanId, ')
          ..write('language: $language, ')
          ..write('audioRef: $audioRef, ')
          ..write('photoRefs: $photoRefs, ')
          ..write('deviceTranscript: $deviceTranscript, ')
          ..write('answers: $answers, ')
          ..write('uploads: $uploads, ')
          ..write('edits: $edits, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('status: $status, ')
          ..write('productId: $productId, ')
          ..write('title: $title, ')
          ..write('price: $price, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idempotencyKey,
    actAsArtisanId,
    language,
    audioRef,
    photoRefs,
    deviceTranscript,
    answers,
    uploads,
    edits,
    capturedAt,
    status,
    productId,
    title,
    price,
    attempts,
    nextAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Capture &&
          other.id == this.id &&
          other.idempotencyKey == this.idempotencyKey &&
          other.actAsArtisanId == this.actAsArtisanId &&
          other.language == this.language &&
          other.audioRef == this.audioRef &&
          other.photoRefs == this.photoRefs &&
          other.deviceTranscript == this.deviceTranscript &&
          other.answers == this.answers &&
          other.uploads == this.uploads &&
          other.edits == this.edits &&
          other.capturedAt == this.capturedAt &&
          other.status == this.status &&
          other.productId == this.productId &&
          other.title == this.title &&
          other.price == this.price &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError);
}

class CapturesCompanion extends UpdateCompanion<Capture> {
  final Value<String> id;
  final Value<String> idempotencyKey;
  final Value<String?> actAsArtisanId;
  final Value<String> language;
  final Value<String?> audioRef;
  final Value<String> photoRefs;
  final Value<String?> deviceTranscript;
  final Value<String> answers;
  final Value<String> uploads;
  final Value<String> edits;
  final Value<DateTime> capturedAt;
  final Value<String> status;
  final Value<String?> productId;
  final Value<String?> title;
  final Value<double?> price;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const CapturesCompanion({
    this.id = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.actAsArtisanId = const Value.absent(),
    this.language = const Value.absent(),
    this.audioRef = const Value.absent(),
    this.photoRefs = const Value.absent(),
    this.deviceTranscript = const Value.absent(),
    this.answers = const Value.absent(),
    this.uploads = const Value.absent(),
    this.edits = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.productId = const Value.absent(),
    this.title = const Value.absent(),
    this.price = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapturesCompanion.insert({
    required String id,
    required String idempotencyKey,
    this.actAsArtisanId = const Value.absent(),
    this.language = const Value.absent(),
    this.audioRef = const Value.absent(),
    this.photoRefs = const Value.absent(),
    this.deviceTranscript = const Value.absent(),
    this.answers = const Value.absent(),
    this.uploads = const Value.absent(),
    this.edits = const Value.absent(),
    required DateTime capturedAt,
    this.status = const Value.absent(),
    this.productId = const Value.absent(),
    this.title = const Value.absent(),
    this.price = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       idempotencyKey = Value(idempotencyKey),
       capturedAt = Value(capturedAt);
  static Insertable<Capture> custom({
    Expression<String>? id,
    Expression<String>? idempotencyKey,
    Expression<String>? actAsArtisanId,
    Expression<String>? language,
    Expression<String>? audioRef,
    Expression<String>? photoRefs,
    Expression<String>? deviceTranscript,
    Expression<String>? answers,
    Expression<String>? uploads,
    Expression<String>? edits,
    Expression<DateTime>? capturedAt,
    Expression<String>? status,
    Expression<String>? productId,
    Expression<String>? title,
    Expression<double>? price,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (actAsArtisanId != null) 'act_as_artisan_id': actAsArtisanId,
      if (language != null) 'language': language,
      if (audioRef != null) 'audio_ref': audioRef,
      if (photoRefs != null) 'photo_refs': photoRefs,
      if (deviceTranscript != null) 'device_transcript': deviceTranscript,
      if (answers != null) 'answers': answers,
      if (uploads != null) 'uploads': uploads,
      if (edits != null) 'edits': edits,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (status != null) 'status': status,
      if (productId != null) 'product_id': productId,
      if (title != null) 'title': title,
      if (price != null) 'price': price,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapturesCompanion copyWith({
    Value<String>? id,
    Value<String>? idempotencyKey,
    Value<String?>? actAsArtisanId,
    Value<String>? language,
    Value<String?>? audioRef,
    Value<String>? photoRefs,
    Value<String?>? deviceTranscript,
    Value<String>? answers,
    Value<String>? uploads,
    Value<String>? edits,
    Value<DateTime>? capturedAt,
    Value<String>? status,
    Value<String?>? productId,
    Value<String?>? title,
    Value<double?>? price,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return CapturesCompanion(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      actAsArtisanId: actAsArtisanId ?? this.actAsArtisanId,
      language: language ?? this.language,
      audioRef: audioRef ?? this.audioRef,
      photoRefs: photoRefs ?? this.photoRefs,
      deviceTranscript: deviceTranscript ?? this.deviceTranscript,
      answers: answers ?? this.answers,
      uploads: uploads ?? this.uploads,
      edits: edits ?? this.edits,
      capturedAt: capturedAt ?? this.capturedAt,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (actAsArtisanId.present) {
      map['act_as_artisan_id'] = Variable<String>(actAsArtisanId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (audioRef.present) {
      map['audio_ref'] = Variable<String>(audioRef.value);
    }
    if (photoRefs.present) {
      map['photo_refs'] = Variable<String>(photoRefs.value);
    }
    if (deviceTranscript.present) {
      map['device_transcript'] = Variable<String>(deviceTranscript.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (uploads.present) {
      map['uploads'] = Variable<String>(uploads.value);
    }
    if (edits.present) {
      map['edits'] = Variable<String>(edits.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturesCompanion(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('actAsArtisanId: $actAsArtisanId, ')
          ..write('language: $language, ')
          ..write('audioRef: $audioRef, ')
          ..write('photoRefs: $photoRefs, ')
          ..write('deviceTranscript: $deviceTranscript, ')
          ..write('answers: $answers, ')
          ..write('uploads: $uploads, ')
          ..write('edits: $edits, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('status: $status, ')
          ..write('productId: $productId, ')
          ..write('title: $title, ')
          ..write('price: $price, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaBlobsTable extends MediaBlobs
    with TableInfo<$MediaBlobsTable, MediaBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ref, bytes, contentType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ref};
  @override
  MediaBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaBlob(
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
    );
  }

  @override
  $MediaBlobsTable createAlias(String alias) {
    return $MediaBlobsTable(attachedDatabase, alias);
  }
}

class MediaBlob extends DataClass implements Insertable<MediaBlob> {
  final String ref;
  final Uint8List bytes;
  final String contentType;
  const MediaBlob({
    required this.ref,
    required this.bytes,
    required this.contentType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ref'] = Variable<String>(ref);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['content_type'] = Variable<String>(contentType);
    return map;
  }

  MediaBlobsCompanion toCompanion(bool nullToAbsent) {
    return MediaBlobsCompanion(
      ref: Value(ref),
      bytes: Value(bytes),
      contentType: Value(contentType),
    );
  }

  factory MediaBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaBlob(
      ref: serializer.fromJson<String>(json['ref']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      contentType: serializer.fromJson<String>(json['contentType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ref': serializer.toJson<String>(ref),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'contentType': serializer.toJson<String>(contentType),
    };
  }

  MediaBlob copyWith({String? ref, Uint8List? bytes, String? contentType}) =>
      MediaBlob(
        ref: ref ?? this.ref,
        bytes: bytes ?? this.bytes,
        contentType: contentType ?? this.contentType,
      );
  MediaBlob copyWithCompanion(MediaBlobsCompanion data) {
    return MediaBlob(
      ref: data.ref.present ? data.ref.value : this.ref,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaBlob(')
          ..write('ref: $ref, ')
          ..write('bytes: $bytes, ')
          ..write('contentType: $contentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ref, $driftBlobEquality.hash(bytes), contentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaBlob &&
          other.ref == this.ref &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.contentType == this.contentType);
}

class MediaBlobsCompanion extends UpdateCompanion<MediaBlob> {
  final Value<String> ref;
  final Value<Uint8List> bytes;
  final Value<String> contentType;
  final Value<int> rowid;
  const MediaBlobsCompanion({
    this.ref = const Value.absent(),
    this.bytes = const Value.absent(),
    this.contentType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaBlobsCompanion.insert({
    required String ref,
    required Uint8List bytes,
    required String contentType,
    this.rowid = const Value.absent(),
  }) : ref = Value(ref),
       bytes = Value(bytes),
       contentType = Value(contentType);
  static Insertable<MediaBlob> custom({
    Expression<String>? ref,
    Expression<Uint8List>? bytes,
    Expression<String>? contentType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ref != null) 'ref': ref,
      if (bytes != null) 'bytes': bytes,
      if (contentType != null) 'content_type': contentType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaBlobsCompanion copyWith({
    Value<String>? ref,
    Value<Uint8List>? bytes,
    Value<String>? contentType,
    Value<int>? rowid,
  }) {
    return MediaBlobsCompanion(
      ref: ref ?? this.ref,
      bytes: bytes ?? this.bytes,
      contentType: contentType ?? this.contentType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaBlobsCompanion(')
          ..write('ref: $ref, ')
          ..write('bytes: $bytes, ')
          ..write('contentType: $contentType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $CapturesTable captures = $CapturesTable(this);
  late final $MediaBlobsTable mediaBlobs = $MediaBlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [captures, mediaBlobs];
}

typedef $$CapturesTableCreateCompanionBuilder = CapturesCompanion Function({
  required String id,
  required String idempotencyKey,
  Value<String?> actAsArtisanId,
  Value<String> language,
  Value<String?> audioRef,
  Value<String> photoRefs,
  Value<String?> deviceTranscript,
  Value<String> answers,
  Value<String> uploads,
  Value<String> edits,
  required DateTime capturedAt,
  Value<String> status,
  Value<String?> productId,
  Value<String?> title,
  Value<double?> price,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$CapturesTableUpdateCompanionBuilder = CapturesCompanion Function({
  Value<String> id,
  Value<String> idempotencyKey,
  Value<String?> actAsArtisanId,
  Value<String> language,
  Value<String?> audioRef,
  Value<String> photoRefs,
  Value<String?> deviceTranscript,
  Value<String> answers,
  Value<String> uploads,
  Value<String> edits,
  Value<DateTime> capturedAt,
  Value<String> status,
  Value<String?> productId,
  Value<String?> title,
  Value<double?> price,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$CapturesTableFilterComposer
    extends Composer<_$LocalDb, $CapturesTable> {
  $$CapturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actAsArtisanId => $composableBuilder(
    column: $table.actAsArtisanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioRef => $composableBuilder(
    column: $table.audioRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoRefs => $composableBuilder(
    column: $table.photoRefs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceTranscript => $composableBuilder(
    column: $table.deviceTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploads => $composableBuilder(
    column: $table.uploads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get edits => $composableBuilder(
    column: $table.edits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapturesTableOrderingComposer
    extends Composer<_$LocalDb, $CapturesTable> {
  $$CapturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actAsArtisanId => $composableBuilder(
    column: $table.actAsArtisanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioRef => $composableBuilder(
    column: $table.audioRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoRefs => $composableBuilder(
    column: $table.photoRefs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceTranscript => $composableBuilder(
    column: $table.deviceTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploads => $composableBuilder(
    column: $table.uploads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get edits => $composableBuilder(
    column: $table.edits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapturesTableAnnotationComposer
    extends Composer<_$LocalDb, $CapturesTable> {
  $$CapturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actAsArtisanId => $composableBuilder(
    column: $table.actAsArtisanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get audioRef =>
      $composableBuilder(column: $table.audioRef, builder: (column) => column);

  GeneratedColumn<String> get photoRefs =>
      $composableBuilder(column: $table.photoRefs, builder: (column) => column);

  GeneratedColumn<String> get deviceTranscript => $composableBuilder(
    column: $table.deviceTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<String> get uploads =>
      $composableBuilder(column: $table.uploads, builder: (column) => column);

  GeneratedColumn<String> get edits =>
      $composableBuilder(column: $table.edits, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$CapturesTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $CapturesTable,
          Capture,
          $$CapturesTableFilterComposer,
          $$CapturesTableOrderingComposer,
          $$CapturesTableAnnotationComposer,
          $$CapturesTableCreateCompanionBuilder,
          $$CapturesTableUpdateCompanionBuilder,
          (Capture, BaseReferences<_$LocalDb, $CapturesTable, Capture>),
          Capture,
          PrefetchHooks Function()
        > {
  $$CapturesTableTableManager(_$LocalDb db, $CapturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String?> actAsArtisanId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> audioRef = const Value.absent(),
                Value<String> photoRefs = const Value.absent(),
                Value<String?> deviceTranscript = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<String> uploads = const Value.absent(),
                Value<String> edits = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapturesCompanion(
                id: id,
                idempotencyKey: idempotencyKey,
                actAsArtisanId: actAsArtisanId,
                language: language,
                audioRef: audioRef,
                photoRefs: photoRefs,
                deviceTranscript: deviceTranscript,
                answers: answers,
                uploads: uploads,
                edits: edits,
                capturedAt: capturedAt,
                status: status,
                productId: productId,
                title: title,
                price: price,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String idempotencyKey,
                Value<String?> actAsArtisanId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> audioRef = const Value.absent(),
                Value<String> photoRefs = const Value.absent(),
                Value<String?> deviceTranscript = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<String> uploads = const Value.absent(),
                Value<String> edits = const Value.absent(),
                required DateTime capturedAt,
                Value<String> status = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapturesCompanion.insert(
                id: id,
                idempotencyKey: idempotencyKey,
                actAsArtisanId: actAsArtisanId,
                language: language,
                audioRef: audioRef,
                photoRefs: photoRefs,
                deviceTranscript: deviceTranscript,
                answers: answers,
                uploads: uploads,
                edits: edits,
                capturedAt: capturedAt,
                status: status,
                productId: productId,
                title: title,
                price: price,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CapturesTable, Capture>(table),
                  BaseReferences<_$LocalDb, $CapturesTable, Capture>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapturesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $CapturesTable,
      Capture,
      $$CapturesTableFilterComposer,
      $$CapturesTableOrderingComposer,
      $$CapturesTableAnnotationComposer,
      $$CapturesTableCreateCompanionBuilder,
      $$CapturesTableUpdateCompanionBuilder,
      (Capture, BaseReferences<_$LocalDb, $CapturesTable, Capture>),
      Capture,
      PrefetchHooks Function()
    >;
typedef $$MediaBlobsTableCreateCompanionBuilder = MediaBlobsCompanion Function({
  required String ref,
  required Uint8List bytes,
  required String contentType,
  Value<int> rowid,
});
typedef $$MediaBlobsTableUpdateCompanionBuilder = MediaBlobsCompanion Function({
  Value<String> ref,
  Value<Uint8List> bytes,
  Value<String> contentType,
  Value<int> rowid,
});

class $$MediaBlobsTableFilterComposer
    extends Composer<_$LocalDb, $MediaBlobsTable> {
  $$MediaBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaBlobsTableOrderingComposer
    extends Composer<_$LocalDb, $MediaBlobsTable> {
  $$MediaBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaBlobsTableAnnotationComposer
    extends Composer<_$LocalDb, $MediaBlobsTable> {
  $$MediaBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );
}

class $$MediaBlobsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $MediaBlobsTable,
          MediaBlob,
          $$MediaBlobsTableFilterComposer,
          $$MediaBlobsTableOrderingComposer,
          $$MediaBlobsTableAnnotationComposer,
          $$MediaBlobsTableCreateCompanionBuilder,
          $$MediaBlobsTableUpdateCompanionBuilder,
          (MediaBlob, BaseReferences<_$LocalDb, $MediaBlobsTable, MediaBlob>),
          MediaBlob,
          PrefetchHooks Function()
        > {
  $$MediaBlobsTableTableManager(_$LocalDb db, $MediaBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ref = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaBlobsCompanion(
                ref: ref,
                bytes: bytes,
                contentType: contentType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ref,
                required Uint8List bytes,
                required String contentType,
                Value<int> rowid = const Value.absent(),
              }) => MediaBlobsCompanion.insert(
                ref: ref,
                bytes: bytes,
                contentType: contentType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaBlobsTable, MediaBlob>(table),
                  BaseReferences<_$LocalDb, $MediaBlobsTable, MediaBlob>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $MediaBlobsTable,
      MediaBlob,
      $$MediaBlobsTableFilterComposer,
      $$MediaBlobsTableOrderingComposer,
      $$MediaBlobsTableAnnotationComposer,
      $$MediaBlobsTableCreateCompanionBuilder,
      $$MediaBlobsTableUpdateCompanionBuilder,
      (MediaBlob, BaseReferences<_$LocalDb, $MediaBlobsTable, MediaBlob>),
      MediaBlob,
      PrefetchHooks Function()
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$CapturesTableTableManager get captures =>
      $$CapturesTableTableManager(_db, _db.captures);
  $$MediaBlobsTableTableManager get mediaBlobs =>
      $$MediaBlobsTableTableManager(_db, _db.mediaBlobs);
}

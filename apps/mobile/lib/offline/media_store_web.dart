import 'database.dart';
import 'media_store.dart';

MediaStore create(LocalDb db) => BlobMediaStore(db);

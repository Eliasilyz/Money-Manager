import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase not initialized');
});
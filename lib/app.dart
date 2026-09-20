import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/features/settings/application/backup_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase not initialized');
});

final backupServiceProvider = Provider<BackupService>((ref) => const BackupService());
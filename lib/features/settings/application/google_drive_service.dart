import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:money_manager/l10n/l10n_loader.dart';

class DriveBackupFile {
  final String id;
  final String name;
  final DateTime createdTime;
  final int size;
  final bool isAutoBackup;

  const DriveBackupFile({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.size,
    required this.isAutoBackup,
  });

  factory DriveBackupFile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'backup.json';
    final created = json['createdTime'] != null
        ? DateTime.tryParse(json['createdTime'] as String)?.toLocal() ?? DateTime.now()
        : DateTime.now();
    final size = int.tryParse(json['size']?.toString() ?? '0') ?? 0;
    final isAuto = name.contains('auto') || (json['properties']?['isAutoBackup'] == 'true');
    return DriveBackupFile(
      id: json['id'] as String? ?? '',
      name: name,
      createdTime: created,
      size: size,
      isAutoBackup: isAuto,
    );
  }
}

class GoogleDriveService {
  static const String _driveApiUrl = 'https://www.googleapis.com/drive/v3/files';
  static const String _uploadApiUrl = 'https://www.googleapis.com/upload/drive/v3/files';

  const GoogleDriveService();

  /// Uploads a backup byte payload to Google Drive (in appDataFolder or Drive root/app folder).
  Future<DriveBackupFile> uploadBackup({
    required Map<String, String> authHeaders,
    required List<int> bytes,
    required String fileName,
    bool isAutoBackup = false,
  }) async {
    final boundary = '----MoneyManagerBoundary${DateTime.now().millisecondsSinceEpoch}';

    final metadata = {
      'name': fileName,
      'parents': ['appDataFolder'],
      'description': 'Money Manager App Backup',
      'properties': {
        'app': 'money_manager',
        'isAutoBackup': isAutoBackup ? 'true' : 'false',
      },
    };

    final metadataJson = jsonEncode(metadata);
    final mimeType = fileName.endsWith('.gz') ? 'application/gzip' : 'application/json';

    final List<int> body = [];

    // Metadata part
    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'));
    body.addAll(utf8.encode('$metadataJson\r\n'));

    // Media part
    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
    body.addAll(bytes);
    body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final headers = Map<String, String>.from(authHeaders);
    headers['Content-Type'] = 'multipart/related; boundary=$boundary';
    headers['Content-Length'] = body.length.toString();

    final response = await http.post(
      Uri.parse('$_uploadApiUrl?uploadType=multipart'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DriveBackupFile.fromJson(json);
    } else {
      debugPrint('Drive Upload Error [${response.statusCode}]: ${response.body}');
      throw Exception((await loadAppL10n()).driveUploadFailed(response.statusCode));
    }
  }

  /// Lists all backup files found in appDataFolder or drive spaces.
  Future<List<DriveBackupFile>> listBackups(Map<String, String> authHeaders) async {
    const query = "name contains 'money_manager_backup' and trashed = false";
    final uri = Uri.parse(
      '$_driveApiUrl?spaces=appDataFolder,drive&q=${Uri.encodeComponent(query)}&fields=files(id,name,mimeType,createdTime,size,properties)&orderBy=createdTime desc',
    );

    final response = await http.get(uri, headers: authHeaders);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final filesList = json['files'] as List? ?? [];
      return filesList.map((f) => DriveBackupFile.fromJson(f as Map<String, dynamic>)).toList();
    } else {
      debugPrint('Drive List Error [${response.statusCode}]: ${response.body}');
      throw Exception((await loadAppL10n()).driveListFailed(response.statusCode));
    }
  }

  /// Downloads raw byte content of a backup file by ID.
  Future<List<int>> downloadBackup({
    required Map<String, String> authHeaders,
    required String fileId,
  }) async {
    final uri = Uri.parse('$_driveApiUrl/$fileId?alt=media');
    final response = await http.get(uri, headers: authHeaders);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      debugPrint('Drive Download Error [${response.statusCode}]: ${response.body}');
      throw Exception((await loadAppL10n()).driveDownloadFailed(response.statusCode));
    }
  }

  /// Deletes a file from Google Drive by ID.
  Future<void> deleteBackup({
    required Map<String, String> authHeaders,
    required String fileId,
  }) async {
    final uri = Uri.parse('$_driveApiUrl/$fileId');
    final response = await http.delete(uri, headers: authHeaders);

    if (response.statusCode != 200 && response.statusCode != 204) {
      debugPrint('Drive Delete Error [${response.statusCode}]: ${response.body}');
      throw Exception((await loadAppL10n()).driveDeleteFailed(response.statusCode));
    }
  }

  /// Trims old auto-backups on Google Drive beyond `maxKeep` count.
  Future<void> trimOldAutoBackups({
    required Map<String, String> authHeaders,
    int maxKeep = 5,
  }) async {
    try {
      final all = await listBackups(authHeaders);
      final autoBackups = all.where((b) => b.isAutoBackup).toList();
      if (autoBackups.length > maxKeep) {
        // Oldest auto backups at the end of the list (since ordered by createdTime desc)
        final toDelete = autoBackups.sublist(maxKeep);
        for (final file in toDelete) {
          await deleteBackup(authHeaders: authHeaders, fileId: file.id);
        }
      }
    } catch (e) {
      debugPrint('Trim old auto backups error: $e');
    }
  }

  /// Computes total storage size occupied by Money Manager backups on Drive.
  Future<int> getTotalBackupBytes(Map<String, String> authHeaders) async {
    try {
      final backups = await listBackups(authHeaders);
      return backups.fold<int>(0, (sum, f) => sum + f.size);
    } catch (e) {
      return 0;
    }
  }
}

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) => const GoogleDriveService());

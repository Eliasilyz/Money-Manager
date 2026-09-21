import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/features/settings/application/backup_service.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  List<FileSystemEntity> _backupFiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<Directory> _backupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backups');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final dir = await _backupDir();
    final files = await dir.list().toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (!mounted) return;
    setState(() {
      _backupFiles = files;
      _loading = false;
    });
  }

  Future<void> _exportBackup() async {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final service = ref.read(backupServiceProvider);

    String? password;
    await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(l10n.backupNow, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            style: GoogleFonts.inter(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.passwordRequired,
              hintText: l10n.encryptBackup,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, ''), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.isEmpty ? null : ctrl.text),
              child: Text(l10n.encryptBackup, style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    ).then((pw) async {
      if (pw == null) return;
      password = pw;

      final dir = await _backupDir();
      final name = '${AppConstants.backupFileName.split('.json').first}-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}.json';
      final raw = await service.generateBackup(db, password: password);
      final file = File('${dir.path}/$name');
      await file.writeAsString(raw);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text('${l10n.backupNow}: $name', style: GoogleFonts.inter(fontSize: 13)),
          ]),
          duration: const Duration(seconds: 4),
        ),
      );
      await _refresh();
    });
  }

  Future<void> _importBackup(File file) async {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final service = ref.read(backupServiceProvider);

    final raw = await file.readAsString();
    if (!mounted) return;

    Map<String, List<Map<String, dynamic>>> data;
    bool encrypted = raw.contains('"format": "encrypted_backup"');
    try {
      data = service.parseBackup(raw);
    } on BackupException catch (e) {
      if (!encrypted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message, style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
        );
        return;
      }
      String? pw;
      await showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(l10n.backupRestore, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            content: TextField(
              controller: ctrl,
              obscureText: true,
              style: GoogleFonts.inter(color: colors.textPrimary),
              decoration: InputDecoration(labelText: l10n.passwordRequired),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
              TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(l10n.restore, style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600))),
            ],
          );
        },
      ).then((value) => pw = value);
      if (!mounted || pw == null) return;

      try {
        data = service.parseBackup(raw, password: pw);
      } on BackupException catch (e2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e2.message, style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
        );
        return;
      }
    }

    if (service.hasUnknownCollections(data)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error, style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.rose,
        ),
      );
      return;
    }

    final total = data.values.fold<int>(0, (sum, rows) => sum + rows.length);

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.restoreConfirm, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text(
          '${l10n.backupRestore} $total data. ${l10n.restoreWarning}',
          style: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.restore, style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final serviceNow = ref.read(backupServiceProvider);
      final safety = await serviceNow.generateBackup(db);
      final dir = await _backupDir();
      final safetyFile = File('${dir.path}/safety-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}.json');
      await safetyFile.writeAsString(safety);

      await serviceNow.restoreBackup(db, data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.restore} ($total data).', style: GoogleFonts.inter(fontSize: 13)),
          duration: const Duration(seconds: 4),
        ),
      );
      await _refresh();
    } on BackupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${e.message}', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestore, style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(l10n.backupNow, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _exportBackup,
              icon: const Icon(Icons.ios_share, size: 18),
              label: Text(l10n.backupNow, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.manageBackups, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
          else if (_backupFiles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(l10n.noData, style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
              ),
            )
          else
            ..._backupFiles.map((f) {
              final stat = f.statSync();
              final name = Uri.file(f.path).pathSegments.last;
              final sizeKb = (stat.size / 1024).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: ListTile(
                    onTap: () => _importBackup(File(f.path)),
                    leading: Icon(Icons.description_outlined, color: colors.primary, size: 22),
                    title: Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${DateFormat('dd MMM yyyy, HH:mm').format(stat.modified)} • $sizeKb KB', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                    trailing: Icon(Icons.restore, color: colors.textSecondary, size: 18),
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

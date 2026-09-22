import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/features/settings/application/backup_service.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _operating = false;

  bool get _isUnsupportedPlatform {
    if (kIsWeb) return true;
    return !(Platform.isAndroid || Platform.isIOS);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isUnsupportedPlatform) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.backupRestore, style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: colors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  l10n.backupAvailablePlatform,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 15, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestore, style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildGoogleDriveSection(colors, l10n),
          const SizedBox(height: 24),
          _buildAutoBackupSection(colors, l10n),
          const SizedBox(height: 24),
          _buildRetentionSection(colors, l10n),
          const SizedBox(height: 24),
          _buildStatusSection(colors, l10n),
          const SizedBox(height: 24),
          _buildManualSection(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveSection(AppColorsT colors, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Icon(Icons.cloud, size: 22),
        iconColor: colors.primary,
        title: Text('Google Drive', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          subtitle: Text(
          l10n.notSignedIn,
          style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
        ),
        trailing: FilledButton(
          onPressed: _operating ? null : _handleGoogleSignIn,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(l10n.signInOut, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildAutoBackupSection(AppColorsT colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.autoBackup, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(l10n.autoBackup, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
                value: ref.watch(_autoBackupProvider),
                onChanged: _operating ? null : (v) => ref.read(_autoBackupProvider.notifier).state = v,
                activeThumbColor: AppColors.gold,
              ),
              if (ref.watch(_autoBackupProvider)) ...[
                Divider(height: 1, color: colors.border),
                _buildIntervalPicker(colors, l10n),
                Divider(height: 1, color: colors.border),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(l10n.wifiOnly, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
                  value: ref.watch(_wifiOnlyProvider),
                  onChanged: _operating ? null : (v) => ref.read(_wifiOnlyProvider.notifier).state = v,
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalPicker(AppColorsT colors, AppLocalizations l10n) {
    final intervals = [l10n.frequencyDaily, l10n.frequencyWeekly, l10n.frequencyMonthly];
    final current = ref.watch(_backupIntervalProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(l10n.interval, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
      trailing: DropdownButton<String>(
        value: current,
        underline: const SizedBox(),
        items: intervals.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter(fontSize: 13)))).toList(),
        onChanged: _operating ? null : (v) {
          if (v != null) ref.read(_backupIntervalProvider.notifier).state = v;
        },
      ),
    );
  }

  Widget _buildRetentionSection(AppColorsT colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.backupRetention, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(l10n.maxBackups, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
            subtitle: Text(l10n.maxBackupsDesc, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            trailing: DropdownButton<int>(
              value: ref.watch(_maxBackupsProvider),
              underline: const SizedBox(),
              items: List.generate(10, (i) => i + 1).map((n) {
                return DropdownMenuItem(value: n, child: Text('$n', style: GoogleFonts.inter(fontSize: 13)));
              }).toList(),
              onChanged: _operating ? null : (v) {
                if (v != null) ref.read(_maxBackupsProvider.notifier).state = v;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(AppColorsT colors, AppLocalizations l10n) {
    final lastBackup = ref.watch(_lastBackupProvider);
    final lastFailure = ref.watch(_lastFailureProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.backupRestore, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.schedule, color: colors.primary, size: 20),
                title: Text(
                  lastBackup != null
                      ? '${l10n.lastBackup(DateFormat('dd MMM yy, HH:mm').format(lastBackup))} (${l10n.backupSuccessful})'
                      : l10n.noBackupYet,
                  style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                ),
              ),
              if (lastFailure != null) ...[
                Divider(height: 1, color: colors.border),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.error_outline, color: AppColors.rose, size: 20),
                  title: Text(
                    'Failed: $lastFailure',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.rose),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualSection(AppColorsT colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _operating ? null : _handleBackup,
            icon: _operating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload, size: 18),
            label: Text(l10n.backupNow, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _operating ? null : _handleRestore,
            icon: const Icon(Icons.cloud_download, size: 18),
            label: Text(l10n.restore, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _operating = true);
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TODO: Google Sign-In', style: GoogleFonts.inter(fontSize: 13))),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _handleBackup() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      final service = ref.read(backupServiceProvider);
      final db = ref.read(databaseProvider);

      if (await service.shouldSkipBackup(db)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noChangesSkipBackup, style: GoogleFonts.inter(fontSize: 13))),
        );
        return;
      }

      await service.createCompressedBackup(db);
      await service.recordBackupSuccess();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupSuccessNoUpload, style: GoogleFonts.inter(fontSize: 13))),
      );
    } on BackupException catch (e) {
      await ref.read(backupServiceProvider).recordBackupFailure(e.message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${e.message}', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _handleRestore() async {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final service = ref.read(backupServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.restoreConfirm, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text(
          l10n.restoreWillReplace,
          style: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.restore, style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _operating = true);
    try {
      await service.createSafetySnapshot(db);
      await service.deleteSafetySnapshot();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreSuccessDrive, style: GoogleFonts.inter(fontSize: 13))),
      );
    } on BackupException catch (e) {
      try {
        await service.rollbackFromSafetySnapshot(db);
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${e.message}', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }
}

// --- Local state providers (persisted via SettingsService) ---

final _autoBackupProvider = StateProvider<bool>((ref) => false);
final _wifiOnlyProvider = StateProvider<bool>((ref) => true);
final _backupIntervalProvider = StateProvider<String>((ref) => 'Daily');
final _maxBackupsProvider = StateProvider<int>((ref) => 5);
final _lastBackupProvider = StateProvider<DateTime?>((ref) => null);
final _lastFailureProvider = StateProvider<String?>((ref) => null);

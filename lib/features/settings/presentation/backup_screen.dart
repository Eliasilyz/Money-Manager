import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/features/settings/application/auth_service.dart';
import 'package:money_manager/features/settings/application/backup_service.dart';
import 'package:money_manager/features/settings/application/google_drive_service.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _operating = false;
  bool _loadingDriveFiles = false;
  List<DriveBackupFile> _driveFiles = [];
  String _totalDriveSize = '0 B';
  DateTime? _lastBackupTime;
  String? _lastFailureMessage;

  bool get _isUnsupportedPlatform {
    if (kIsWeb) return true;
    return !(Platform.isAndroid || Platform.isIOS);
  }

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _fetchDriveFiles();
  }

  Future<void> _loadStatus() async {
    final service = ref.read(backupServiceProvider);
    final time = await service.getLastBackupTime();
    final fail = await service.getLastBackupFailure();
    if (mounted) {
      setState(() {
        _lastBackupTime = time;
        _lastFailureMessage = fail;
      });
    }
  }

  Future<void> _fetchDriveFiles() async {
    final user = ref.read(googleUserNotifierProvider);
    if (user == null) {
      if (mounted) {
        setState(() {
          _driveFiles = [];
          _totalDriveSize = '0 B';
        });
      }
      return;
    }

    setState(() => _loadingDriveFiles = true);
    try {
      final authService = ref.read(authServiceProvider);
      final driveService = ref.read(googleDriveServiceProvider);
      final headers = await authService.getAuthHeaders();
      if (headers != null) {
        final files = await driveService.listBackups(headers);
        final sizeStr = await ref.read(backupServiceProvider).getDriveBackupSizeFormatted(
              authService: authService,
              driveService: driveService,
            );
        if (mounted) {
          setState(() {
            _driveFiles = files;
            _totalDriveSize = sizeStr;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching drive files: $e');
    } finally {
      if (mounted) setState(() => _loadingDriveFiles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(googleUserNotifierProvider);

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
      appBar: AppBar(
        title: Text(l10n.backupRestore, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.googleCloudSetupInfo,
            onPressed: () => _showCloudConsoleHelp(context),
          ),
          if (user != null)
            IconButton(
              icon: _loadingDriveFiles
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              onPressed: _loadingDriveFiles ? null : _fetchDriveFiles,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildGoogleDriveSection(colors, l10n, user),
          const SizedBox(height: 24),
          if (user != null) ...[
            _buildRemoteBackupsSection(colors, l10n),
            const SizedBox(height: 24),
          ],
          _buildAutoBackupSection(colors, l10n),
          const SizedBox(height: 24),
          _buildRetentionSection(colors, l10n),
          const SizedBox(height: 24),
          _buildStatusSection(colors, l10n),
          const SizedBox(height: 24),
          _buildManualSection(colors, l10n, user),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveSection(AppColorsT colors, AppLocalizations l10n, GoogleSignInAccount? user) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: user?.photoUrl != null
            ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user!.photoUrl!),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_sync, size: 22, color: colors.primary),
              ),
        title: Text(
          user != null ? (user.displayName ?? user.email) : 'Google Drive',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        subtitle: Text(
          user != null ? user.email : l10n.notSignedIn,
          style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
        ),
        trailing: user != null
            ? OutlinedButton(
                onPressed: _operating ? null : _handleGoogleSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rose,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(l10n.signOut, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              )
            : FilledButton(
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

  Widget _buildRemoteBackupsSection(AppColorsT colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.driveBackupsTitle, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            Text(l10n.driveStorage(_totalDriveSize), style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: _loadingDriveFiles
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : _driveFiles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          l10n.noDriveBackups,
                          style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _driveFiles.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
                      itemBuilder: (ctx, i) {
                        final file = _driveFiles[i];
                        final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(file.createdTime);
                        final sizeStr = BackupService.formatBytes(file.size);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Icon(
                            file.isAutoBackup ? Icons.sync_sharp : Icons.cloud_done,
                            color: colors.primary,
                            size: 22,
                          ),
                          title: Text(
                            file.name,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '$dateStr • $sizeStr${file.isAutoBackup ? ' • Auto' : ''}',
                            style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.cloud_download_outlined, size: 20),
                                color: colors.primary,
                                tooltip: l10n.restore,
                                onPressed: _operating ? null : () => _handleRestoreDriveFile(file),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: AppColors.rose,
                                tooltip: l10n.delete,
                                onPressed: _operating ? null : () => _handleDeleteDriveFile(file),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAutoBackupSection(AppColorsT colors, AppLocalizations l10n) {
    final autoBackup = ref.watch(autoBackupProvider);
    final wifiOnly = ref.watch(wifiOnlyProvider);
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
                value: autoBackup,
                onChanged: _operating
                    ? null
                    : (v) {
                        ref.read(autoBackupProvider.notifier).state = v;
                        ref.read(settingsServiceProvider).saveAutoBackup(v);
                      },
                activeThumbColor: AppColors.gold,
              ),
              if (autoBackup) ...[
                Divider(height: 1, color: colors.border),
                _buildIntervalPicker(colors, l10n),
                Divider(height: 1, color: colors.border),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(l10n.wifiOnly, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
                  value: wifiOnly,
                  onChanged: _operating
                      ? null
                      : (v) {
                          ref.read(wifiOnlyProvider.notifier).state = v;
                          ref.read(settingsServiceProvider).saveWifiOnly(v);
                        },
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
    final intervals = ['Daily', 'Weekly', 'Monthly'];
    final current = ref.watch(backupIntervalProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(l10n.interval, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
      trailing: DropdownButton<String>(
        value: intervals.contains(current) ? current : 'Daily',
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(value: 'Daily', child: Text(l10n.frequencyDaily, style: GoogleFonts.inter(fontSize: 13))),
          DropdownMenuItem(value: 'Weekly', child: Text(l10n.frequencyWeekly, style: GoogleFonts.inter(fontSize: 13))),
          DropdownMenuItem(value: 'Monthly', child: Text(l10n.frequencyMonthly, style: GoogleFonts.inter(fontSize: 13))),
        ],
        onChanged: _operating
            ? null
            : (v) {
                if (v != null) {
                  ref.read(backupIntervalProvider.notifier).state = v;
                  ref.read(settingsServiceProvider).saveBackupInterval(v);
                }
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
              value: ref.watch(maxBackupsProvider),
              underline: const SizedBox(),
              items: List.generate(10, (i) => i + 1).map((n) {
                return DropdownMenuItem(value: n, child: Text('$n', style: GoogleFonts.inter(fontSize: 13)));
              }).toList(),
              onChanged: _operating
                  ? null
                  : (v) {
                      if (v != null) {
                        ref.read(maxBackupsProvider.notifier).state = v;
                        ref.read(settingsServiceProvider).saveMaxBackups(v);
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(AppColorsT colors, AppLocalizations l10n) {
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
                  _lastBackupTime != null
                      ? '${l10n.lastBackup(DateFormat('dd MMM yy, HH:mm').format(_lastBackupTime!))} (${l10n.backupSuccessful})'
                      : l10n.noBackupYet,
                  style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                ),
              ),
              if (_lastFailureMessage != null) ...[
                Divider(height: 1, color: colors.border),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.error_outline, color: AppColors.rose, size: 20),
                  title: Text(
                    'Failed: $_lastFailureMessage',
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

  Widget _buildManualSection(AppColorsT colors, AppLocalizations l10n, GoogleSignInAccount? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _operating ? null : () => _handleBackupNow(user),
            icon: _operating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload, size: 18),
            label: Text(l10n.backupNow, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      final user = await ref.read(googleUserNotifierProvider.notifier).signIn();
      if (user != null) {
        await _fetchDriveFiles();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.signInSuccess(user.email), style: GoogleFonts.inter(fontSize: 13))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = l10n.signInFailed(e.toString());
      final errStr = e.toString();
      if (errStr.contains('ApiException: 4') || errStr.contains('sign_in_required')) {
        msg = l10n.signInCancelled;
      } else if (errStr.contains('ApiException: 10') || errStr.contains('developer_error')) {
        msg = l10n.signInAuthMisconfigured;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: AppColors.rose,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.infoCloud,
            textColor: Colors.white,
            onPressed: () => _showCloudConsoleHelp(context),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }


  Future<void> _handleGoogleSignOut() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      await ref.read(googleUserNotifierProvider.notifier).signOut();
      await _fetchDriveFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.signOutSuccess, style: GoogleFonts.inter(fontSize: 13))),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _handleBackupNow(GoogleSignInAccount? user) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _operating = true);
    try {
      final service = ref.read(backupServiceProvider);
      final db = ref.read(databaseProvider);

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.signInForBackupRequired, style: GoogleFonts.inter(fontSize: 13))),
        );
        return;
      }

      if (await service.shouldSkipBackup(db)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noChangesSkipBackup, style: GoogleFonts.inter(fontSize: 13))),
        );
        return;
      }

      final authService = ref.read(authServiceProvider);
      final driveService = ref.read(googleDriveServiceProvider);

      await service.performBackupToDrive(
        database: db,
        authService: authService,
        driveService: driveService,
        isAutoBackup: false,
      );

      await _loadStatus();
      await _fetchDriveFiles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupSuccess, style: GoogleFonts.inter(fontSize: 13))),
      );
    } on BackupException catch (e) {
      await ref.read(backupServiceProvider).recordBackupFailure(e.message);
      await _loadStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${e.message}', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } catch (e) {
      await ref.read(backupServiceProvider).recordBackupFailure(e.toString());
      await _loadStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _handleRestoreDriveFile(DriveBackupFile file) async {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final service = ref.read(backupServiceProvider);
    final authService = ref.read(authServiceProvider);
    final driveService = ref.read(googleDriveServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.restoreConfirm, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text(
          '${l10n.restoreWillReplace}\nFile: ${file.name}',
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
      final restoredCount = await service.restoreFromDrive(
        database: db,
        authService: authService,
        driveService: driveService,
        fileId: file.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreSuccessCount(restoredCount), style: GoogleFonts.inter(fontSize: 13))),
      );
    } on BackupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${e.message}', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  Future<void> _handleDeleteDriveFile(DriveBackupFile file) async {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final authService = ref.read(authServiceProvider);
    final driveService = ref.read(googleDriveServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.deleteDriveBackupTitle, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text(
          l10n.deleteDriveBackupConfirm(file.name),
          style: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete, style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _operating = true);
    try {
      final headers = await authService.getAuthHeaders();
      if (headers != null) {
        await driveService.deleteBackup(authHeaders: headers, fileId: file.id);
        await _fetchDriveFiles();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driveFileDeleted, style: GoogleFonts.inter(fontSize: 13))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e', style: GoogleFonts.inter(fontSize: 13)), backgroundColor: AppColors.rose),
      );
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  void _showCloudConsoleHelp(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(l10n.googleCloudSetupInfo, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              l10n.googleCloudSetupDesc,
              style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Application Package ID:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  const SizedBox(height: 4),
                  SelectableText('id.eliasilyz.moneymanager', style: GoogleFonts.firaCode(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary)),
                  const SizedBox(height: 8),
                  Text('OAuth Scopes:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  const SizedBox(height: 4),
                  SelectableText(
                    'https://www.googleapis.com/auth/drive.appdata\nhttps://www.googleapis.com/auth/drive.file',
                    style: GoogleFonts.firaCode(fontSize: 11, color: colors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://console.cloud.google.com/');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.openCloudConsole, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

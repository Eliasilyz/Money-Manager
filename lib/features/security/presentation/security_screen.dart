import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/security/application/security_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _hasPin = false;
  bool _biometric = false;
  bool _canBiometric = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(securityServiceProvider);
    final hasPin = await service.isPinSet();
    final bio = await ref
        .read(settingsServiceProvider)
        .getBiometricEnabled();
    final canBio = await service.canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _biometric = bio;
      _canBiometric = canBio;
    });
  }

  Future<void> _setPin() async {
    final service = ref.read(securityServiceProvider);
    final l10n = AppLocalizations.of(context);
    final pin = await _promptPin(context, title: l10n.enterPin);
    if (pin == null) return;
    if (!mounted) return;
    final confirm = await _promptPin(context, title: l10n.changePin);
    if (confirm == null) return;
    if (pin != confirm) {
      _showSnack(l10n.pinMismatch);
      return;
    }
    await service.setPin(pin);
    if (!mounted) return;
    setState(() => _hasPin = true);
    _showSnack(l10n.pinActive);
  }

  Future<void> _removePin() async {
    final service = ref.read(securityServiceProvider);
    final l10n = AppLocalizations.of(context);
    final pin = await _promptPin(context, title: l10n.enterPin);
    if (pin == null) return;
    final ok = await service.verifyPin(pin);
    if (!ok) {
      _showSnack(l10n.pinMismatch);
      return;
    }
    await service.removePin();
    if (!mounted) return;
    setState(() {
      _hasPin = false;
      _biometric = false;
    });
    _showSnack(l10n.pinInactive);
  }

  Future<void> _toggleBiometric(bool v) async {
    final service = ref.read(securityServiceProvider);
    final settings = ref.read(settingsServiceProvider);
    final l10n = AppLocalizations.of(context);
    if (v) {
      final success = await service.authenticateWithBiometrics();
      if (!success) {
        _showSnack(l10n.biometricsInactive);
        return;
      }
    }
    await settings.saveBiometricEnabled(v);
    if (!mounted) return;
    setState(() => _biometric = v);
  }

  Future<String?> _promptPin(BuildContext context, {required String title}) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.enterPin,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.isEmpty ? null : ctrl.text),
            child: Text(l10n.save, style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.inter(fontSize: 13)), duration: const Duration(seconds: 3)),
    );
  }

  Widget _row(IconData icon, String title, String subtitle, bool enabled, VoidCallback onTap) {
    final colors = AppColorsT.of(context);
    return ListTile(
      onTap: enabled ? onTap : null,
      leading: Icon(icon, color: colors.primary, size: 22),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.securityPriv, style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            l10n.securityPriv,
            style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _row(
                  _hasPin ? Icons.lock_outline : Icons.add,
                  l10n.securityPriv,
                  _hasPin ? l10n.pinActive : l10n.pinInactive,
                  true,
                  _hasPin ? _removePin : _setPin,
                ),
                if (_hasPin && _canBiometric) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _biometric,
                    onChanged: _toggleBiometric,
                    activeTrackColor: AppColors.gold,
                    activeThumbColor: AppColors.bg,
                    title: Text(l10n.enableBiometrics, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                  ),
                ] else if (_hasPin)
                  const Divider(height: 1),
              ],
            ),
          ),
          if (_hasPin)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                l10n.securityPriv,
                style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
              ),
            ),
          if (!_canBiometric)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 4),
              child: Text(
                l10n.biometricsInactive,
                style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

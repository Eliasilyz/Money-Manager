import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_manager/core/crypto/crypto_utils.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/l10n_loader.dart';

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);
  @override
  String toString() => message;
}

class SecurityService {
  final SettingsService _settings;
  final LocalAuthentication _auth;

  SecurityService(this._settings) : _auth = LocalAuthentication();

  Future<bool> isPinSet() async => (await _settings.getPinHash()) != null;

  bool _matchesPin(String entered, String hash, String salt) {
    return CryptoUtils.hashData('$salt:$entered') == hash;
  }

  Future<bool> verifyPin(String pin) async {
    final hash = await _settings.getPinHash();
    final salt = await _settings.getPinSalt();
    if (hash == null || salt == null) return false;
    return _matchesPin(pin, hash, salt);
  }

  Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    final hash = CryptoUtils.hashData('$salt:$pin');
    await _settings.savePin(hash, salt);
  }

  Future<void> removePin() async {
    await _settings.clearPin();
    await _settings.saveBiometricEnabled(false);
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: (await loadAppL10n()).biometricReason,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  String _randomSalt() {
    final rng = Random.secure();
    return base64Encode(List.generate(16, (_) => rng.nextInt(256)));
  }
}

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService(ref.read(settingsServiceProvider));
});

/// True while the app must show the lock screen.
final appLockedProvider = StateProvider<bool>((ref) => false);

/// True once the lock screen has been dismissed this session.
final appUnlockedProvider = StateProvider<bool>((ref) => false);

/// Sets the initial lock state based on whether a PIN is configured.
final securityInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(securityServiceProvider);
  final hasPin = await service.isPinSet();
  ref.read(appLockedProvider.notifier).state = hasPin;
});
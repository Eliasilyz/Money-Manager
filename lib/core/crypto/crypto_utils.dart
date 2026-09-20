import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;

/// Encryption helpers used by encrypted backups and PIN hashing.
///
/// Uses AES-256-GCM for confidentiality plus an encrypt-then-MAC
/// HMAC-SHA256 so tampering and wrong passwords are detected reliably
/// (the `encrypt` package's GCM path does not verify the auth tag on
/// decrypt, so a MAC is appended explicitly).
class CryptoUtils {
  static const ivLength = 12;
  static const macLength = 32;

  /// PBKDF2-like key derivation: HMAC-SHA256(password, salt || counter).
  static Uint8List deriveKey(String password, Uint8List salt) {
    final hmac = crypto.Hmac(crypto.sha256, utf8.encode(password));
    return Uint8List.fromList(hmac.convert([...salt, 0x00, 0x01]).bytes);
  }

  /// Envelope: base64( salt(16) | iv(12) | hmac(32) | ciphertext ).
  static String encryptData(String plainText, String key) {
    final salt = randomBytes(16);
    final derived = deriveKey(key, salt);
    final iv = enc.IV(randomBytes(ivLength));
    final encrypter = enc.Encrypter(enc.AES(enc.Key(derived), mode: enc.AESMode.gcm));
    final ciphertext = encrypter.encrypt(plainText, iv: iv).bytes;
    final mac = _mac(derived, [...salt, ...iv.bytes, ...ciphertext]);
    return base64Encode([...salt, ...iv.bytes, ...mac, ...ciphertext]);
  }

  static String decryptData(String encryptedText, String key) {
    final bytes = base64Decode(encryptedText);
    if (bytes.length < 16 + ivLength + macLength) {
      throw const FormatException('Data terenkripsi tidak valid');
    }
    final salt = Uint8List.fromList(bytes.sublist(0, 16));
    final iv = Uint8List.fromList(bytes.sublist(16, 16 + ivLength));
    final mac = Uint8List.fromList(bytes.sublist(16 + ivLength, 16 + ivLength + macLength));
    final ciphertext = Uint8List.fromList(bytes.sublist(16 + ivLength + macLength));

    final derived = deriveKey(key, salt);
    final expected = _mac(derived, [...salt, ...iv, ...ciphertext]);
    if (!_constantTimeEquals(mac, expected)) {
      throw const FormatException('Kata sandi salah atau data rusak');
    }

    final encrypter = enc.Encrypter(enc.AES(enc.Key(derived), mode: enc.AESMode.gcm));
    return encrypter.decrypt(enc.Encrypted(ciphertext), iv: enc.IV(iv));
  }

  static String hashData(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }

  /// Returns bytes of the backup raw payload (for manual callers); kept for
  /// the UI path to expose file size limits.
  static Uint8List randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
  }

  static Uint8List _mac(Uint8List key, List<int> data) {
    return crypto.Hmac(crypto.sha256, key).convert(data).bytes as Uint8List;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
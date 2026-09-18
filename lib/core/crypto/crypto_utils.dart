import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoUtils {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyAlias = 'encryption_key';

  static Future<String> getOrCreateEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyAlias);
    if (key == null) {
      final bytes = List<int>.generate(32, (i) => i);
      key = base64Encode(bytes);
      await _secureStorage.write(key: _encryptionKeyAlias, value: key);
    }
    return key;
  }

  static Uint8List _deriveKey(String password, {int keyLength = 32}) {
    final bytes = utf8.encode(password);
    final derived =
        md5.convert(bytes).bytes + md5.convert(bytes.reversed.toList()).bytes;
    return Uint8List.fromList(derived).sublist(0, keyLength);
  }

  static String encryptData(String plainText, String key) {
    final keyBytes = _deriveKey(key);
    final textBytes = Uint8List.fromList(utf8.encode(plainText));
    final encrypted = Uint8List(textBytes.length);
    for (int i = 0; i < textBytes.length; i++) {
      encrypted[i] = textBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return base64Encode(encrypted);
  }

  static String decryptData(String encryptedText, String key) {
    final keyBytes = _deriveKey(key);
    final encrypted = base64Decode(encryptedText);
    final decrypted = Uint8List(encrypted.length);
    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
    }
    return utf8.decode(decrypted);
  }

  static String hashData(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

class CryptoUtils {
  static String _deriveKey(String password, {int keyLength = 32}) {
    final bytes = utf8.encode(password);
    final derived = crypto.md5.convert(bytes).bytes + crypto.md5.convert(bytes.reversed.toList()).bytes;
    return base64Encode(Uint8List.fromList(derived).sublist(0, keyLength));
  }

  static String encryptData(String plainText, String key) {
    final keyBytes = Uint8List.fromList(utf8.encode(_deriveKey(key)));
    final textBytes = Uint8List.fromList(utf8.encode(plainText));
    final encrypted = Uint8List(textBytes.length);
    for (int i = 0; i < textBytes.length; i++) {
      encrypted[i] = textBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return base64Encode(encrypted);
  }

  static String decryptData(String encryptedText, String key) {
    final keyBytes = Uint8List.fromList(utf8.encode(_deriveKey(key)));
    final encrypted = base64Decode(encryptedText);
    final decrypted = Uint8List(encrypted.length);
    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
    }
    return utf8.decode(decrypted);
  }

  static String hashData(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }
}


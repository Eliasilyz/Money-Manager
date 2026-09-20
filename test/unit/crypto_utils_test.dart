import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/crypto/crypto_utils.dart';

void main() {
  group('CryptoUtils AES-GCM roundtrip', () {
    test('encrypt and decrypt returns original text', () {
      const plain = 'Hello, Money Manager!Data rahasia 12345';
      final encrypted = CryptoUtils.encryptData(plain, 'password-ku');
      expect(encrypted, isNot(plain));
      expect(CryptoUtils.decryptData(encrypted, 'password-ku'), plain);
    });

    test('wrong password fails to decrypt', () {
      final encrypted = CryptoUtils.encryptData('secret', 'benar');
      expect(() => CryptoUtils.decryptData(encrypted, 'salah'), throwsA(anything));
    });

    test('same input produces different ciphertext (random salt/iv)', () {
      final a = CryptoUtils.encryptData('sama', 'key');
      final b = CryptoUtils.encryptData('sama', 'key');
      expect(a, isNot(b));
    });

    test('corrupted ciphertext fails', () {
      final encrypted = CryptoUtils.encryptData('secret', 'key');
      final corrupted = '${encrypted.substring(0, encrypted.length ~/ 2)}X${encrypted.substring(encrypted.length ~/ 2 + 1)}';
      expect(() => CryptoUtils.decryptData(corrupted, 'key'), throwsA(anything));
    });

    test('hashData is stable and non-reversible', () {
      expect(CryptoUtils.hashData('abc'), CryptoUtils.hashData('abc'));
      expect(CryptoUtils.hashData('abc'), isNot(CryptoUtils.hashData('abd')));
    });
  });
}
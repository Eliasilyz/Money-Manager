# Security

## App lock

- **PIN** — stored as `SHA-256("salt:pin")` with a random 16-byte salt (`features/security/application/security_provider.dart`). The salt and hash live in `SharedPreferences`.
- **Anti-bruteforce** — 5 consecutive wrong PINs trigger a lockout dialog with a mandatory **60-second** cooldown (`lock_screen.dart`).
- **Biometrics** — optional fingerprint/Face ID via `local_auth` (`stickyAuth`, `biometricOnly`). Enabling it requires a PIN to exist; removing the PIN also disables biometrics.
- **Session lock** — `securityInitProvider` locks the app at launch if a PIN is configured. `appLockedProvider` drives a `LockScreen` overlay rendered above the router, so navigation state is preserved while locked (`app.dart` builder).

## Backup encryption (CryptoUtils)

`lib/core/crypto/crypto_utils.dart` implements encrypt-then-MAC:

- **Cipher**: AES-256-GCM (random 12-byte IV, random 16-byte salt per message)
- **MAC**: HMAC-SHA256 over `salt | iv | ciphertext`, verified in **constant time** before decryption
- **Envelope**: `base64( salt(16) | iv(12) | hmac(32) | ciphertext )`
- **Key derivation**: HMAC-SHA256-based KDF over the password + salt

The explicit MAC matters: the `encrypt` package does not verify the GCM auth tag on decrypt, so tamper detection is done manually. A wrong password or corrupted data throws `FormatException` with a localized message.

Covered by `test/unit/crypto_utils_test.dart` (roundtrip, wrong password, randomization, tamper, hash stability).

## What is *not* encrypted

The local SQLite database is stored **in plain text**. The PIN gates app access; it does not encrypt data at rest. Anyone with the device file (root/backup extraction) can read it. This is the standard trade-off for a local-first app, but be aware of it.

## Hardening ideas (not yet implemented)

- SQLCipher / SQLCipher-style encryption for `money_manager.db`
- Key derivation with a higher iteration count (current KDF is a single HMAC round — fast, which is good for UX but weaker against offline PIN brute force)
- Keychain/Keystore storage for the PIN salt and Drive tokens instead of `SharedPreferences`

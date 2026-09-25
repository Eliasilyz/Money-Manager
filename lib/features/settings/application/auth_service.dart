import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleUserInfo {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleUserInfo({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  factory GoogleUserInfo.fromJson(Map<String, dynamic> json) => GoogleUserInfo(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        displayName: json['displayName'] ?? '',
        photoUrl: json['photoUrl'],
      );
}

class AuthService {
  static const List<String> _scopes = [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.appdata',
    'https://www.googleapis.com/auth/drive.file',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        await _saveUserCache(account);
      }
      return account;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final bool isSigned = await _googleSignIn.isSignedIn();
      if (!isSigned) return null;
      final account = await _googleSignIn.signInSilently(reAuthenticate: false);
      if (account != null) {
        await _saveUserCache(account);
      }
      return account;
    } catch (e) {
      debugPrint('Google Silent Sign In Error: $e');
      return null;
    }
  }


  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearUserCache();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  Future<Map<String, String>?> getAuthHeaders() async {
    final account = _googleSignIn.currentUser ?? await signInSilently();
    if (account == null) return null;
    return await account.authHeaders;
  }

  Future<void> _saveUserCache(GoogleSignInAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gdrive_user_id', account.id);
    await prefs.setString('gdrive_user_email', account.email);
    await prefs.setString('gdrive_user_name', account.displayName ?? '');
    if (account.photoUrl != null) {
      await prefs.setString('gdrive_user_photo', account.photoUrl!);
    } else {
      await prefs.remove('gdrive_user_photo');
    }
  }

  Future<void> _clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gdrive_user_id');
    await prefs.remove('gdrive_user_email');
    await prefs.remove('gdrive_user_name');
    await prefs.remove('gdrive_user_photo');
  }

  static Future<GoogleUserInfo?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('gdrive_user_email');
    if (email == null || email.isEmpty) return null;
    return GoogleUserInfo(
      id: prefs.getString('gdrive_user_id') ?? '',
      email: email,
      displayName: prefs.getString('gdrive_user_name') ?? '',
      photoUrl: prefs.getString('gdrive_user_photo'),
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class GoogleUserNotifier extends StateNotifier<GoogleSignInAccount?> {
  final AuthService _authService;

  GoogleUserNotifier(this._authService) : super(_authService.currentUser) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authService.signInSilently();
      if (mounted) state = user;
    } catch (e) {
      debugPrint('GoogleUserNotifier init error: $e');
    }
  }


  Future<GoogleSignInAccount?> signIn() async {
    final user = await _authService.signIn();
    state = user;
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}

final googleUserNotifierProvider =
    StateNotifierProvider<GoogleUserNotifier, GoogleSignInAccount?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return GoogleUserNotifier(auth);
});

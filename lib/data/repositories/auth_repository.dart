import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  SupabaseClient get client {
    if (!AppConfig.configured) throw StateError('Set SUPABASE_URL and SUPABASE_ANON_KEY to connect your account.');
    return Supabase.instance.client;
  }
  User? get user {
    if (!AppConfig.configured) return null;
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }
  bool get authenticated => user != null && (user!.isAnonymous || user!.emailConfirmedAt != null);
  static const duplicateEmail = 'An account with this email already exists. Please sign in instead.';
  Stream<AuthState> get onAuthStateChange {
    if (!AppConfig.configured) return const Stream.empty();
    try {
      return Supabase.instance.client.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }
  Future<bool> signInWithGoogle() => client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: AppConfig.redirectUrl);
  Future<AuthResponse> signInWithEmail(String email, String password) =>
      client.auth.signInWithPassword(email: email.trim().toLowerCase(), password: password);
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final result = await client.auth.signUp(email: email.trim().toLowerCase(), password: password,
        emailRedirectTo: AppConfig.redirectUrl);
      if (result.user?.identities?.isEmpty == true) throw const AuthException(duplicateEmail);
      return result;
    } on AuthException catch (e) {
      if (['user_already_exists', 'email_exists'].contains(e.code)) throw const AuthException(duplicateEmail);
      rethrow;
    }
  }
  Future<AuthResponse> signInAnonymously() => client.auth.signInAnonymously();
  Future<bool> linkGoogleAccount() => client.auth.linkIdentity(OAuthProvider.google, redirectTo: AppConfig.redirectUrl);
  Future<UserResponse> linkEmailAccount(String email, String password) => client.auth.updateUser(
    UserAttributes(email: email.trim().toLowerCase(), password: password), emailRedirectTo: AppConfig.redirectUrl);
  Future<void> resendVerificationEmail(String email) => client.auth.resend(type: OtpType.signup,
    email: email.trim().toLowerCase(), emailRedirectTo: AppConfig.redirectUrl);
  Future<void> signOut() => client.auth.signOut();
}

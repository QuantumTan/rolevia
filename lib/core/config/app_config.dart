abstract final class AppConfig {
  static bool? configuredOverride;

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_SUPABASE_PROJECT_REF.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_PLACEHOLDER',
  );
  static const rewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const redirectUrl = 'io.supabase.rolevia://login-callback';
  static bool get configured =>
      configuredOverride ??
      (supabaseUrl.isNotEmpty &&
          supabaseAnonKey.isNotEmpty &&
          !supabaseUrl.contains('YOUR_SUPABASE') &&
          !supabaseAnonKey.contains('PLACEHOLDER'));
}

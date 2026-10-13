abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get effectiveSupabaseKey {
    final publishableKey = supabasePublishableKey.trim();
    if (publishableKey.isNotEmpty) return publishableKey;
    return supabaseAnonKey.trim();
  }

  static bool get isSupabaseConfigured {
    final uri = Uri.tryParse(supabaseUrl.trim());
    final key = effectiveSupabaseKey;
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty &&
        key.isNotEmpty;
  }
}

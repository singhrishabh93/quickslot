class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://knnrrmfwyubpkyqdikym.supabase.co';

  /// Anon (public) key — safe to ship in client builds.
  /// Get yours from Supabase Dashboard → Settings → API → "anon public".
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtubnJybWZ3eXVicGt5cWRpa3ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwOTc2NTEsImV4cCI6MjA5NjY3MzY1MX0.wFAtseb5RTLFDzrkTh9-EyyCfiRYvkMxCZhYK12YxU4';

  static bool get isConfigured =>
      anonKey.isNotEmpty && anonKey != 'REPLACE_ME_WITH_ANON_KEY';
}

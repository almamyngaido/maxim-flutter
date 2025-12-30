/// API Configuration
///
/// Central place to configure API endpoints for different environments
class ApiConfig {
  // ========================================
  // ENVIRONMENT CONFIGURATION
  // ========================================
  //
  // Set this to switch between environments:
  // - Environment.production: Railway hosted API
  // - Environment.local: Local development on PC
  // - Environment.network: Local network (for phone testing)

  static const Environment currentEnvironment = Environment.production;

  // Production URL (Railway)
  static const String productionUrl = 'https://immo-api-production.up.railway.app';

  // Local development URLs
  static const String _localIP = '192.168.1.8'; // Your PC's local IP
  static const String _port = '3000';
  static const String localhostUrl = 'http://127.0.0.1:3000';
  static const String networkUrl = 'http://$_localIP:$_port';

  /// Base API URL - automatically switches based on environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        return productionUrl;
      case Environment.local:
        return localhostUrl;
      case Environment.network:
        return networkUrl;
    }
  }

  /// Environment-based URL (alias for baseUrl)
  static String get apiUrl => baseUrl;

  /// Utility method to test if API is reachable
  static void printApiConfig() {
    print('=================================');
    print('📡 API Configuration');
    print('=================================');
    print('Environment: $currentEnvironment');
    print('Base URL: $baseUrl');
    print('=================================');
    print('');
    print('To switch environments:');
    print('1. Open lib/configs/api_config.dart');
    print('2. Change currentEnvironment value');
    print('3. Restart the app');
    print('=================================');
  }
}

/// Environment enum for easy switching
enum Environment {
  production,  // Railway hosted API
  local,       // localhost:3000
  network,     // Your PC's network IP (for phone testing)
}

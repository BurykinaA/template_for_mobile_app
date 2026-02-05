/// API Configuration for SStats.net Football API
/// 
/// API Key should be set via environment variable:
/// flutter run --dart-define=API_KEY=your_api_key
/// 
/// Or export before running:
/// export API_KEY=your_api_key
/// flutter run

class ApiConfig {
  static const String baseUrl = 'https://api.sstats.net';
  
  // API Key from environment variable
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  // API Endpoints
  static const String gamesListEndpoint = '/Games/list';
  static const String leaguesEndpoint = '/Leagues';
  static const String gameGlickoEndpoint = '/Games/glicko'; // + /{id}
  static const String seasonTableEndpoint = '/Games/season-table';
  static const String teamsListEndpoint = '/Teams/list';

  /// Build URL with query parameters
  static String buildUrl(String endpoint, [Map<String, String>? params]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    final queryParams = <String, String>{};
    if (apiKey.isNotEmpty) {
      queryParams['apikey'] = apiKey;
    }
    if (params != null) {
      queryParams.addAll(params);
    }
    
    return uri.replace(queryParameters: queryParams.isEmpty ? null : queryParams).toString();
  }

  /// Check if API key is configured
  static bool get isApiKeyConfigured => apiKey.isNotEmpty;
}

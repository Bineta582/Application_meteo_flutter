import 'package:dio/dio.dart';
import 'package:meteo_app/models/meteo_data.dart';

class MeteoService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  // Remplace par ta clé API OpenWeatherMap
  static const String _apiKey = 'ee414cbd59cae729bd075828fad800a9';

  final Dio _dio;

  MeteoService()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<MeteoData> getWeatherByCity(String city) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'fr',
        },
      );
      return MeteoData.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw WeatherException('Délai de connexion dépassé');
      } else if (e.response?.statusCode == 404) {
        throw WeatherException('Ville "$city" introuvable');
      } else if (e.response?.statusCode == 401) {
        throw WeatherException('Clé API invalide');
      } else {
        throw WeatherException('Erreur réseau : ${e.message}');
      }
    }
  }

  Future<List<MeteoData>> getWeatherForCities(List<String> cities) async {
    final List<MeteoData> results = [];
    final List<String> errors = [];

    for (final city in cities) {
      try {
        final data = await getWeatherByCity(city);
        results.add(data);
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        errors.add(city);
      }
    }

    if (results.isEmpty) {
      throw WeatherException(
          'Impossible de récupérer la météo. Vérifiez votre connexion.');
    }

    return results;
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

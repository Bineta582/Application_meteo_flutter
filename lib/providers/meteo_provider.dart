import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meteo_data.dart';
import '../services/meteo_service.dart';

enum WeatherState { idle, loading, success, error }

class MeteoProvider extends ChangeNotifier {
  final MeteoService _service = MeteoService();

  WeatherState _state = WeatherState.idle;
  List<MeteoData> _weatherList = [];
  String _errorMessage = '';
  double _progress = 0.0;
  int _currentMessageIndex = 0;
  String _loadingMessage = '';
  Timer? _messageTimer;
  Timer? _progressTimer;

  WeatherState get state => _state;
  List<MeteoData> get weatherList => _weatherList;
  String get errorMessage => _errorMessage;
  double get progress => _progress;
  String get loadingMessage => _loadingMessage;

  static const List<String> _cities = [
    'Dakar',
    'Paris',
    'New York',
    'Tokyo',
    'Dubai',
  ];

  static const List<String> _loadingMessages = [
    'Nous téléchargeons les données…',
    'Connexion aux serveurs météo…',
    'C\'est presque fini…',
    'Récupération des températures…',
    'Plus que quelques secondes avant d\'avoir le résultat…',
    'Analyse des données atmosphériques…',
    'Presque prêt ! 🌤',
  ];

  Future<void> loadWeather() async {
    _state = WeatherState.loading;
    _progress = 0.0;
    _weatherList = [];
    _errorMessage = '';
    _currentMessageIndex = 0;
    _loadingMessage = _loadingMessages[0];
    notifyListeners();

    // Démarrer le timer de messages rotatifs
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _currentMessageIndex =
          (_currentMessageIndex + 1) % _loadingMessages.length;
      _loadingMessage = _loadingMessages[_currentMessageIndex];
      notifyListeners();
    });

    // Démarrer la progression simulée
    _progressTimer?.cancel();
    double fakeProgress = 0.0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (fakeProgress < 0.85) {
        fakeProgress += 0.008;
        _progress = fakeProgress;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });

    try {
      final List<MeteoData> results = [];
      for (int i = 0; i < _cities.length; i++) {
        final data = await _service.getWeatherByCity(_cities[i]);
        results.add(data);
        _progress = (i + 1) / _cities.length;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 800));
      }

      _progressTimer?.cancel();
      _messageTimer?.cancel();

      // Animation finale de la jauge
      double finalProgress = _progress;
      Timer.periodic(const Duration(milliseconds: 20), (timer) {
        if (finalProgress < 1.0) {
          finalProgress += 0.02;
          _progress = finalProgress.clamp(0.0, 1.0);
          notifyListeners();
        } else {
          timer.cancel();
          _weatherList = results;
          _state = WeatherState.success;
          notifyListeners();
        }
      });
    } catch (e) {
      _progressTimer?.cancel();
      _messageTimer?.cancel();
      _state = WeatherState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = WeatherState.idle;
    _weatherList = [];
    _errorMessage = '';
    _progress = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }
}

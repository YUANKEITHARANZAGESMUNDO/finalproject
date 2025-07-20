import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with your OpenWeatherMap API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Get current position
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getDefaultWeather();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getDefaultWeather();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Make API call to OpenWeatherMap
      final response = await http.get(Uri.parse(
        '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'].round(),
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'humidity': data['main']['humidity'],
          'windSpeed': data['wind']['speed'],
          'city': data['name'],
          'country': data['sys']['country'],
        };
      } else {
        return _getDefaultWeather();
      }
    } catch (e) {
      return _getDefaultWeather();
    }
  }

  static Map<String, dynamic> _getDefaultWeather() {
    return {
      'temperature': 25,
      'description': 'Partly cloudy',
      'icon': '02d',
      'humidity': 65,
      'windSpeed': 5.2,
      'city': 'Unknown',
      'country': 'Unknown',
    };
  }

  static String getWeatherIcon(String iconCode, bool isDarkMode) {
    // Map weather icon codes to emoji or custom icons
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
        return '🌦️';
      case '10n':
        return '🌧️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return isDarkMode ? '🌙' : '☀️';
    }
  }
} 
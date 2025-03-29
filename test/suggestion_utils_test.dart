import 'package:flutter_test/flutter_test.dart';
import 'package:eferme_app/stateNotifierProviders/weather_state.dart';
import 'package:eferme_app/utils/suggestions_utils.dart';

void main() {
  group('getAllSuggestions', () {
    test('returns suggestions for hot and clear weather', () {
      final weatherData = WeatherData(
        temperature: 30,
        description: 'clear',
        cityName: 'Test City',
        forecast: [], 
        humidity: 34, 
        windSpeed: 4,
      );

      final suggestions = getAllSuggestions(weatherData);

      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Irrigate crops early in the morning to reduce evaporation.'));
    });

    test('returns suggestions for cold weather', () {
      final weatherData = WeatherData(
        temperature: 5,
        description: 'clear',
        cityName: 'Test City',
        forecast: [], 
        humidity: 25, 
        windSpeed: 10,
      );

      final suggestions = getAllSuggestions(weatherData);

      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Cover sensitive plants with frost blankets.'));
    });

    test('returns no specific suggestions for unknown weather', () {
      final weatherData = WeatherData(
        temperature: 20,
        description: 'unknown',
        cityName: 'Test City',
        forecast: [], 
        humidity: 23, 
        windSpeed: 12,
      );

      final suggestions = getAllSuggestions(weatherData);

      expect(suggestions, contains('No specific suggestions for the current weather.'));
    });
  });

  group('getAllForecastSuggestions', () {
    test('returns suggestions for hot and clear forecast', () {
      final forecast = Forecast(
        dateTime: DateTime.now(),
        temperature: 30,
        description: 'clear', 
        maxTemperature: 27.2, 
        minTemperature: 12.0,
      );

      final suggestions = getAllForecastSuggestions(forecast);

      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Irrigate crops early in the morning to reduce evaporation.'));
    });

    test('returns suggestions for cold forecast', () {
      final forecast = Forecast(
        dateTime: DateTime.now(),
        temperature: 5,
        description: 'clear', 
        maxTemperature: 27.2, 
        minTemperature: 10.1,
      );

      final suggestions = getAllForecastSuggestions(forecast);

      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Cover sensitive plants with frost blankets.'));
    });

    test('returns no specific suggestions for unknown forecast', () {
      final forecast = Forecast(
        dateTime: DateTime.now(),
        temperature: 20,
        description: 'unknown', 
        maxTemperature: 25.2, 
        minTemperature: 12.5,
      );

      final suggestions = getAllForecastSuggestions(forecast);

      expect(suggestions, contains('No specific suggestions for the current weather.'));
    });
  });
}
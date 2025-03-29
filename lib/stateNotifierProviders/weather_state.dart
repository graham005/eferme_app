import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eferme_app/services/sqlite_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final List<Forecast> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.forecast
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['city_name'],
      temperature: json['temperature'].toDouble(),
      description: json['description'],
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
      forecast: List<Forecast>.from(json['forecast'].map((x) => Forecast.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'forecast': List<dynamic>.from(forecast.map((x) => x.toJson())),
    };
  }

  WeatherData copyWith({
    String? cityName,
    double? temperature,
    String? description,
    int? humidity,
    double? windSpeed,
    List<Forecast>? forecast,
  }) {
    return WeatherData(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      forecast: forecast ?? this.forecast,
    );
  }

  static Future<WeatherData> fetchWeather(String city, String apiKey) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return WeatherData(
        cityName: jsonData['name'],
        temperature: jsonData['main']['temp'].toDouble() - 273.15,
        description: jsonData['weather'][0]['description'],
        humidity: jsonData['main']['humidity'],
        windSpeed: jsonData['wind']['speed'].toDouble(),
        forecast: []
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  
  static Future<List<Forecast>> fetchForecast(String city, String apiKey) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      Map<String, List<Forecast>> dailyForecasts = {};

      for (var data in jsonData['list']) {
        Forecast forecast = Forecast.fromJson(data);
        String date = DateFormat('yyyy-MM-dd').format(forecast.dateTime);

        if (!dailyForecasts.containsKey(date)) {
          dailyForecasts[date] = [];
        }
        dailyForecasts[date]!.add(forecast);
      }

      List<Forecast> processedForecasts = dailyForecasts.entries.map((entry) {
        List<Forecast> dailyData = entry.value;
        double maxTemp = dailyData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
        double minTemp = dailyData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
        return Forecast(
          dateTime: dailyData.first.dateTime,
          temperature: dailyData.first.temperature,
          description: dailyData.first.description,
          maxTemperature: maxTemp,
          minTemperature: minTemp,
        );
      }).toList();

      return processedForecasts;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}

class Forecast {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final double maxTemperature;
  final double minTemperature;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.maxTemperature,
    required this.minTemperature,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble() - 273.15,
      description: json['weather'][0]['description'],
      maxTemperature: json['main']['temp_max'].toDouble() - 273.15,
      minTemperature: json['main']['temp_min'].toDouble() - 273.15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch ~/ 1000,
      'temperature': temperature,
      'description': description,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
    };
  }
}

class WeatherNotifier extends StateNotifier<WeatherData?> {
  WeatherNotifier(): super(null);

  final SQLiteHelper dbHelper = SQLiteHelper();

  Future<void> fetchWeatherAndForecast() async {
    try {
      // Load the last synced weather data from the database
      final lastSyncedData = await dbHelper.getLastSyncedWeatherData();
      if(lastSyncedData.isNotEmpty) {
        state = WeatherData.fromJson(lastSyncedData);
      }

      // Check connectivty
      bool isConnected = await _checkConnectivity();
      if(isConnected) {
        // Fetch current location
        LocationPermission permission = await Geolocator.checkPermission();
        if(permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        // Fetch weather and forecast from the API
        String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
        String city = await _getCityFromCoordinates(position.latitude, position.longitude, apiKey);

        WeatherData weatherData = await WeatherData.fetchWeather(city, apiKey);
        List<Forecast> forecast = await WeatherData.fetchForecast(city, apiKey);

        // Update the state with the fetched data
        state = weatherData.copyWith(forecast: forecast); 

        // Save the fetched data to the database
        await dbHelper.insertWeatherData(weatherData.toJson());
      }    
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String> _getCityFromCoordinates(double latitude,double longitude, String apiKey) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['name'];
    } else {
      throw Exception('Failed to load city data');
    }
  }
}


final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherData?>((ref) => WeatherNotifier());
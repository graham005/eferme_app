import 'dart:math';
import 'package:eferme_app/pages/calculator_page.dart';
import 'package:eferme_app/pages/diseaseDetection/disease_detection_page.dart';
import 'package:eferme_app/pages/navigation_bar.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../stateNotifierProviders/weather_state.dart';
import 'package:eferme_app/utils/weather_utils.dart';
import 'package:eferme_app/utils/suggestions_utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider);
    final notifier = ref.watch(weatherProvider.notifier);

    if (weatherData == null) {
      notifier.fetchWeatherAndForecast();
    }

    String dailyRandomSuggestion = '';
    String nextDayRandomSuggestion = '';
    if (weatherData != null) {
      final suggestions = getAllSuggestions(weatherData);
      if (suggestions.isNotEmpty) {
        final randomIndex = Random().nextInt(suggestions.length);
        dailyRandomSuggestion = suggestions[randomIndex];
      }

      // Get the next day's forecast
      if (weatherData.forecast.isNotEmpty) {
        final nextDayForecast = weatherData.forecast[1]; 
        final nextDaySuggestions = getAllForecastSuggestions(nextDayForecast);
        if (nextDaySuggestions.isNotEmpty) {
          final randomIndex = Random().nextInt(nextDaySuggestions.length);
          nextDayRandomSuggestion = nextDaySuggestions[randomIndex];
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('e-ferme', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Weather", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (weatherData != null)
                            Text("${weatherData.temperature.toStringAsFixed(1)}°C", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (weatherData != null)
                            Row(
                              children: [
                                Icon(Icons.location_city),
                                SizedBox(width: 4),
                                Text(weatherData.cityName),
                              ],
                            ),
                          if (weatherData != null)
                            Text(weatherData.description),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                    Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 2,))), 
                        );
                      },
                      child: Card(
                        color: Color(0xFFe0e3db),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                          children: [
                            Row(
                            children: [
                              Icon(Icons.search, color: Colors.green),
                              SizedBox(width: 10),
                            ],
                            ),
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                              children: [
                                Text("Disease", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                              ),
                              Text("Detection", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                            ),
                            Row(
                            children: [
                              Text("Scan your maize"),
                              SizedBox(width: 10),
                            ],
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  SizedBox(width: 16),
                    Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 1,))),
                        );
                      },
                      child: Card(
                        color: Color(0xFFe0e3db),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                          children: [
                            Row(
                            children: [
                              Icon(Icons.calculate_outlined, color: Colors.brown),
                              SizedBox(width: 5),
                            ],
                            ),
                            Row(
                            children: [
                              Text("Farm Calculator", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                            ],
                            ),
                            Row(
                            children: [
                              Text("Seed & Fertilizer"),
                              SizedBox(width: 10),
                            ],
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
                    )
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.6),
                ),
                child: Lottie.asset('assets/homepage.json'),
              ),
              SizedBox(height: 16),
              Text("Today's Farm Tips", textAlign: TextAlign.start, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Card(
                color: Color(0xFFe0e3db),
                elevation: 0,
                child: ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.amber),
                  title: Text(dailyRandomSuggestion),
                  subtitle: Text(nextDayRandomSuggestion),
                ),
              ),
              SizedBox(height: 16),
              Text("5-Day Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (weatherData != null && weatherData.forecast.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weatherData.forecast.length,
                    itemBuilder: (context, index) {
                      final forecast = weatherData.forecast[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(DateFormat('E').format(forecast.dateTime)),
                              getIcons(forecast.description),
                              Text("${forecast.temperature.toStringAsFixed(1)}°C"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
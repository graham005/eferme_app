import 'package:eferme_app/pages/weather/suggestions_page.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eferme_app/stateNotifierProviders/weather_state.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:eferme_app/utils/weather_utils.dart'; // Import the utility file

class WeatherPage extends ConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider);
    final notifier = ref.watch(weatherProvider.notifier);

    if (weatherData == null) {
      notifier.fetchWeatherAndForecast();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (weatherData != null)
                Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on),
                                    SizedBox(width: 4),
                                    Text(
                                      weatherData.cityName,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Lottie.asset(getAnimation(weatherData.description)),
                            Text(
                              "${weatherData.temperature.toStringAsFixed(1)}°C",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            Text(weatherData.description),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.water_drop),
                                    Text("Humidity"),
                                    Text("${weatherData.humidity}%")
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.wind_power),
                                    Text("Wind"),
                                    Text("${weatherData.windSpeed.toStringAsFixed(1)} km/h"),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "5-Day Forecast",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8),
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: _buildForecastList(weatherData.forecast),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("Farming Suggestions"),
                    SizedBox(height: 8),
                    _buildFarmingSuggestions(_generateFarmingSuggestions(weatherData))
                  ],
                )
              else
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForecastList(List<Forecast> forecast) {
    return forecast.map((forecastItem) {
      String dayOfWeek = DateFormat('E').format(forecastItem.dateTime);
      return Builder(
        builder: (context) => GestureDetector(
        onTap:() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthGuard(child: SuggestionPage(forecast: forecastItem))), // Replace WeatherDetailsPage() with your actual page
          );
        },
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayOfWeek,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  "${forecastItem.maxTemperature.toStringAsFixed(1)}°/${forecastItem.minTemperature.toStringAsFixed(1)}°",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                getIcons(forecastItem.description),
              ],
            ),
          ),
        ),
      ));
    }).toList();
  }

  Widget _buildFarmingSuggestions(List<String> suggestions) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Today's Suggestions"),
            Divider(),
            ...suggestions.map((suggestion) => ListTile(
                  title: Text(suggestion),
                )),
          ],
        ),
      ),
    );
  }

  List<String> _generateFarmingSuggestions(WeatherData weatherData) {
    List<String> suggestions = [];

    if (weatherData.temperature < 10) {
      suggestions.add("Its quite cold. Consider protecting plants from frost");
    } else if (weatherData.temperature > 25) {
      suggestions.add("Its quite hot. Consider watering plants more frequently");
    }
    if (weatherData.description.contains("rain")) {
      suggestions.add("Expected rain. Hold off on watering plants. Good condition for planting");
    } else {
      suggestions.add("No rain expected. Water plants as needed");
    }
    return suggestions;
  }

  String getAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'few clouds':
      case 'overcast clouds':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'clear':
      case 'clear sky':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }
}
import 'package:eferme_app/stateNotifierProviders/weather_state.dart';
import 'package:flutter/material.dart';
import 'package:eferme_app/utils/suggestions_utils.dart';

class SuggestionPage extends StatelessWidget {
  final Forecast forecast;

  const SuggestionPage({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forecast Suggestions"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${forecast.temperature.toStringAsFixed(1)}℃",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      forecast.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  "Suggestions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                ...getAllForecastSuggestions(forecast).map((suggestion) => ListTile(
                      title: Text(suggestion),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

Icon getIcons(String? mainCondition) {
  if (mainCondition == null) return Icon(Icons.sunny);

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
      return Icon(Icons.cloud, color: Colors.grey,);
    case 'rain':
    case 'drizzle':
    case 'shower rain':
      return Icon(Icons.shower, color: Colors.grey,);
    case 'thunderstorm':
      return Icon(Icons.flash_on, color: Colors.amber,);
    case 'clear':
    case 'clear sky':
      return Icon(Icons.wb_sunny, color: Colors.amber);
    default:
      return Icon(Icons.wb_sunny, color: Colors.amber);
  }
}
import '../stateNotifierProviders/weather_state.dart';

List<String> getAllSuggestions(WeatherData weatherData) {
  List<String> suggestions = [];

  if (weatherData.temperature > 25 &&  (
    weatherData.description.contains("clear") || 
    weatherData.description.contains("cloud") ||
    weatherData.description.contains("sun") ||
    weatherData.description.contains("overcast clouds") 
    )) {
    suggestions.addAll([
      "Irrigate crops early in the morning to reduce evaporation.",
      "Apply mulch to retain soil moisture.",
      "Plant drought-resistant crops.",
      "Provide shade for sensitive plants.",
      "Harvest heat-tolerant crops like tomatoes and peppers.",
      "Monitor for pests that thrive in hot weather.",
      "Water fruit trees deeply to prevent stress.",
      "Avoid fertilizing during peak heat to prevent burning plants.",
      "Use row covers to protect young plants from scorching sun.",
      "Schedule fieldwork for early morning or late afternoon to avoid heat exhaustion."
    ]);
  } else if (weatherData.temperature < 10) {
    suggestions.addAll([
      "Cover sensitive plants with frost blankets.",
      "Harvest frost-tolerant crops like Brussels sprouts and kale.",
      "Insulate outdoor water pipes to prevent freezing.",
      "Store harvested produce in frost-free areas.",
      "Plant winter wheat or barley.",
      "Use cold frames to extend the growing season.",
      "Protect beehives from freezing temperatures.",
      "Apply lime to soil to reduce acidity.",
      "Prune dormant trees and shrubs.",
      "Monitor livestock for signs of cold stress."
    ]);
  } else if (weatherData.description.contains("rain")) {
    suggestions.addAll([
      "Avoid tilling soil to prevent compaction.",
      "Plant rain-loving crops like rice or watercress.",
      "Harvest leafy greens before heavy rain damages them.",
      "Clear drainage ditches to prevent flooding.",
      "Apply organic fertilizers that benefit from rain absorption.",
      "Protect seedlings from heavy downpours with covers.",
      "Monitor for fungal diseases like mildew or blight.",
      "Delay planting if the soil is waterlogged.",
      "Store harvested crops in dry, ventilated areas.",
      "Check livestock shelters for leaks or flooding."
    ]);
  } else if (weatherData.description.contains("storm") || weatherData.description.contains("wind")) {
    suggestions.addAll([
      "Secure loose equipment and tools.",
      "Harvest ripe crops to prevent wind damage.",
      "Reinforce greenhouse structures.",
      "Tie down or stake tall plants to prevent breakage.",
      "Move livestock to sheltered areas.",
      "Avoid working outdoors during severe storms.",
      "Inspect fences for damage after the storm passes.",
      "Prune damaged branches from trees post-storm.",
      "Cover compost piles to prevent nutrient loss.",
      "Check for soil erosion and take corrective measures."
    ]);
  } else if (weatherData.description.contains("humid")) {
    suggestions.addAll([
      "Monitor for mold and mildew on crops.",
      "Harvest crops early to prevent spoilage.",
      "Increase airflow in greenhouses.",
      "Apply fungicides if necessary.",
      "Plant humidity-tolerant crops like okra or sweet potatoes.",
      "Avoid overwatering to prevent root rot.",
      "Inspect stored grains for moisture damage.",
      "Use fans to dry harvested crops.",
      "Prune dense foliage to improve air circulation.",
      "Check livestock for heat stress and provide ventilation."
    ]);
  } else if (weatherData.description.contains("dry") && weatherData.description.contains("wind")) {
    suggestions.addAll([
      "Water crops deeply to reach root zones.",
      "Use windbreaks to protect fields.",
      "Plant wind-tolerant crops like sorghum or millet.",
      "Avoid burning debris to prevent wildfires.",
      "Apply soil amendments to retain moisture.",
      "Harvest grains before they dry out too much.",
      "Cover bare soil with straw or mulch.",
      "Monitor for dust-related crop damage.",
      "Reduce tillage to prevent soil erosion.",
      "Provide extra water for livestock."
    ]);
  } else {
    suggestions.add("No specific suggestions for the current weather.");
  }

  return suggestions;
}

List<String> getAllForecastSuggestions(Forecast forecast) {
  List<String> suggestions = [];

  if (forecast.temperature > 25 && (
    forecast.description.contains("clear",) || 
    forecast.description.contains("cloud") ||
    forecast.description.contains("sun") ||
    forecast.description.contains("overcast clouds") 
    )) {
    suggestions.addAll([
      "Irrigate crops early in the morning to reduce evaporation.",
      "Apply mulch to retain soil moisture.",
      "Plant drought-resistant crops.",
      "Provide shade for sensitive plants.",
      "Harvest heat-tolerant crops like tomatoes and peppers.",
      "Monitor for pests that thrive in hot weather.",
      "Water fruit trees deeply to prevent stress.",
      "Avoid fertilizing during peak heat to prevent burning plants.",
      "Use row covers to protect young plants from scorching sun.",
      "Schedule fieldwork for early morning or late afternoon to avoid heat exhaustion."
    ]);
  } else if (forecast.temperature < 10) {
    suggestions.addAll([
      "Cover sensitive plants with frost blankets.",
      "Harvest frost-tolerant crops like Brussels sprouts and kale.",
      "Insulate outdoor water pipes to prevent freezing.",
      "Store harvested produce in frost-free areas.",
      "Plant winter wheat or barley.",
      "Use cold frames to extend the growing season.",
      "Protect beehives from freezing temperatures.",
      "Apply lime to soil to reduce acidity.",
      "Prune dormant trees and shrubs.",
      "Monitor livestock for signs of cold stress."
    ]);
  } else if (forecast.description.contains("rain")) {
    suggestions.addAll([
      "Avoid tilling soil to prevent compaction.",
      "Plant rain-loving crops like rice or watercress.",
      "Harvest leafy greens before heavy rain damages them.",
      "Clear drainage ditches to prevent flooding.",
      "Apply organic fertilizers that benefit from rain absorption.",
      "Protect seedlings from heavy downpours with covers.",
      "Monitor for fungal diseases like mildew or blight.",
      "Delay planting if the soil is waterlogged.",
      "Store harvested crops in dry, ventilated areas.",
      "Check livestock shelters for leaks or flooding."
    ]);
  } else if (forecast.description.contains("storm") || forecast.description.contains("wind")) {
    suggestions.addAll([
      "Secure loose equipment and tools.",
      "Harvest ripe crops to prevent wind damage.",
      "Reinforce greenhouse structures.",
      "Tie down or stake tall plants to prevent breakage.",
      "Move livestock to sheltered areas.",
      "Avoid working outdoors during severe storms.",
      "Inspect fences for damage after the storm passes.",
      "Prune damaged branches from trees post-storm.",
      "Cover compost piles to prevent nutrient loss.",
      "Check for soil erosion and take corrective measures."
    ]);
  } else if (forecast.description.contains("humid")) {
    suggestions.addAll([
      "Monitor for mold and mildew on crops.",
      "Harvest crops early to prevent spoilage.",
      "Increase airflow in greenhouses.",
      "Apply fungicides if necessary.",
      "Plant humidity-tolerant crops like okra or sweet potatoes.",
      "Avoid overwatering to prevent root rot.",
      "Inspect stored grains for moisture damage.",
      "Use fans to dry harvested crops.",
      "Prune dense foliage to improve air circulation.",
      "Check livestock for heat stress and provide ventilation."
    ]);
  } else if (forecast.description.contains("dry") && forecast.description.contains("wind")) {
    suggestions.addAll([
      "Water crops deeply to reach root zones.",
      "Use windbreaks to protect fields.",
      "Plant wind-tolerant crops like sorghum or millet.",
      "Avoid burning debris to prevent wildfires.",
      "Apply soil amendments to retain moisture.",
      "Harvest grains before they dry out too much.",
      "Cover bare soil with straw or mulch.",
      "Monitor for dust-related crop damage.",
      "Reduce tillage to prevent soil erosion.",
      "Provide extra water for livestock."
    ]);
  } else {
    suggestions.add("No specific suggestions for the next day's weather.");
  }

  return suggestions;
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the DiseaseState model
class DiseaseState {
  String disease;
  List<String> remedies;

  DiseaseState({this.disease = '', this.remedies = const []});
}

// Define the DiseaseStateNotifier class
class DiseaseStateNotifier extends StateNotifier<DiseaseState> {
  DiseaseStateNotifier() : super(DiseaseState());

  void setDisease(String disease) {
    // Update the disease state
    state = DiseaseState(
      disease: disease,
      remedies: generateRemedies(disease),
    );
  }

  // Generate remedies based on detected disease
  List<String> generateRemedies(String disease) {
    switch (disease) {
      case 'common rust':
        return [
          'Remove infected leaves from the plant',
          'Apply fungicides specifically designed to target rust fungi',
        ];
      case 'leaf blight':
        return [
          'Remove infected leaves from the plant',
          'Apply fungicide to the plant',
        ];
      case 'gray leaf spot':
        return [
          'Remove infected leaves from the plant',
          'Apply fungicide to the plant',
        ];
      case 'ear rot':
        return [
          'Dry harvested grain quickly to less than 13% moisture and store it in cool conditions below 30 degrees F to limit fungal growth and mycotoxin accumulation',
          'Store moldy or mycotoxin-contaminated grain separately from clean grain',
        ];
      case 'stem borer':
        return [
          'Remove infected leaves from the plant',
          'Apply ash dust into the leaf funnel of young plants',
        ];
      case 'healthy':
        return ['No remedies needed'];
      default:
        return ['No remedies needed'];
    }
  }
}

final diseaseStateProvider = StateNotifierProvider<DiseaseStateNotifier, DiseaseState>((ref) {
  return DiseaseStateNotifier();
});
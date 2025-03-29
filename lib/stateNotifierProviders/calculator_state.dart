import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorState {
  final double landSize;
  final String cropType;
  final String fertilizerType;
  final double seedRequirement;
  final double fertilizerRequirement;

  CalculatorState({
    this.landSize = 0.0,
    this.cropType = '',
    this.fertilizerType = '',
    this.seedRequirement = 0.0,
    this.fertilizerRequirement = 0.0,
  });

  CalculatorState copyWith({
    double? landSize,
    String? cropType,
    String? fertilizerType,
    double? seedRequirement,
    double? fertilizerRequirement,
  }) {
    return CalculatorState(
      landSize: landSize ?? this.landSize,
      cropType: cropType ?? this.cropType,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      seedRequirement: seedRequirement ?? this.seedRequirement,
      fertilizerRequirement: fertilizerRequirement ?? this.fertilizerRequirement,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState());

  void setLandSize(double value) {
    state = state.copyWith(landSize: value);
  }

  void setCropType(String value) {
    state = state.copyWith(cropType: value);
  }

  void setFertilizerType(String value) {
    state = state.copyWith(fertilizerType: value);
  }

  void setSeedRequirement(double value) {
    state = state.copyWith(seedRequirement: value);
  }

  void setFertilizerRequirement(double value) {
    state = state.copyWith(fertilizerRequirement: value);
  }
}

final caculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
import 'package:eferme_app/stateNotifierProviders/calculator_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  bool _isLoading = false; // State to track loading

  Future<void> _calculateRequirements(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Simulate a delay (e.g., 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    final calculatorState = ref.read(caculatorProvider);
    final notifier = ref.read(caculatorProvider.notifier);

    // Calculate the amount of seed and fertilizer needed
    double landSize = calculatorState.landSize;
    String cropType = calculatorState.cropType;
    String fertilizerType = calculatorState.fertilizerType;

    // Seed and fertilizer requirements per acre
    const Map<String, double> seedRequirements = {
      'Maize': 10, // kg per acre
      'Beans': 30, // kg per acre
      'Groundnuts': 16, // kg per acre
      'Peas': 30, // kg per acre
      'Rice': 24, // kg per acre
    };

    const Map<String, double> fertilizerRequirements = {
      'DAP': 50, // kg per acre
      'CAN': 50, // kg per acre
      'NPK': 100, // kg per acre
      'Urea': 75, // kg per acre
    };

    double? seedRequiredPerAcre = seedRequirements[cropType];
    double? fertilizerRequiredPerAcre = fertilizerRequirements[fertilizerType];

    double totalSeedRequired =
        seedRequiredPerAcre != null ? seedRequiredPerAcre * landSize : 0.0;
    double totalFertilizerRequired =
        fertilizerRequiredPerAcre != null ? fertilizerRequiredPerAcre * landSize : 0.0;

    notifier.setSeedRequirement(totalSeedRequired);
    notifier.setFertilizerRequirement(totalFertilizerRequired);

    setState(() {
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final calculatorState = ref.watch(caculatorProvider);
    final notifier = ref.read(caculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Farm Calculator',
            style: TextStyle(fontWeight: FontWeight.bold),
            
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        double? size = double.tryParse(value);
                        if (size != null) {
                          notifier.setLandSize(size);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Land Size',
                        suffixText: 'Acres',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: DropdownButtonFormField(
                  value: calculatorState.cropType.isNotEmpty
                      ? calculatorState.cropType
                      : null,
                  items: const [
                    DropdownMenuItem(value: 'Maize', child: Text('Maize')),
                    DropdownMenuItem(value: 'Beans', child: Text('Beans')),
                    DropdownMenuItem(value: 'Groundnuts', child: Text('Groundnuts')),
                    DropdownMenuItem(value: 'Peas', child: Text('Peas')),
                    DropdownMenuItem(value: 'Rice', child: Text('Rice')),
                  ],
                  onChanged: (String? newValue) {
                    notifier.setCropType(newValue!); 
                  },
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: DropdownButtonFormField(
                  value: calculatorState.fertilizerType.isNotEmpty
                      ? calculatorState.fertilizerType
                      : null,
                  items: const [
                    DropdownMenuItem(value: 'DAP', child: Text('DAP')),
                    DropdownMenuItem(value: 'CAN', child: Text('CAN')),
                    DropdownMenuItem(value: 'NPK', child: Text('NPK')),
                    DropdownMenuItem(value: 'Urea', child: Text('Urea')),
                  ],
                  onChanged: (String? newValue) {
                    notifier.setFertilizerType(newValue!); 
                  },
                  decoration: const InputDecoration(
                    labelText: 'Fertilizer Type',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button while loading
                      : () => _calculateRequirements(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0, // Remove shadow
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'Calculate Requirements',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seed Required: '),
                  Text(
                    "${calculatorState.seedRequirement.toStringAsFixed(2)} kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fertilizer Required: '),
                  Text(
                    "${calculatorState.fertilizerRequirement.toStringAsFixed(2)} kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
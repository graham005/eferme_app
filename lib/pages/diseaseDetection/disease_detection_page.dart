import 'package:eferme_app/stateNotifierProviders/disease_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  _DiseaseDetectionPageState createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isProcessing = false;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  late AnimationController _animationController;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), 
    );

    _animationController.addListener(() {
      _progress.value = _animationController.value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final diseaseState = ref.watch(diseaseStateProvider);

        return Scaffold(
          appBar: AppBar(
            title: Center(child: const Text('Maize Disease Detection', 
            style: TextStyle(fontWeight: FontWeight.bold),)),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Upload a photo to identify plant diseases.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text('Take a photo or upload from gallery', style: TextStyle(color: Colors.grey
                      , fontSize: 16, fontWeight: FontWeight.w300)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                        final pickedImage = await _picker.pickImage(source: ImageSource.camera);
                        if (pickedImage != null) {
                          setState(() {
                            _selectedImage = pickedImage;
                            _errorMessage = '';
                          });
                          ref.read(diseaseStateProvider.notifier).setDisease('');
                          await _processImage(pickedImage.path, ref);
                        }
                        },
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        label: Text('Camera', style: TextStyle(color: Colors.white,)),
                        style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                        final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            _selectedImage = pickedImage;
                            _errorMessage = '';
                          });
                          ref.read(diseaseStateProvider.notifier).setDisease('');
                          await _processImage(pickedImage.path, ref);
                        }
                        },
                        icon: Icon(Icons.photo_library, color: Colors.white),
                        label: Text('Gallery', style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                        ),
                      ),
                      ],
                    ),
                    ],
                  ),
                  ),
                ),
                SizedBox(height: 20),
                if (_selectedImage != null)
                  Column(
                    children: [
                      Image.file(
                        File(_selectedImage!.path),
                        height: 200,
                      ),
                      if (_isProcessing)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ValueListenableBuilder<double>(
                            valueListenable: _progress,
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 15,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '$_errorMessage 😥' ,
                    style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  ),
                if (diseaseState.disease.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detected Disease', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black)),
                        Card(
                        color: Colors.amber.shade50,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                            diseaseState.disease,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ),
                        ),
                        ),
                      SizedBox(height: 10),
                      Text('Quick Remedies:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ...diseaseState.remedies.map((remedy) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                                children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 5),
                                Expanded(
                                  child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(' $remedy', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: 10),
                      Card(
                        color: Colors.green,
                        child: Center(
                          child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature under Maintenance')));
                          },
                          icon: Icon(Icons.list, color: Colors.white),
                          label: Text('View Detailed Remedies', style: TextStyle(color: Colors.white
                          , fontWeight: FontWeight.bold)),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                            elevation: WidgetStateProperty.all<double>(0),
                          ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<File> resizeImage(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);
      final resizedImageBytes = img.encodeJpg(resizedImage);
      final resizedImageFile = File(imagePath)..writeAsBytesSync(resizedImageBytes);
      return resizedImageFile;
    }
    return imageFile;
  }

  Future<void> _processImage(String imagePath, WidgetRef ref) async {
    setState(() {
      _isProcessing = true;
      _progress.value = 0.0;
      _animationController.reset();
      _animationController.forward();
    });
    try {
      final resizedImageFile = await resizeImage(imagePath);
      final prediction = await loadAndRunModel(imagePath);
        
        if (prediction.isNotEmpty) {
          print('Prediction: ${prediction[0]['label']}');
          ref.read(diseaseStateProvider.notifier).setDisease(prediction[0]['label']);
        } else {
          print('No prediction found');
          setState(() {
            _errorMessage = 'Enter a valid image';
          });
    }
    } catch (e) {
      print('Error processing image: $e');
      setState((){
        _errorMessage = 'An error occurred while processing the image';
      });
    } finally {
        setState(() {
          _isProcessing = false;
          _animationController.stop();
        });
    }
  }

  Future<List<dynamic>> loadAndRunModel(String imagePath) async {
    try {
      // Load the model
      String? modelLoaded = await Tflite.loadModel(
        model: 'assets/model.tflite',
        labels: 'assets/labels.txt',
      );
      if (modelLoaded == null) {
        print('Failed to load model');
        return [];
      }

      // Run inference on image
      var output = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 7,
        threshold: 0.6,
      );

      print('Model output: $output');
      return output ?? [];
    } catch (e) {
      print('Error loading or running model: $e');
      return [];
    } finally {
      // Unload the model
      unLoadModel();
    }
  }

  void unLoadModel() {
    Tflite.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore import

class IVPage extends StatefulWidget {
  const IVPage({super.key});

  @override
  _IVPageState createState() => _IVPageState();
}

class _IVPageState extends State<IVPage> {
  double glucoseLevel = 700; // Initial glucose level
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize audio player
  final double totalVolume = 1000; // Total volume in ml
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();
    _getGlucoseLevelFromFirestore(); // Fetch glucose level from Firebase Firestore
  }

  // Method to fetch glucose level from Firestore
  Future<void> _getGlucoseLevelFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('iv_drips').doc('glucose_data').get();
      if (snapshot.exists) {
        setState(() {
          glucoseLevel = snapshot['glucoseLevel'].toDouble(); // Retrieve the stored glucose level
        });
        _checkGlucoseLevel(); // Check the glucose level after retrieving it
      }
    } catch (e) {
      print("Error fetching glucose level: $e");
    }
  }

  // Method to save glucose level to Firestore
  Future<void> _saveGlucoseLevelToFirestore(double level) async {
    try {
      await _firestore.collection('iv_drips').doc('glucose_data').set({
        'glucoseLevel': level, // Save glucose level
      });
      print('Glucose level saved successfully.');
    } catch (e) {
      print("Error saving glucose level: $e");
    }
  }

  // Check glucose level and show alert if too low
  void _checkGlucoseLevel() {
    if (glucoseLevel < 50) {
      _showAlert();
    }
  }

  // Display alert for low glucose level
  void _showAlert() {
    _playAlarm(); // Play alarm sound
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Glucose level is below 50 ml!'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _stopAlarm(); // Stop alarm when dialog is closed
              },
            ),
          ],
        );
      },
    );
  }

  // Play alarm sound
  void _playAlarm() async {
    await _audioPlayer.setSource(AssetSource('alarm.mp3')); // Play the audio
    _audioPlayer.setVolume(1.0); // Set volume to max
    _audioPlayer.resume(); // Start playing

    // Stop the alarm after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _stopAlarm(); // Stop the alarm
    });
  }

  // Stop alarm sound
  void _stopAlarm() {
    _audioPlayer.stop(); // Stop playing the audio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IV Drip Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 400, // Height of the bottle display
                    width: 250,  // Width of the bottle display
                    child: Cube(
                      onSceneCreated: (Scene scene) {
                        scene.world.add(
                          Object(
                            fileName: 'assets/models/glucose_bottle.obj', // Path to your model
                            scale: vm.Vector3(2.0, 2.0, 2.0), // Scale the bottle
                          ),
                        );
                        scene.camera.position.z = 5; // Position the camera
                      },
                    ),
                  ),
                  // Fluid level representation
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 400 * (glucoseLevel / totalVolume), // Adjust height based on glucose level
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.6), // Fluid color
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), // Rounded top
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Level indicator text
              const Text(
                'Glucose Level (ml):',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),

              // TextField for user input
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Glucose level in ml',
                ),
                onSubmitted: (String value) {
                  double? level = double.tryParse(value);
                  if (level != null && level <= totalVolume) {
                    setState(() {
                      glucoseLevel = level; // Set the glucose level in ml
                      _saveGlucoseLevelToFirestore(level); // Save the level to Firestore
                      _checkGlucoseLevel(); // Check if the level is below 50 ml
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Display ml value
              Text(
                '${glucoseLevel.toInt()} ml', // Display ml value
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

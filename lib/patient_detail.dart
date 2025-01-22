import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class PatientDetailPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  PatientDetailPage({required this.patient});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  double glucoseLevel = 0; // Initial glucose level
  final double maxGlucoseLevel = 1000; // Maximum glucose level
  final AudioPlayer audioPlayer = AudioPlayer(); // Create an instance of AudioPlayer

  // Function to update glucose level
  void updateGlucoseLevel(double newLevel) {
    setState(() {
      glucoseLevel = newLevel;
      // Check for alert conditions
      _checkGlucoseLevel();
    });
  }

  void _checkGlucoseLevel() {
    if (glucoseLevel < 50) {
      // Show alert notification
      _showAlertNotification();
      // Play alarm if glucose level is critically low
      _playAlarm(); // Play the alarm
    }
  }

  void _playAlarm() async {
    await audioPlayer.setSource(AssetSource('alarm.mp3')); // Set the source to the asset
    await audioPlayer.resume(); // Play the audio
    // Stop the audio after 3 seconds
    Timer(Duration(seconds: 3), () {
      audioPlayer.stop(); // Stop the alarm after 3 seconds
    });
  }

  void _showAlertNotification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text('Glucose level is critically low! Please check immediately.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK', style: TextStyle(color: Colors.teal.shade600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientPhoto(),
              SizedBox(height: 20),
              _buildDetailCard(),
              SizedBox(height: 20),
              // Bottle Representation
              _buildBottleRepresentation(),
              SizedBox(height: 20),
              _buildGlucoseLevelText(),
              SizedBox(height: 20),
              // Input field to update glucose level
              _buildGlucoseInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientPhoto() {
    return Center(
      child: widget.patient['photo'] != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(75),
        child: Image.network(
          widget.patient['photo'],
          height: 150,
          width: 150,
          fit: BoxFit.cover,
        ),
      )
          : Icon(Icons.person, size: 150, color: Colors.teal.shade600),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${widget.patient['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade600),
            ),
            SizedBox(height: 10),
            Text('Age: ${widget.patient['age'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Place: ${widget.patient['place'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Address: ${widget.patient['address'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Disease: ${widget.patient['disease'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Doctor: ${widget.patient['doctor'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleRepresentation() {
    return Center(
      child: Container(
        height: 200, // Height of the bottle
        width: 100, // Width of the bottle
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal.shade600, width: 2), // Use shade600 to ensure non-null color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: glucoseLevel / maxGlucoseLevel * 200, // Height based on glucose level
              width: 100,
              decoration: BoxDecoration(
                color: Colors.blue[300], // Color of the liquid
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlucoseLevelText() {
    return Center(
      child: Text(
        'Glucose Level: ${glucoseLevel.toStringAsFixed(1)} ml',
        style: TextStyle(fontSize: 20, color: Colors.teal.shade600),
      ),
    );
  }

  Widget _buildGlucoseInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Enter Glucose Level (ml)',
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade600, width: 2), // Use shade600 here as well
          ),
        ),
        keyboardType: TextInputType.number,
        onSubmitted: (value) {
          double? newLevel = double.tryParse(value);
          if (newLevel != null) {
            updateGlucoseLevel(newLevel);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'add_patient.dart';
import 'patient_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Function to update the switch state in Firestore for a single patient
  Future<void> _updatePatientStatus(String selectedPatientId) async {
    try {
      // Begin a batch operation to ensure atomic updates
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Get all patients in the collection
      QuerySnapshot patientsSnapshot = await FirebaseFirestore.instance.collection('patients').get();

      // Update each patient's status
      for (var doc in patientsSnapshot.docs) {
        bool isSelected = (doc.id == selectedPatientId);
        batch.update(doc.reference, {'isMonitoringEnabled': isSelected});
      }

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Error updating patient status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            SizedBox(width: 10),
            Text(
              'NeuVitX',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Allow scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome to NeuVitX!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Patients',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),

              // StreamBuilder for fetching patients
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('patients').snapshots(),
                builder: (context, snapshot) {
                  // Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Handle error state
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final patients = snapshot.data!.docs;

                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(), // Prevent scrolling of grid view
                    shrinkWrap: true, // Allow grid view to take only the space it needs
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Adjust aspect ratio as needed
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      var patient = patients[index].data() as Map<String, dynamic>;
                      bool isMonitoringEnabled = patient['isMonitoringEnabled'] ?? false;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to the detail page of the patient
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailPage(patient: patient),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(75),
                                  child: patient['photo'] != null
                                      ? Image.network(
                                    patient['photo'],
                                    height: 75,
                                    width: 75,
                                    fit: BoxFit.cover,
                                  )
                                      : Icon(Icons.person, size: 75, color: Colors.deepPurple),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  patient['name'] ?? 'Unknown Name',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'ID: ${patients[index].id}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  patient['place'] ?? 'Unknown Place',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                SwitchListTile(
                                  title: Text('NVX'),
                                  value: isMonitoringEnabled,
                                  onChanged: (bool value) {
                                    if (value) {
                                      _updatePatientStatus(patients[index].id); // Update Firestore
                                    }
                                  },
                                  activeColor: Colors.deepPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddPatient page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPatientPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/main'); // Navigate to main.dart
    } catch (e) {
      print('Logout error: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String place = '';
  String address = '';
  String disease = '';
  String doctor = '';
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      _formKey.currentState!.save();

      // Create a unique patient ID
      final patientId = 'NVX${DateTime.now().millisecondsSinceEpoch}';

      // Save patient data to Firestore
      await FirebaseFirestore.instance.collection('patients').doc(patientId).set({
        'name': name,
        'age': age,
        'place': place,
        'address': address,
        'disease': disease,
        'doctor': doctor,
        'photo': null, // Initially set to null; will update after image upload
      });

      // Navigate back to the home page immediately
      Navigator.pop(context);

      // Now upload the image to Firebase Storage in the background
      final storageRef = FirebaseStorage.instance.ref().child('patient_images/$patientId');
      await storageRef.putFile(_image!).whenComplete(() async {
        String photoUrl = await storageRef.getDownloadURL();
        // Update the Firestore document with the image URL
        await FirebaseFirestore.instance.collection('patients').doc(patientId).update({
          'photo': photoUrl,
        });
      });

      // Clear the fields after adding patient
      _clearFields();

      // Show success message (optional, can be displayed in the home page)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient added successfully!')),
      );
    }
  }

  void _clearFields() {
    setState(() {
      name = '';
      age = 0;
      place = '';
      address = '';
      disease = '';
      doctor = '';
      _image = null;
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Information',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),

                // Patient Name
                _buildTextField(
                  label: 'Name',
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => name = value!,
                ),

                // Patient Age
                _buildTextField(
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter an age' : null,
                  onSaved: (value) => age = int.parse(value!),
                ),

                // Patient Place
                _buildTextField(
                  label: 'Place',
                  validator: (value) => value!.isEmpty ? 'Please enter a place' : null,
                  onSaved: (value) => place = value!,
                ),

                // Patient Address
                _buildTextField(
                  label: 'Address',
                  validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                  onSaved: (value) => address = value!,
                ),

                // Patient Disease
                _buildTextField(
                  label: 'Disease',
                  validator: (value) => value!.isEmpty ? 'Please enter a disease' : null,
                  onSaved: (value) => disease = value!,
                ),

                // Patient Doctor
                _buildTextField(
                  label: 'Doctor',
                  validator: (value) => value!.isEmpty ? 'Please enter a doctor\'s name' : null,
                  onSaved: (value) => doctor = value!,
                ),

                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    ),
                    child: Center(child: Text('Tap to select an image', style: TextStyle(color: Colors.deepPurple))),
                  )
                      : Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Add Patient Button
                ElevatedButton(
                  onPressed: _addPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Updated parameter
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(child: Text('Add Patient', style: TextStyle(fontSize: 20))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String? Function(String?)? validator, Function(String?)? onSaved, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
          labelStyle: TextStyle(color: Colors.deepPurple),
        ),
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
      ),
    );
  }
}

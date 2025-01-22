// lib/models/patient.dart
class Patient {
  final String name;
  final int age;
  final String place;
  final String address;
  final String disease;
  final String doctor;
  final String photo;

  Patient({
    required this.name,
    required this.age,
    required this.place,
    required this.address,
    required this.disease,
    required this.doctor,
    required this.photo,
  });

  // Method to convert the Patient object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'place': place,
      'address': address,
      'disease': disease,
      'doctor': doctor,
      'photo': photo,
    };
  }

  // Optional: A method to create a Patient from a Map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      name: map['name'],
      age: map['age'],
      place: map['place'],
      address: map['address'],
      disease: map['disease'],
      doctor: map['doctor'],
      photo: map['photo'],
    );
  }
}

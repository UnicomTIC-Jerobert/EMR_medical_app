import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

class PatientRepository {
  final List<Patient> _mockDb = [
    Patient(
      id: 'P-1001',
      fullName: 'Robert Chen',
      mobile: '9876543210',
      dob: '1985-06-14',
      gender: 'Male',
      bloodGroup: 'O+',
      allergies: 'Penicillin',
      address: '42 Elm Street, Springfield',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    Patient(
      id: 'P-1002',
      fullName: 'Sarah Jenkins',
      mobile: '9845123456',
      dob: '1992-11-23',
      gender: 'Female',
      bloodGroup: 'A+',
      allergies: null,
      address: '109 Baker Avenue, Springfield',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Patient(
      id: 'P-1003',
      fullName: 'David Miller',
      mobile: '9789012345',
      dob: '1978-02-04',
      gender: 'Male',
      bloodGroup: 'B-',
      allergies: 'Sulfa drugs',
      address: '12 Riverbank Road',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// Multi-attribute search simulating SQLite index lookup
  Future<List<Patient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final cleanQ = query.trim().toLowerCase();
    if (cleanQ.length < 2) return [];

    return _mockDb.where((p) {
      final nameMatch = p.fullName.toLowerCase().contains(cleanQ);
      final mobileMatch = p.mobile.contains(cleanQ);
      final dobMatch = p.dob.contains(cleanQ);
      return nameMatch || mobileMatch || dobMatch;
    }).toList();
  }

  Future<Patient> createPatient({
    required String fullName,
    required String mobile,
    required String dob,
    required String gender,
    required String bloodGroup,
    String? allergies,
    String? address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newPatient = Patient(
      id: 'P-${1000 + _mockDb.length + 1}',
      fullName: fullName,
      mobile: mobile,
      dob: dob,
      gender: gender,
      bloodGroup: bloodGroup,
      allergies: allergies?.trim().isEmpty == true ? null : allergies,
      address: address?.trim().isEmpty == true ? null : address,
      createdAt: DateTime.now(),
    );

    _mockDb.insert(0, newPatient);
    return newPatient;
  }
}

class PrescriptionItem {
  final String id;
  final int medicineId;
  final String medicineName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String instructions;

  PrescriptionItem({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.instructions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'durationDays': durationDays,
        'instructions': instructions,
      };
}

/// Represents the SQLite JSON column: clinical_data
class ClinicalData {
  final String bp;
  final String pulse;
  final String temperature;
  final String weight;
  final String spo2;
  final Map<String, String> customNotes; // Dynamic NoSQL attributes

  ClinicalData({
    required this.bp,
    required this.pulse,
    required this.temperature,
    required this.weight,
    required this.spo2,
    required this.customNotes,
  });

  Map<String, dynamic> toJson() => {
        'bp': bp,
        'pulse': pulse,
        'temperature': temperature,
        'weight': weight,
        'spo2': spo2,
        'customNotes': customNotes,
      };
}

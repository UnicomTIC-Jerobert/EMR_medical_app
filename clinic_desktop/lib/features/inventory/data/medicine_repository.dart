import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';

final medicineRepositoryProvider =
    ChangeNotifierProvider<MedicineRepository>((ref) {
  return MedicineRepository();
});

class MedicineRepository extends ChangeNotifier {
  final List<Medicine> _medicines = [
    Medicine(
      id: 1,
      brandName: 'Dolo 650',
      genericName: 'Paracetamol',
      stockQty: 240,
      unitPrice: 2.5,
      category: 'Antipyretic / Analgesic',
      symptoms: ['fever', 'headache', 'body pain', 'mild fever', 'temperature'],
    ),
    Medicine(
      id: 2,
      brandName: 'Augmentin 625 Duo',
      genericName: 'Amoxicillin + Clavulanic Acid',
      stockQty: 45,
      unitPrice: 18.0,
      category: 'Antibiotic',
      symptoms: [
        'bacterial infection',
        'throat infection',
        'sinusitis',
        'ear pain',
        'tonsils'
      ],
    ),
    Medicine(
      id: 3,
      brandName: 'Pan 40',
      genericName: 'Pantoprazole',
      stockQty: 180,
      unitPrice: 8.5,
      category: 'Antacid / PPI',
      symptoms: [
        'acidity',
        'gerd',
        'heartburn',
        'stomach burning',
        'gastric ulcer'
      ],
    ),
    Medicine(
      id: 4,
      brandName: 'Allegra 120mg',
      genericName: 'Fexofenadine',
      stockQty: 85,
      unitPrice: 12.0,
      category: 'Antihistamine',
      symptoms: ['allergy', 'sneezing', 'runny nose', 'skin rash', 'itching'],
    ),
    Medicine(
      id: 5,
      brandName: 'Azithral 500',
      genericName: 'Azithromycin',
      stockQty: 12,
      unitPrice: 22.0,
      category: 'Antibiotic',
      symptoms: [
        'chest infection',
        'bronchitis',
        'severe cough',
        'throat ache'
      ],
    ),
  ];

  List<Medicine> get medicines => List.unmodifiable(_medicines);

  Future<List<Medicine>> semanticSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    return _medicines.where((m) {
      final brandMatch = m.brandName.toLowerCase().contains(q);
      final genericMatch = m.genericName.toLowerCase().contains(q);
      final symptomMatch =
          m.symptoms.any((s) => s.contains(q) || q.contains(s));
      return brandMatch || genericMatch || symptomMatch;
    }).toList();
  }

  void deductStock(int medicineId, int quantity) {
    final med = _medicines.firstWhere((m) => m.id == medicineId,
        orElse: () => throw Exception('Not found'));
    med.stockQty = (med.stockQty - quantity).clamp(0, 999999);
    notifyListeners();
  }

  void addStock(int medicineId, int delta) {
    final med = _medicines.firstWhere((m) => m.id == medicineId);
    med.stockQty += delta;
    notifyListeners();
  }

  void createMedicine({
    required String brandName,
    required String genericName,
    required String category,
    required int stockQty,
    required double unitPrice,
    required List<String> symptoms,
  }) {
    final newId = _medicines.isNotEmpty
        ? _medicines.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    final newMed = Medicine(
      id: newId,
      brandName: brandName,
      genericName: genericName,
      stockQty: stockQty,
      unitPrice: unitPrice,
      category: category,
      symptoms: symptoms,
    );
    _medicines.insert(0, newMed);
    notifyListeners();
  }
}

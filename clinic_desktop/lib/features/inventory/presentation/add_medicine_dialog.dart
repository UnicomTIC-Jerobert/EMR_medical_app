import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medicine_repository.dart';

class AddMedicineDialog extends ConsumerStatefulWidget {
  const AddMedicineDialog({super.key});

  @override
  ConsumerState<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends ConsumerState<AddMedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _genericController = TextEditingController();
  final _stockController = TextEditingController(text: '100');
  final _priceController = TextEditingController(text: '10.0');
  final _symptomsController = TextEditingController();

  String _category = 'Antibiotic';

  @override
  void dispose() {
    _brandController.dispose();
    _genericController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final symptoms = _symptomsController.text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    ref.read(medicineRepositoryProvider).createMedicine(
          brandName: _brandController.text.trim(),
          genericName: _genericController.text.trim(),
          category: _category,
          stockQty: int.tryParse(_stockController.text) ?? 50,
          unitPrice: double.tryParse(_priceController.text) ?? 5.0,
          symptoms: symptoms,
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New medicine added to inventory!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: AppColors.bgSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        FaIcon(FontAwesomeIcons.circlePlus,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text("Add Medicine to Inventory",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                            labelText: "Brand Name *",
                            hintText: "e.g. Zithromax 500"),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _genericController,
                        decoration: const InputDecoration(
                            labelText: "Generic Chemical Name *",
                            hintText: "e.g. Azithromycin"),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration:
                            const InputDecoration(labelText: "Category"),
                        items: [
                          'Antibiotic',
                          'Antipyretic / Analgesic',
                          'Antacid / PPI',
                          'Antihistamine',
                          'Antihypertensive',
                          'Antidiabetic',
                          'Vitamin / Supplement',
                        ]
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "Initial Stock Units"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: "Unit Price (\$)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _symptomsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Semantic Keywords & Symptoms (Comma-separated)",
                    hintText:
                        "e.g. bacterial throat infection, severe cough, bronchitis, tonsil pain",
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Doctors typing any of these symptoms will immediately match this medicine in the consultation table.",
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: _handleSave,
                        child: const Text("Save to Inventory")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

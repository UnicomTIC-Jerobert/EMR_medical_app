import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../patients/models/patient.dart';
import '../../inventory/data/medicine_repository.dart';
import '../../inventory/models/medicine.dart';
import '../models/visit_models.dart';
import 'prescription_pdf_dialog.dart';

/// Helper state class to hold controllers for dynamic prescription rows
class PrescriptionRowState {
  final String id;
  final TextEditingController medicineController;
  final TextEditingController dosageController;
  final TextEditingController durationController;
  final TextEditingController instructionsController;
  Medicine? selectedMedicine;
  String frequency;

  PrescriptionRowState({
    required this.id,
    required this.medicineController,
    required this.dosageController,
    required this.durationController,
    required this.instructionsController,
    this.selectedMedicine,
    this.frequency = '1-0-1',
  });

  void dispose() {
    medicineController.dispose();
    dosageController.dispose();
    durationController.dispose();
    instructionsController.dispose();
  }
}

/// Helper class for dynamic NoSQL key-value observation pairs
class CustomParamState {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;

  CustomParamState({
    required this.id,
    required this.keyController,
    required this.valueController,
  });

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class ConsultationView extends ConsumerStatefulWidget {
  final Patient patient;
  final VoidCallback onFinalized;

  const ConsultationView({
    super.key,
    required this.patient,
    required this.onFinalized,
  });

  @override
  ConsumerState<ConsultationView> createState() => _ConsultationViewState();
}

class _ConsultationViewState extends ConsumerState<ConsultationView> {
  // Fixed Vitals
  final _bpController = TextEditingController(text: '120/80');
  final _pulseController = TextEditingController(text: '72');
  final _tempController = TextEditingController(text: '98.4');
  final _weightController = TextEditingController(text: '70');
  final _spo2Controller = TextEditingController(text: '99');
  final _complaintsController = TextEditingController();

  // Dynamic NoSQL Parameters
  final List<CustomParamState> _customParams = [];

  // Dynamic Prescription Rows
  final List<PrescriptionRowState> _rows = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _addPrescriptionRow(); // Seed with one default row
  }

  @override
  void dispose() {
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _spo2Controller.dispose();
    _complaintsController.dispose();
    for (var p in _customParams) {
      p.dispose();
    }
    for (var r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addPrescriptionRow() {
    setState(() {
      _rows.add(
        PrescriptionRowState(
          id: UniqueKey().toString(),
          medicineController: TextEditingController(),
          dosageController: TextEditingController(text: '1 tab'),
          durationController: TextEditingController(text: '5'),
          instructionsController: TextEditingController(text: 'After meals'),
        ),
      );
    });
  }

  void _removePrescriptionRow(int index) {
    if (_rows.length == 1) return;
    setState(() {
      final removed = _rows.removeAt(index);
      removed.dispose();
    });
  }

  void _addCustomParam() {
    setState(() {
      _customParams.add(
        CustomParamState(
          id: UniqueKey().toString(),
          keyController: TextEditingController(),
          valueController: TextEditingController(),
        ),
      );
    });
  }

  void _removeCustomParam(int index) {
    setState(() {
      final removed = _customParams.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _handleFinalize() async {
    // 1. Validation: Ensure all rows have a medicine name
    for (var r in _rows) {
      if (r.medicineController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select or enter medicine names for all rows.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      // 2. Deduct inventory stock
      final medRepo = ref.read(medicineRepositoryProvider);
      for (var r in _rows) {
        if (r.selectedMedicine != null) {
          final days = int.tryParse(r.durationController.text) ?? 5;
          medRepo.deductStock(r.selectedMedicine!.id, days * 2);
        }
      }

      // 3. Compile dynamic NoSQL custom observations into a map
      final Map<String, String> customNotesMap = {};
      for (var param in _customParams) {
        if (param.keyController.text.trim().isNotEmpty) {
          customNotesMap[param.keyController.text.trim()] =
              param.valueController.text.trim();
        }
      }

      // 4. Construct ClinicalData (Fixed vitals + Dynamic NoSQL map)
      final clinicalData = ClinicalData(
        bp: _bpController.text.trim(),
        pulse: _pulseController.text.trim(),
        temperature: _tempController.text.trim(),
        weight: _weightController.text.trim(),
        spo2: _spo2Controller.text.trim(),
        customNotes: customNotesMap,
      );

      // 5. Construct Prescription Items list
      final presItems = _rows.map((r) {
        return PrescriptionItem(
          id: r.id,
          medicineId: r.selectedMedicine?.id ?? 0,
          medicineName: r.medicineController.text.trim(),
          dosage: r.dosageController.text.trim(),
          frequency: r.frequency,
          durationDays: int.tryParse(r.durationController.text) ?? 5,
          instructions: r.instructionsController.text.trim(),
        );
      }).toList();

      final visitRef =
          "VISIT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // 6. Launch Native PDF & Print Dialog
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PrescriptionPdfDialog(
            patient: widget.patient,
            clinicalData: clinicalData,
            complaints: _complaintsController.text.trim(),
            items: presItems,
            visitRef: visitRef,
          ),
        );

        // 7. Clear consultation state after print dialog is closed
        widget.onFinalized();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // 1. VITALS & DYNAMIC OBSERVATIONS (NoSQL)
        // ==========================================
        _buildCard(
          title: "Vitals & Dynamic Clinical Observations (NoSQL)",
          icon: FontAwesomeIcons.heartPulse,
          iconColor: AppColors.danger,
          trailing: OutlinedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.plus, size: 10),
            label: const Text("Add Custom Field"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: _addCustomParam,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Vitals Grid
              Row(
                children: [
                  Expanded(
                      child: _buildVitalInput(
                          "BP (mmHg)", _bpController, "120/80")),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildVitalInput(
                          "Pulse (bpm)", _pulseController, "72")),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildVitalInput(
                          "Temp (°F)", _tempController, "98.4")),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildVitalInput(
                          "Weight (kg)", _weightController, "70")),
                  const SizedBox(width: 12),
                  Expanded(
                      child:
                          _buildVitalInput("SpO2 (%)", _spo2Controller, "99")),
                ],
              ),

              // Dynamic NoSQL Key-Values
              if (_customParams.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.border),
                ),
                const Text(
                  "Custom Specialty Fields (Stored in SQLite JSON column):",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                ..._customParams.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: item.keyController,
                            decoration: const InputDecoration(
                                hintText: "Field Name (e.g. Fasting Sugar)"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: item.valueController,
                            decoration: const InputDecoration(
                                hintText: "Value (e.g. 115 mg/dL)"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.trashCan,
                              size: 14, color: AppColors.danger),
                          onPressed: () => _removeCustomParam(idx),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 14),

              // Complaints
              TextField(
                controller: _complaintsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Chief Complaints & Clinical Findings",
                  hintText:
                      "e.g. Patient presents with high fever, sore throat for 3 days...",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ==========================================
        // 2. DYNAMIC PRESCRIPTION TABLE
        // ==========================================
        _buildCard(
          title: "Prescription Items (Dynamic Table with Semantic Search)",
          icon: FontAwesomeIcons.pills,
          iconColor: AppColors.primary,
          trailing: ElevatedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.plus, size: 11),
            label: const Text("Add Medicine Row"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: _addPrescriptionRow,
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Text("Medicine Name (Symptom / Generic)",
                            style: _headerStyle)),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 2, child: Text("Dosage", style: _headerStyle)),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 2, child: Text("Frequency", style: _headerStyle)),
                    SizedBox(width: 8),
                    Expanded(flex: 1, child: Text("Days", style: _headerStyle)),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 3,
                        child: Text("Instructions", style: _headerStyle)),
                    SizedBox(
                        width: 44,
                        child: Center(child: Text("", style: _headerStyle))),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Table Dynamic Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Medicine Semantic Autocomplete
                      Expanded(
                        flex: 4,
                        child: Autocomplete<Medicine>(
                          displayStringForOption: (m) => m.brandName,
                          optionsBuilder: (textVal) async {
                            if (textVal.text.trim().isEmpty) return const [];
                            return await ref
                                .read(medicineRepositoryProvider)
                                .semanticSearch(textVal.text);
                          },
                          onSelected: (Medicine med) {
                            row.selectedMedicine = med;
                            row.medicineController.text = med.brandName;
                            setState(() {});
                          },
                          fieldViewBuilder: (ctx, ctrl, fNode, _) {
                            // Bind controller
                            if (row.medicineController.text.isNotEmpty &&
                                ctrl.text.isEmpty) {
                              ctrl.text = row.medicineController.text;
                            }
                            ctrl.addListener(() {
                              row.medicineController.text = ctrl.text;
                            });

                            return TextField(
                              controller: ctrl,
                              focusNode: fNode,
                              decoration: InputDecoration(
                                hintText: "Search symptoms, generic...",
                                suffixIcon: row.selectedMedicine != null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Center(
                                          widthFactor: 1,
                                          child: _buildStockBadge(
                                              row.selectedMedicine!.stockQty),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 400,
                                  constraints:
                                      const BoxConstraints(maxHeight: 260),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSurface,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    separatorBuilder: (_, __) => const Divider(
                                        height: 1, color: AppColors.border),
                                    itemBuilder: (context, i) {
                                      final med = options.elementAt(i);
                                      return ListTile(
                                        dense: true,
                                        title: Text(med.brandName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "${med.genericName} • ${med.category}",
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textMuted)),
                                            Wrap(
                                              spacing: 4,
                                              children: med.symptoms
                                                  .take(3)
                                                  .map((s) => Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4,
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFFF1F5F9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        child: Text(s,
                                                            style: const TextStyle(
                                                                fontSize: 9.5,
                                                                color: Color(
                                                                    0xFF475569))),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                        trailing:
                                            _buildStockBadge(med.stockQty),
                                        onTap: () => onSelected(med),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Dosage
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.dosageController,
                          decoration:
                              const InputDecoration(hintText: "500mg / 1 tab"),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 3. Frequency
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: row.frequency,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(
                                value: '1-0-1', child: Text('1-0-1 (BID)')),
                            DropdownMenuItem(
                                value: '1-1-1', child: Text('1-1-1 (TID)')),
                            DropdownMenuItem(
                                value: '1-0-0', child: Text('1-0-0 (Morn)')),
                            DropdownMenuItem(
                                value: '0-0-1', child: Text('0-0-1 (Night)')),
                            DropdownMenuItem(
                                value: 'SOS', child: Text('SOS (As Needed)')),
                          ],
                          onChanged: (v) => setState(() => row.frequency = v!),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 4. Days
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: row.durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: "5"),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 5. Instructions
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: row.instructionsController,
                          decoration:
                              const InputDecoration(hintText: "After meals"),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 6. Delete Row Button
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark,
                              size: 14, color: AppColors.danger),
                          onPressed: _rows.length > 1
                              ? () => _removePrescriptionRow(index)
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ==========================================
        // 3. ACTION BAR
        // ==========================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.plus, size: 11),
                label: const Text("Add Another Medicine"),
                onPressed: _addPrescriptionRow,
              ),
              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const FaIcon(FontAwesomeIcons.check, size: 13),
                label: const Text("Finalize Consultation & Update Stock"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: _isSaving ? null : _handleFinalize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  Widget _buildVitalInput(
      String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const SizedBox(height: 4),
        TextField(
            controller: ctrl, decoration: InputDecoration(hintText: hint)),
      ],
    );
  }

  Widget _buildStockBadge(int stock) {
    final isLow = stock <= 20;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isLow ? AppColors.warningBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$stock in stock",
        style: TextStyle(
          color: isLow ? AppColors.warning : AppColors.success,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
              color: Color(0xFFFAFBFC),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FaIcon(icon, size: 14, color: iconColor),
                    const SizedBox(width: 10),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

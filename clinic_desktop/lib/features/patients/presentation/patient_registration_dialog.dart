import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../data/patient_repository.dart';
import 'patient_providers.dart';

class PatientRegistrationDialog extends ConsumerStatefulWidget {
  const PatientRegistrationDialog({super.key});

  @override
  ConsumerState<PatientRegistrationDialog> createState() =>
      _PatientRegistrationDialogState();
}

class _PatientRegistrationDialogState
    extends ConsumerState<PatientRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _addressController = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _allergiesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newPatient =
          await ref.read(patientRepositoryProvider).createPatient(
                fullName: _nameController.text.trim(),
                mobile: _mobileController.text.trim(),
                dob: _dobController.text.trim(),
                gender: _gender,
                bloodGroup: _bloodGroup,
                allergies: _allergiesController.text.trim(),
                address: _addressController.text.trim(),
              );

      // Lock this new patient into consultation
      ref.read(activePatientProvider.notifier).state = newPatient;

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Patient ${newPatient.fullName} registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        FaIcon(FontAwesomeIcons.userPlus,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text(
                          "Register New Patient",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),

                // Form Fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Full Name *", hintText: "e.g. John Doe"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                            labelText: "Mobile Number *",
                            hintText: "10-digit number"),
                        validator: (v) => v == null || v.trim().length < 7
                            ? "Invalid mobile"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                            labelText: "Date of Birth *",
                            hintText: "YYYY-MM-DD"),
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
                        value: _gender,
                        decoration: const InputDecoration(labelText: "Gender"),
                        items: ['Male', 'Female', 'Other']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration:
                            const InputDecoration(labelText: "Blood Group"),
                        items: [
                          'A+',
                          'A-',
                          'B+',
                          'B-',
                          'O+',
                          'O-',
                          'AB+',
                          'AB-'
                        ]
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) => setState(() => _bloodGroup = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(
                    labelText: "Known Drug Allergies",
                    hintText: "e.g. Penicillin, Sulfa (Leave blank if none)",
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: "Address", hintText: "Street, City"),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Save & Start Consultation"),
                    ),
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

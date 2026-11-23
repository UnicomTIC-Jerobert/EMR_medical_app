import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../data/patient_repository.dart';
import '../models/patient.dart';
import 'patient_providers.dart';
import 'patient_registration_dialog.dart';

class PatientSearchBar extends ConsumerWidget {
  const PatientSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Desktop Autocomplete Box
        SizedBox(
          width: 480,
          child: Autocomplete<Patient>(
            displayStringForOption: (p) => "${p.fullName} (${p.mobile})",
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text.length < 2) return const [];
              return await ref
                  .read(patientRepositoryProvider)
                  .searchPatients(textEditingValue.text);
            },
            onSelected: (Patient selection) {
              ref.read(activePatientProvider.notifier).state = selection;
            },
            fieldViewBuilder:
                (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText:
                      "Search patient by Mobile, Name, or DOB (YYYY-MM-DD)...",
                  prefixIcon:
                      Icon(Icons.search, size: 18, color: AppColors.textMuted),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 480,
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final patient = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              patient.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(patient.mobile,
                                  style: const TextStyle(fontSize: 11.5)),
                              const SizedBox(width: 10),
                              const Icon(Icons.calendar_today,
                                  size: 11, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(patient.dob,
                                  style: const TextStyle(fontSize: 11.5)),
                            ],
                          ),
                          trailing: Text(
                            patient.id,
                            style: const TextStyle(
                                color: AppColors.textLight, fontSize: 11),
                          ),
                          onTap: () => onSelected(patient),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // New Patient Button
        ElevatedButton.icon(
          icon: const FaIcon(FontAwesomeIcons.plus, size: 12),
          label: const Text("New Patient"),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const PatientRegistrationDialog(),
            );
          },
        ),
      ],
    );
  }
}

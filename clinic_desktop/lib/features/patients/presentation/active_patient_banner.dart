import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'patient_providers.dart';

class ActivePatientBanner extends ConsumerWidget {
  const ActivePatientBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(activePatientProvider);

    if (patient == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass,
                size: 28, color: AppColors.textLight),
            SizedBox(height: 12),
            Text(
              "No Active Patient Selected",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textMain),
            ),
            SizedBox(height: 4),
            Text(
              "Search by Mobile number, Name, or Date of Birth above to start consultation.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  patient.fullName[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${patient.gender}, DOB: ${patient.dob})",
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textMuted),
                      ),
                      if (patient.allergies != null &&
                          patient.allergies!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.triangleExclamation,
                                  size: 10, color: AppColors.danger),
                              const SizedBox(width: 4),
                              Text(
                                "Allergy: ${patient.allergies}",
                                style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("ID: ${patient.id}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 14),
                      Text("Mobile: ${patient.mobile}",
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 14),
                      Text("Blood: ${patient.bloodGroup}",
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      if (patient.address != null) ...[
                        const SizedBox(width: 14),
                        Text("Address: ${patient.address}",
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.close, size: 14),
            label: const Text("Change Patient"),
            onPressed: () =>
                ref.read(activePatientProvider.notifier).state = null,
          ),
        ],
      ),
    );
  }
}

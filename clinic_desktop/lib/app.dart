// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/patients/presentation/patient_search_bar.dart';
import 'features/patients/presentation/active_patient_banner.dart';
import 'features/patients/presentation/patient_providers.dart';
import 'features/consultation/presentation/consultation_view.dart';

class MainShellLayout extends ConsumerStatefulWidget {
  const MainShellLayout({super.key});

  @override
  ConsumerState<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends ConsumerState<MainShellLayout> {
  int _activeNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activePatient = ref.watch(activePatientProvider);

    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar
          Container(
            width: 240,
            color: AppColors.bgSidebar,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
                  ),
                  child: const Row(
                    children: [
                      FaIcon(FontAwesomeIcons.heartPulse,
                          color: Color(0xFF38BDF8), size: 20),
                      SizedBox(width: 12),
                      Text(
                        "OmniClinic",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavItem(0, FontAwesomeIcons.userDoctor, "Consultation"),
                _buildNavItem(
                    1, FontAwesomeIcons.prescriptionBottleMedical, "Inventory"),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: AppColors.success, size: 10),
                      SizedBox(width: 8),
                      Text(
                        "Local Daemon Ready",
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Canvas
          Expanded(
            child: Column(
              children: [
                // Top Header Bar with Patient Search Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSurface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PatientSearchBar(),
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 10, color: AppColors.success),
                          SizedBox(width: 6),
                          Text(
                            "SQLite WAL Mode",
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Canvas Area
                Expanded(
                  child: Container(
                    color: AppColors.bgApp,
                    padding: const EdgeInsets.all(24),
                    child: _activeNavIndex == 0
                        ? ListView(
                            children: [
                              const ActivePatientBanner(),
                              if (activePatient != null)
                                ConsultationView(
                                  patient: activePatient,
                                  onFinalized: () {
                                    // Clear active patient after finalization
                                    ref
                                        .read(activePatientProvider.notifier)
                                        .state = null;
                                  },
                                ),
                            ],
                          )
                        : const Center(child: Text("Inventory View (Step 4)")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _activeNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: InkWell(
        onTap: () => setState(() => _activeNavIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              FaIcon(icon,
                  size: 16,
                  color: isActive ? Colors.white : AppColors.textLight),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textLight,
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'core/theme/app_theme.dart';

class MainShellLayout extends StatefulWidget {
  const MainShellLayout({super.key});

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  int _activeNavIndex = 0; // 0 = Consultation, 1 = Inventory

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar (Dark Slate)
          Container(
            width: 240,
            color: AppColors.bgSidebar,
            child: Column(
              children: [
                // Brand Header
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation Items
                _buildNavItem(
                  index: 0,
                  icon: FontAwesomeIcons.userDoctor,
                  label: "Consultation",
                ),
                _buildNavItem(
                  index: 1,
                  icon: FontAwesomeIcons.prescriptionBottleMedical,
                  label: "Inventory",
                ),

                const Spacer(),

                // System Status at Bottom
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
                        "SQLite Engine Offline",
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
                // Top Header Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSurface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _activeNavIndex == 0
                            ? "New Consultation"
                            : "Medicine Inventory Management",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.desktop_windows,
                              size: 16, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Text(
                            "Workstation Client",
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
                    child: Center(
                      child: Text(
                        "Active View Index: $_activeNavIndex\nReady for Riverpod Models & Dynamic Form",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required int index, required IconData icon, required String label}) {
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
              FaIcon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.textLight,
              ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medicine_repository.dart';
import 'add_medicine_dialog.dart';

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medRepo = ref.watch(medicineRepositoryProvider);
    final allMeds = medRepo.medicines;

    // KPI Metrics
    final totalUnits = allMeds.fold<int>(0, (sum, m) => sum + m.stockQty);
    final lowStockCount =
        allMeds.where((m) => m.stockQty <= 20 && m.stockQty > 0).length;
    final outOfStockCount = allMeds.where((m) => m.stockQty == 0).length;

    // Filter Logic
    final query = _searchController.text.trim().toLowerCase();
    final filtered = allMeds.where((m) {
      final matchesSearch = query.isEmpty ||
          m.brandName.toLowerCase().contains(query) ||
          m.genericName.toLowerCase().contains(query) ||
          m.symptoms.any((s) => s.contains(query));

      final matchesCategory =
          _selectedCategory == 'ALL' || m.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return ListView(
      children: [
        // 1. KPI Cards
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: "Total Inventory Units",
                value: totalUnits.toString(),
                icon: FontAwesomeIcons.boxesStacked,
                iconColor: AppColors.primary,
                bgColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKpiCard(
                label: "Low Stock Items (≤ 20)",
                value: lowStockCount.toString(),
                icon: FontAwesomeIcons.triangleExclamation,
                iconColor: AppColors.warning,
                bgColor: AppColors.warningBg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKpiCard(
                label: "Out of Stock Items",
                value: outOfStockCount.toString(),
                icon: FontAwesomeIcons.ban,
                iconColor: AppColors.danger,
                bgColor: AppColors.dangerBg,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. Control Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 380,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "Filter by brand, generic, or symptoms...",
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(
                          value: 'ALL', child: Text('All Categories')),
                      DropdownMenuItem(
                          value: 'Antibiotic', child: Text('Antibiotics')),
                      DropdownMenuItem(
                          value: 'Antipyretic / Analgesic',
                          child: Text('Antipyretics')),
                      DropdownMenuItem(
                          value: 'Antacid / PPI', child: Text('Antacids')),
                      DropdownMenuItem(
                          value: 'Antihistamine',
                          child: Text('Antihistamines')),
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.plus, size: 12),
              label: const Text("Add New Medicine"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddMedicineDialog(),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. Inventory Table
        Container(
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
            children: [
              // Table Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child:
                            Text("Brand Name & Tags", style: _tblHeaderStyle)),
                    Expanded(
                        flex: 3,
                        child: Text("Generic Formulation",
                            style: _tblHeaderStyle)),
                    Expanded(
                        flex: 2,
                        child: Text("Category", style: _tblHeaderStyle)),
                    Expanded(
                        flex: 2,
                        child: Text("Stock Status", style: _tblHeaderStyle)),
                    Expanded(
                        flex: 1,
                        child: Text("Unit Price", style: _tblHeaderStyle)),
                    SizedBox(
                        width: 140,
                        child: Text("Quick Restock",
                            textAlign: TextAlign.right,
                            style: _tblHeaderStyle)),
                  ],
                ),
              ),

              // Table Body
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text("No medicines match your filter.",
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final med = filtered[index];
                    final isOutOfStock = med.stockQty == 0;
                    final isLowStock = med.stockQty <= 20;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.brandName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5)),
                                const SizedBox(height: 2),
                                Wrap(
                                  spacing: 4,
                                  children: med.symptoms
                                      .take(3)
                                      .map((s) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: Text(s,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF475569))),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(med.genericName,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(med.category,
                                  style: const TextStyle(fontSize: 11.5)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? AppColors.dangerBg
                                        : isLowStock
                                            ? AppColors.warningBg
                                            : AppColors.successBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${med.stockQty} units",
                                    style: TextStyle(
                                      color: isOutOfStock
                                          ? AppColors.danger
                                          : isLowStock
                                              ? AppColors.warning
                                              : AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text("\$${med.unitPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildRestockBtn(
                                    "+20", () => medRepo.addStock(med.id, 20)),
                                const SizedBox(width: 6),
                                _buildRestockBtn(
                                    "+50", () => medRepo.addStock(med.id, 50)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  static const TextStyle _tblHeaderStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted);

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain)),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Center(child: FaIcon(icon, size: 18, color: iconColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildRestockBtn(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain)),
      ),
    );
  }
}

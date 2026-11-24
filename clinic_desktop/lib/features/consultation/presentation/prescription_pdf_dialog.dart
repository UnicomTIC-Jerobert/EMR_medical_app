import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../patients/models/patient.dart';
import '../models/visit_models.dart';
import '../../../core/theme/app_theme.dart';

class PrescriptionPdfDialog extends StatelessWidget {
  final Patient patient;
  final ClinicalData clinicalData;
  final String complaints;
  final List<PrescriptionItem> items;
  final String visitRef;

  const PrescriptionPdfDialog({
    super.key,
    required this.patient,
    required this.clinicalData,
    required this.complaints,
    required this.items,
    required this.visitRef,
  });

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header (Clinic & Doctor)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "OMNICLINIC MEDICAL WORKSTATION",
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900),
                      ),
                      pw.Text(
                          "124 Healthcare Boulevard, Suite 400 • Tel: +1 (555) 019-2834",
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.Text("Outpatient Medical Consultation File",
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Dr. Arthur Vance, MD",
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Internal Medicine • Reg: #MED-948201",
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey900),
              pw.SizedBox(height: 10),

              // 2. Patient Demographics Strip
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Patient: ${patient.fullName}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text("ID: ${patient.id}",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Gender/Age: ${patient.gender} (${patient.dob})",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        "Date: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Ref: $visitRef",
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 3. Vitals Strip
              pw.Row(
                children: [
                  pw.Text("Vitals: ",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text("BP: ${clinicalData.bp} mmHg  |  ",
                      style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Text("Pulse: ${clinicalData.pulse} bpm  |  ",
                      style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Text("Temp: ${clinicalData.temperature} °F  |  ",
                      style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Text("Weight: ${clinicalData.weight} kg  |  ",
                      style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Text("SpO2: ${clinicalData.spo2}%",
                      style: const pw.TextStyle(fontSize: 9.5)),
                ],
              ),
              if (patient.allergies != null &&
                  patient.allergies!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text("Allergies: ${patient.allergies}",
                    style: pw.TextStyle(
                        color: PdfColors.red800,
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold)),
              ],
              pw.SizedBox(height: 10),

              if (complaints.isNotEmpty) ...[
                pw.Text("Clinical Notes / Complaints: $complaints",
                    style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 14),
              ],

              // 4. Rx Symbol
              pw.Text("Rx",
                  style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900)),
              pw.SizedBox(height: 6),

              // 5. Prescription Table
              pw.TableHelper.fromTextArray(
                border: null,
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                headerHeight: 22,
                cellHeight: 24,
                headerStyle:
                    pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 9.5),
                headers: [
                  '#',
                  'Medicine Name',
                  'Dosage',
                  'Frequency',
                  'Duration',
                  'Instructions'
                ],
                data: items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return [
                    idx.toString(),
                    item.medicineName,
                    item.dosage,
                    item.frequency,
                    "${item.durationDays} days",
                    item.instructions.isEmpty
                        ? "As advised"
                        : item.instructions,
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // 6. Signature Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Generated via OmniClinic Native Desktop Workstation",
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey600)),
                  pw.Column(
                    children: [
                      pw.Container(
                          width: 140, height: 1, color: PdfColors.grey900),
                      pw.SizedBox(height: 4),
                      pw.Text("Physician Signature",
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: AppColors.bgSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 800),
        child: Column(
          children: [
            // Modal Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Prescription Preview & Native OS Print",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Embedded Flutter PDF Previewer with direct OS printer integration
            Expanded(
              child: PdfPreview(
                build: (format) async => (await _buildPdf()).save(),
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowPrinting: true,
                allowSharing: false,
                pdfFileName: "Prescription_${patient.fullName}_$visitRef.pdf",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

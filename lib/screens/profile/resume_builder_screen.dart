import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  String _selectedTemplate = 'Professional';
  final _objectiveCtrl = TextEditingController(
    text: 'Dedicated Mobile Software Engineer with 2+ years of hands-on experience building high-performance cross-platform Flutter applications. Passionate about clean architecture, state management, and reliable REST API integrations.',
  );

  Future<void> _previewAndExportPdf(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  user?.name ?? 'Candidate',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${user?.targetRole ?? "Software Developer"} • ${user?.location.isNotEmpty == true ? user!.location : "India"} • ${user?.email ?? ""}',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 12),

                pw.Text('PROFESSIONAL OBJECTIVE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text(_objectiveCtrl.text, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 14),

                pw.Text('CORE TECHNICAL SKILLS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text(
                  (user?.skills.keys.join(', ') ?? 'Flutter, Dart, Firebase, REST API, Git'),
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 14),

                pw.Text('WORK EXPERIENCE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 4),
                ...((user?.experience.isNotEmpty == true)
                    ? user!.experience.map(
                        (exp) => pw.Bullet(text: exp, style: const pw.TextStyle(fontSize: 10)),
                      )
                    : [
                        pw.Bullet(
                          text: 'Software Developer — Mobile & Web Engineering Projects (2024)',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ]),
                pw.SizedBox(height: 14),

                pw.Text('EDUCATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 4),
                ...((user?.education.isNotEmpty == true)
                    ? user!.education.map(
                        (edu) => pw.Bullet(text: edu, style: const pw.TextStyle(fontSize: 10)),
                      )
                    : [
                        pw.Bullet(
                          text: 'B.Tech in Computer Science & Engineering (2024)',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ]),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HireHub_Resume_${(user?.name ?? "Candidate").replaceAll(RegExp(r'\s+'), "_")}.pdf',
    );
  }

  @override
  void dispose() {
    _objectiveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ATS Resume Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () => _previewAndExportPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Picker
            Text('Select Layout Template', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Row(
              children: ['Professional', 'Modern', 'Minimal'].map((t) {
                final isSelected = _selectedTemplate == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _selectedTemplate = t),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Objective Summary
            Text('Career Objective / Executive Summary', style: AppTypography.titleSm),
            const SizedBox(height: 8),
            TextField(
              controller: _objectiveCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your core technical strengths and experience...',
              ),
            ),
            const SizedBox(height: 20),

            // Profile Data Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Included Candidate Data', style: AppTypography.titleSm),
                  const SizedBox(height: 12),
                  _buildDataRow('Candidate Name', user?.name ?? 'Candidate'),
                  _buildDataRow('Target Role', user?.targetRole ?? 'Software Developer'),
                  _buildDataRow('Skills Included', '${user?.skills.length ?? 0} technologies'),
                  _buildDataRow('Work Experience', '${user?.experience.length ?? 0} listed'),
                  _buildDataRow('Education', '${user?.education.length ?? 0} listed'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Preview & Export Resume PDF',
              icon: Icons.picture_as_pdf_rounded,
              onPressed: () => _previewAndExportPdf(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySm),
          Text(value, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

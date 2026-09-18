import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/document_picker.dart';
import '../../models/application_model.dart';
import '../../models/job_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skill_chip.dart';
import 'application_confirmation_screen.dart';

class ApplyJobScreen extends StatefulWidget {
  final JobModel job;

  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _pitchCtrl = TextEditingController();
  String _noticePeriod = 'Immediate (0–15 Days)';
  bool _isHybridOk = true;
  bool _isSubmitting = false;

  String? _customResumeFileName;
  int? _customResumeSizeBytes;
  bool _isUploadingCustomResume = false;

  @override
  void initState() {
    super.initState();
    _pitchCtrl.text =
        'I am excited to apply for the ${widget.job.title} role at ${widget.job.companyName}. With 2 years of production experience in Flutter, Dart, and Firebase, I have built reliable cross-platform architectures and integrated complex REST APIs. I am eager to contribute to your engineering milestones.';
  }

  @override
  void dispose() {
    _pitchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomResume() async {
    try {
      final auth = context.read<AuthProvider>();
      final doc = await DocumentPicker.pickDocument(
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (doc == null || doc.bytes.isEmpty) return;

      if (!mounted) return;
      setState(() {
        _isUploadingCustomResume = true;
        _customResumeFileName = doc.name;
        _customResumeSizeBytes = doc.bytes.length;
      });

      final user = auth.user;
      if (user != null) {
        final storage = StorageService();
        await storage.uploadResume(
          userId: user.uid,
          fileName: doc.name,
          bytes: doc.bytes,
        );
      }

      if (mounted) {
        setState(() => _isUploadingCustomResume = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attached ${doc.name} to this application.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingCustomResume = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final attachedResumeName = _customResumeFileName ??
        user.resumeName ??
        '${user.name.replaceAll(RegExp(r'\s+'), '_')}_Resume.pdf';

    final appModel = ApplicationModel(
      id: const Uuid().v4(),
      userId: user.uid,
      jobId: widget.job.id,
      jobTitle: widget.job.title,
      companyId: widget.job.companyId,
      companyName: widget.job.companyName,
      location: widget.job.location,
      salaryFormatted: widget.job.formattedSalary,
      resumeName: attachedResumeName,
      coverLetter: _pitchCtrl.text.trim(),
      status: 'applied',
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      timeline: [
        ApplicationTimelineEvent(
          title: 'Application Submitted',
          description: 'Resume, verified skill credentials, and pitch received.',
          timestamp: DateTime.now(),
          isDone: true,
        ),
      ],
    );

    try {
      await context.read<ApplicationProvider>().submitApplication(appModel);
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ApplicationConfirmationScreen(application: appModel),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header Glance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.job.companyName.isNotEmpty ? widget.job.companyName[0] : 'C',
                      style: AppTypography.titleMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.job.title, style: AppTypography.titleSm),
                        Text(
                          '${widget.job.companyName} • ${widget.job.formattedSalary}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Applicant Information
            Text('1. Applicant Information', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildProfileRow('Full Name', user?.name ?? 'Candidate'),
                  const Divider(height: 16),
                  _buildProfileRow('Email', user?.email ?? ''),
                  const Divider(height: 16),
                  _buildProfileRow('Location', user?.location.isNotEmpty == true ? user!.location : 'Remote / India'),
                  const Divider(height: 16),
                  _buildProfileRow('Experience', '${user?.experienceYears ?? 0} Years'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Resume Attached
            Text('2. Resume Attached', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customResumeFileName ??
                                  user?.resumeName ??
                                  '${(user?.name ?? "Candidate").replaceAll(RegExp(r'\s+'), '_')}_Resume.pdf',
                              style: AppTypography.labelMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _customResumeSizeBytes != null
                                  ? '${(_customResumeSizeBytes! / 1024).toStringAsFixed(1)} KB • Tailored for this role'
                                  : (user?.resumeUrl?.isNotEmpty == true
                                      ? 'Cloud Synced PDF • Ready'
                                      : 'Profile PDF • Ready'),
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                color: _customResumeFileName != null ? AppColors.accent : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_rounded, color: AppColors.accent, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Want to tailor your CV for ${widget.job.companyName}?',
                        style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (_isUploadingCustomResume)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      else
                        TextButton.icon(
                          onPressed: _pickCustomResume,
                          icon: const Icon(Icons.file_upload_outlined, size: 16),
                          label: Text(
                            _customResumeFileName != null ? 'Change PDF' : 'Upload PDF',
                            style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Verified Skill Proof
            Text('3. Verified Skill Proof', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.job.requiredSkills.map((s) {
                final isVerified = user?.skills.containsKey(s) ?? false;
                return SkillChip(
                  skillName: s,
                  variant: isVerified ? SkillChipVariant.matched : SkillChipVariant.neutral,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Section 4: Pitch / Cover Letter
            Text('4. Candidate Pitch', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            TextField(
              controller: _pitchCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share why you are the best fit for this role...',
              ),
            ),
            const SizedBox(height: 20),

            // Section 5: Screening Questions
            Text('5. Screening Questionnaire', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notice Period', style: AppTypography.labelMd),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _noticePeriod,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Immediate (0–15 Days)', child: Text('Immediate (0–15 Days)')),
                      DropdownMenuItem(value: '30 Days', child: Text('30 Days')),
                      DropdownMenuItem(value: '60 Days', child: Text('60 Days')),
                    ],
                    onChanged: (val) => setState(() => _noticePeriod = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Willing to work hybrid schedule in ${widget.job.location}?',
                          style: AppTypography.bodySm,
                        ),
                      ),
                      Switch(
                        value: _isHybridOk,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isHybridOk = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Confirm & Submit Application',
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySm),
        Text(value, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/document_picker.dart';
import '../../core/utils/document_text_extractor.dart';
import '../../core/utils/resume_parser.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skill_chip.dart';
import '../auth/auth_screen.dart';
import '../settings/application_health_screen.dart';
import '../settings/settings_screen.dart';
import 'resume_builder_screen.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  bool _isProcessingResume = false;

  Future<void> _uploadAndExtractResume() async {
    try {
      final auth = context.read<AuthProvider>();
      final doc = await DocumentPicker.pickDocument(
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (doc == null || doc.bytes.isEmpty) return;

      final fileName = doc.name;
      final bytes = doc.bytes;

      if (!mounted) return;
      setState(() => _isProcessingResume = true);

      // 1. Extract text and detect skills
      final extractedText = DocumentTextExtractor.extractText(bytes, fileName);
      final detectedProficiencies = ResumeParser.detectSkillsWithProficiency(extractedText);

      // 2. Upload to Firebase Storage
      final currentUser = auth.user;
      String? storageUrl;

      if (currentUser != null) {
        final storage = StorageService();
        storageUrl = await storage.uploadResume(
          userId: currentUser.uid,
          fileName: fileName,
          bytes: bytes,
        );

        // 3. Merge newly detected skills into user's existing skills
        final mergedSkills = Map<String, int>.from(currentUser.skills);
        detectedProficiencies.forEach((skill, prof) {
          mergedSkills[skill] = prof;
        });

        auth.updateProfile(
          resumeName: fileName,
          resumeUrl: storageUrl,
          skills: mergedSkills,
          profileCompletion: 95,
        );
      }

      if (mounted) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Resume Uploaded & Parsed!', style: AppTypography.headlineSm),
                            Text('$fileName • ${detectedProficiencies.length} skills extracted', style: AppTypography.bodySm),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Updated Technical Stack:', style: AppTypography.labelMd),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: detectedProficiencies.entries.map((e) {
                      return Chip(
                        avatar: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                        label: Text('${e.key} (${e.value}%)'),
                        backgroundColor: AppColors.surfaceContainerLow,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Save to Profile',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingResume = false);
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final roleCtrl = TextEditingController(text: user?.targetRole ?? 'Software Developer (Flutter)');
    final locCtrl = TextEditingController(text: user?.location ?? 'Mumbai, India');
    final expCtrl = TextEditingController(text: (user?.experienceYears ?? 2).toString());
    final salaryCtrl = TextEditingController(text: (user?.expectedSalaryLPA ?? 8.5).toString());
    String workMode = user?.preferredWorkMode ?? 'Hybrid';
    String jobType = user?.preferredJobType ?? 'Full-time';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Edit Profile Details', style: AppTypography.headlineSm),
                              Text('Update your personal details & career preferences',
                                  style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Tech Role',
                        prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location / Hub',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Experience (Yrs)',
                              prefixIcon: Icon(Icons.timeline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: salaryCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Expected CTC (LPA)',
                              prefixIcon: Icon(Icons.currency_rupee),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Preferred Work Mode', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Hybrid', 'Remote', 'On-site'].map((mode) {
                        final isSel = workMode == mode;
                        return ChoiceChip(
                          label: Text(mode),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setModalState(() => workMode = mode),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text('Job Type', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Full-time', 'Internship', 'Contract'].map((type) {
                        final isSel = jobType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          selectedColor: AppColors.accent,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setModalState(() => jobType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: 'Save Profile Changes',
                      icon: Icons.check_circle_outline,
                      onPressed: () {
                        context.read<AuthProvider>().updateProfile(
                          name: nameCtrl.text.trim(),
                          targetRole: roleCtrl.text.trim(),
                          location: locCtrl.text.trim(),
                          experienceYears: int.tryParse(expCtrl.text.trim()) ?? 2,
                          expectedSalaryLPA: double.tryParse(salaryCtrl.text.trim()) ?? 8.5,
                          preferredWorkMode: workMode,
                          preferredJobType: jobType,
                          profileCompletion: 95,
                        );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExperienceDialog(BuildContext context) {
    final roleCtrl = TextEditingController(text: 'Flutter Developer');
    final companyCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '2023 – Present');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Work Experience', style: AppTypography.headlineSm),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job Title / Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Company / Organization',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 2023 – Present)',
                  prefixIcon: Icon(Icons.date_range_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Add to Experience Timeline',
                onPressed: () {
                  if (roleCtrl.text.trim().isEmpty || companyCtrl.text.trim().isEmpty) {
                    return;
                  }
                  final auth = context.read<AuthProvider>();
                  final list = List<String>.from(auth.user?.experience ?? []);
                  list.insert(0, '${roleCtrl.text.trim()} at ${companyCtrl.text.trim()} (${durationCtrl.text.trim()})');
                  auth.updateProfile(experience: list);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEducationDialog(BuildContext context) {
    final degreeCtrl = TextEditingController(text: 'B.Tech in Computer Science');
    final schoolCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2024');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Education Credential', style: AppTypography.headlineSm),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: degreeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Degree / Certificate',
                  prefixIcon: Icon(Icons.school_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: schoolCtrl,
                decoration: const InputDecoration(
                  labelText: 'University / College',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Graduation Year',
                  prefixIcon: Icon(Icons.event_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Add to Education',
                onPressed: () {
                  if (degreeCtrl.text.trim().isEmpty || schoolCtrl.text.trim().isEmpty) {
                    return;
                  }
                  final auth = context.read<AuthProvider>();
                  final list = List<String>.from(auth.user?.education ?? []);
                  list.insert(0, '${degreeCtrl.text.trim()} — ${schoolCtrl.text.trim()} (${yearCtrl.text.trim()})');
                  auth.updateProfile(education: list);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.work_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Your Profile'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            tooltip: 'Application Health Score',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApplicationHealthScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Candidate Profile Identity Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with verified badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                              style: AppTypography.headlineLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user?.name ?? 'Your Name',
                                    style: AppTypography.headlineSm,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'PRO',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.targetRole ?? 'Software Developer',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    user?.location ?? 'Mumbai, India',
                                    style: AppTypography.bodySm.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (user?.email != null && user!.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.mail_outline_rounded, size: 13, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Completeness bar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Text('Profile Strength', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                            Text('${user?.profileCompletion ?? 95}% Complete',
                                style: AppTypography.bodySm.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (user?.profileCompletion ?? 95) / 100,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Prominent Edit Profile Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () => _showEditProfileDialog(context, user),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Career Preferences & Target Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                children: [
                  // Preferences Top Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Career Preferences',
                              style: AppTypography.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active Status',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProfileStat('Experience', '${user?.experienceYears ?? 2} Years'),
                            _buildProfileStat('Expected CTC', '₹${(user?.expectedSalaryLPA ?? 8.5).toStringAsFixed(1)} LPA'),
                            _buildProfileStat('Work Mode', user?.preferredWorkMode ?? 'Hybrid'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text('Instant Recruiter Match: Enabled',
                                    style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => _showEditProfileDialog(context, user),
                              child: const Text('Update', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stealth Mode Recruiter Shield
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stealth Mode (Recruiter Shield)', style: AppTypography.titleSm),
                        Text(
                          settings.stealthMode ? 'Your profile is hidden from current employer' : 'Profile visible to verified recruiters',
                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.stealthMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => settings.setStealthMode(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Real Resume Upload & Cloud Storage Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.resumeName ?? 'No Resume Attached',
                              style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.resumeUrl != null ? 'Synced to Cloud Storage • Active' : 'Attach your real PDF resume to extract skills',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                color: user?.resumeUrl != null ? AppColors.accent : AppColors.textSecondary,
                                fontWeight: user?.resumeUrl != null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _isProcessingResume
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.cloud_upload_outlined, size: 16),
                          label: Text(_isProcessingResume ? 'Extracting...' : 'Upload PDF Resume'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: _isProcessingResume ? null : _uploadAndExtractResume,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bolt_rounded, size: 16),
                        label: const Text('Re-scan', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                        onPressed: _isProcessingResume ? null : _uploadAndExtractResume,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Resume Builder Action Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF12355B), Color(0xFF0F3057)],
                ),
                borderRadius: AppSpacing.roundedLg,
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ATS Resume Builder & Export', style: AppTypography.titleSm.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          'Generate a clean ATS technical resume PDF from your verified profile.',
                          style: AppTypography.bodySm.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResumeBuilderScreen()),
                      );
                    },
                    child: const Text('Build PDF', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Verified Skills
            Text('Verified Technical Stack', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            if ((user?.skills ?? {}).isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_outlined, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload a PDF resume above to automatically parse and verify your technical skills.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user!.skills.keys.map((s) {
                  return SkillChip(
                    skillName: '$s • ${user.skills[s]}%',
                    variant: SkillChipVariant.matched,
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Experience Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Professional Experience', style: AppTypography.headlineSm),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add Role'),
                  onPressed: () => _showAddExperienceDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if ((user?.experience ?? []).isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No work history added yet. Tap Add Role or Pre-fill below.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...user!.experience.map((exp) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(exp, style: AppTypography.bodyMd)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () {
                          final list = List<String>.from(user.experience)..remove(exp);
                          context.read<AuthProvider>().updateProfile(experience: list);
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 20),

            // Education
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Education Credentials', style: AppTypography.headlineSm),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add Degree'),
                  onPressed: () => _showAddEducationDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if ((user?.education ?? []).isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No degrees added yet. Tap Add Degree to record credentials.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...user!.education.map((edu) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(edu, style: AppTypography.bodyMd)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () {
                          final list = List<String>.from(user.education)..remove(edu);
                          context.read<AuthProvider>().updateProfile(education: list);
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),

            PrimaryButton(
              text: 'Check Application Health Score (78/100)',
              icon: Icons.health_and_safety_outlined,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApplicationHealthScreen()),
                );
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
              label: const Text('Sign Out of HireHub', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out of HireHub?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

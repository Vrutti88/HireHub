import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/document_picker.dart';
import '../../core/utils/document_text_extractor.dart';
import '../../core/utils/resume_parser.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/primary_button.dart';
import '../main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 1;

  // Step 1: Career & Experience
  String _targetRole = 'Software Developer (Flutter)';
  int _experienceYears = 2;
  String _location = 'Mumbai';
  double _expectedSalaryLPA = 8.5;
  String _workMode = 'Hybrid';

  // Step 2: Skills Selection
  final Set<String> _selectedSkills = {'Flutter', 'Dart', 'Firebase'};
  final TextEditingController _customSkillCtrl = TextEditingController();

  // Step 3: Real Resume Upload & Rule-based Detection
  String? _uploadedResumeFileName;
  int? _uploadedResumeSizeBytes;
  String? _uploadedResumeUrl;
  bool _isAnalyzingResume = false;
  bool _isUploadingToStorage = false;
  List<String> _detectedSkills = [];
  Map<String, int> _detectedSkillsWithProficiency = {};
  final TextEditingController _resumeTextCtrl = TextEditingController();

  final List<String> _roleOptions = [
    'Software Developer (Flutter)',
    'Mobile Engineer (iOS/Android)',
    'UI/UX Designer',
    'Junior Data Analyst',
    'Full Stack Engineer',
  ];

  final List<String> _suggestedSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'REST API',
    'Git',
    'State Management',
    'SQL',
    'Python',
    'Figma',
    'Unit Testing',
  ];

  @override
  void dispose() {
    _customSkillCtrl.dispose();
    _resumeTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadResume() async {
    try {
      final auth = context.read<AuthProvider>();
      final doc = await DocumentPicker.pickDocument(
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'rtf'],
      );

      if (doc == null || doc.bytes.isEmpty) return;

      final fileName = doc.name;
      final bytes = doc.bytes;

      if (!mounted) return;
      setState(() {
        _isAnalyzingResume = true;
        _uploadedResumeFileName = fileName;
        _uploadedResumeSizeBytes = bytes.length;
      });

      // 1. Extract text from the real file
      final extractedText = DocumentTextExtractor.extractText(bytes, fileName);
      if (extractedText.isNotEmpty) {
        _resumeTextCtrl.text = extractedText;
      }

      // 2. Extract skills using comprehensive dictionary
      final textToParse = extractedText.isNotEmpty ? extractedText : _resumeTextCtrl.text;
      final detected = ResumeParser.detectSkillsWithProficiency(textToParse);

      setState(() {
        _detectedSkills = detected.keys.toList();
        _detectedSkillsWithProficiency = detected;
        _selectedSkills.addAll(detected.keys);
        _isAnalyzingResume = false;
      });

      // 3. Upload file bytes to Firebase Storage in background
      final user = auth.user;
      if (user != null) {
        setState(() => _isUploadingToStorage = true);
        final storage = StorageService();
        final url = await storage.uploadResume(
          userId: user.uid,
          fileName: fileName,
          bytes: bytes,
        );
        if (mounted) {
          setState(() {
            _uploadedResumeUrl = url;
            _isUploadingToStorage = false;
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Extracted ${detected.length} technical skills from $fileName!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingResume = false;
          _isUploadingToStorage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File processing note: $e')),
        );
      }
    }
  }

  void _analyzeManualText() {
    if (_resumeTextCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or paste your resume text first.')),
      );
      return;
    }
    setState(() => _isAnalyzingResume = true);
    final detected = ResumeParser.detectSkillsWithProficiency(_resumeTextCtrl.text);
    setState(() {
      _isAnalyzingResume = false;
      _detectedSkills = detected.keys.toList();
      _detectedSkillsWithProficiency = detected;
      _selectedSkills.addAll(detected.keys);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Extracted ${detected.length} technical skills!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _finishSetup() {
    final auth = context.read<AuthProvider>();
    final skillsMap = <String, int>{};
    for (final s in _selectedSkills) {
      skillsMap[s] = _detectedSkillsWithProficiency[s] ?? 75; // default verified proficiency
    }

    final cleanName = (auth.user?.name ?? 'Candidate').replaceAll(RegExp(r'\s+'), '_');
    final finalResumeName = _uploadedResumeFileName ?? '${cleanName}_Resume.pdf';

    auth.updateProfile(
      targetRole: _targetRole,
      experienceYears: _experienceYears,
      location: _location,
      expectedSalaryLPA: _expectedSalaryLPA,
      preferredWorkMode: _workMode,
      skills: skillsMap,
      resumeName: finalResumeName,
      resumeUrl: _uploadedResumeUrl,
      profileCompletion: 85,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile Setup ($_currentStep/3)', style: AppTypography.titleMd),
        actions: [
          TextButton(
            onPressed: _finishSetup,
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator Bar
            LinearProgressIndicator(
              value: _currentStep / 3.0,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildStepContent(),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _currentStep == 3 ? 'Save & Go to Dashboard' : 'Continue',
                      onPressed: () {
                        if (_currentStep < 3) {
                          setState(() => _currentStep++);
                        } else {
                          _finishSetup();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Career();
      case 2:
        return _buildStep2Skills();
      case 3:
      default:
        return _buildStep3Resume();
    }
  }

  Widget _buildStep1Career() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Career & Preferences', style: AppTypography.headlineSm),
        const SizedBox(height: 6),
        Text('Tell us your target position and work preferences.', style: AppTypography.bodySm),
        const SizedBox(height: 24),

        // Target Role
        Text('Target Role', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _targetRole,
              isExpanded: true,
              items: _roleOptions.map((role) {
                return DropdownMenuItem(value: role, child: Text(role, style: AppTypography.bodyMd));
              }).toList(),
              onChanged: (val) => setState(() => _targetRole = val!),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Experience Years
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Years of Experience', style: AppTypography.labelMd),
            Text('$_experienceYears years', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _experienceYears.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.primary,
          onChanged: (val) => setState(() => _experienceYears = val.round()),
        ),
        const SizedBox(height: 16),

        // Expected Salary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Expected Salary (LPA)', style: AppTypography.labelMd),
            Text('₹${_expectedSalaryLPA.toStringAsFixed(1)} LPA', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _expectedSalaryLPA,
          min: 2.0,
          max: 30.0,
          divisions: 28,
          activeColor: AppColors.primary,
          onChanged: (val) => setState(() => _expectedSalaryLPA = double.parse(val.toStringAsFixed(1))),
        ),
        const SizedBox(height: 16),

        // Location & Work Mode
        Text('Preferred Location', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _location,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
          onChanged: (val) => _location = val,
        ),
        const SizedBox(height: 16),
        Text('Preferred Work Mode', style: AppTypography.labelMd),
        const SizedBox(height: 8),
                Row(
          children: ['Remote', 'Hybrid', 'On-site'].map((mode) {
            final isSel = _workMode == mode;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(mode),
                selected: isSel,
                selectedColor: AppColors.primaryLight,
                backgroundColor: Colors.white,
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: isSel ? AppColors.primary : AppColors.border,
                  width: isSel ? 1.5 : 1.0,
                ),
                labelStyle: TextStyle(
                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                ),
                onSelected: (val) {
                  if (val) setState(() => _workMode = mode);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Skills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Technical Skills', style: AppTypography.headlineSm),
        const SizedBox(height: 6),
        Text('Select the technologies you actively work with for accurate Job Fit calculations.', style: AppTypography.bodySm),
        const SizedBox(height: 20),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              selected: isSelected,
              label: Text(skill),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Add Custom Skill
        Text('Add Custom Skill', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customSkillCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Docker, GraphQL'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final text = _customSkillCtrl.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _selectedSkills.add(text);
                    _customSkillCtrl.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Resume() {
    final hasFile = _uploadedResumeFileName != null;
    final fileSizeKb = _uploadedResumeSizeBytes != null ? (_uploadedResumeSizeBytes! / 1024).toStringAsFixed(1) : '184.5';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Resume & Skill Detection', style: AppTypography.headlineSm),
        const SizedBox(height: 6),
        Text(
          'Upload your real PDF resume or paste its content. Our parser extracts text, detects technical proficiencies, and uploads the document to cloud storage.',
          style: AppTypography.bodySm,
        ),
        const SizedBox(height: 18),

        // Real File Upload Card
        if (hasFile) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.roundedLg,
              border: Border.all(color: AppColors.accent, width: 1.5),
              boxShadow: AppSpacing.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.roundedMd,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _uploadedResumeFileName!,
                            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text('$fileSizeKb KB • ', style: AppTypography.bodySm.copyWith(fontSize: 12)),
                              if (_isUploadingToStorage) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Syncing to Cloud...',
                                  style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.primary),
                                ),
                              ] else ...[
                                const Icon(Icons.cloud_done_rounded, color: AppColors.accent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Uploaded to Storage',
                                  style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                      label: const Text('Change File', style: TextStyle(fontSize: 12)),
                      onPressed: _pickAndUploadResume,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.bolt_rounded, size: 16),
                      label: const Text('Re-scan Skills', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        if (_resumeTextCtrl.text.isNotEmpty) {
                          _analyzeManualText();
                        } else {
                          _pickAndUploadResume();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          InkWell(
            onTap: _pickAndUploadResume,
            borderRadius: AppSpacing.roundedLg,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to Browse & Upload Resume',
                      style: AppTypography.titleSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports PDF, DOCX, TXT (up to 10MB)',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedFull),
                      ),
                      icon: const Icon(Icons.file_open_rounded, size: 18),
                      label: const Text('Select File From Device'),
                      onPressed: _pickAndUploadResume,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Extracted Text Content Field
        Text('Extracted Resume Content (or Paste Text)', style: AppTypography.labelMd),
        const SizedBox(height: 8),
        TextField(
          controller: _resumeTextCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Resume text will appear here automatically after picking a file, or you can paste your resume text here...',
            hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(_isAnalyzingResume ? 'Extracting...' : 'Scan / Refresh Skills'),
                onPressed: _isAnalyzingResume ? null : _analyzeManualText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Pick New PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _pickAndUploadResume,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Detected Skills Card
        if (_detectedSkills.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: AppSpacing.roundedLg,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Extracted Skills (${_detectedSkills.length})',
                          style: AppTypography.titleSm.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to toggle',
                      style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _detectedSkills.map((s) {
                    final isSelected = _selectedSkills.contains(s);
                    final proficiency = _detectedSkillsWithProficiency[s] ?? 75;
                    return ChoiceChip(
                      label: Text('$s ($proficiency%)'),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedSkills.add(s);
                          } else {
                            _selectedSkills.remove(s);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

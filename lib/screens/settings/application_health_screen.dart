import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/application_health_calculator.dart';
import '../../data/seed_data.dart';
import '../../models/user_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/fit_score_gauge.dart';
import '../main_navigation_screen.dart';

class ApplicationHealthScreen extends StatefulWidget {
  const ApplicationHealthScreen({super.key});

  @override
  State<ApplicationHealthScreen> createState() => _ApplicationHealthScreenState();
}

class _ApplicationHealthScreenState extends State<ApplicationHealthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSyncing = false;
  DateTime _lastSyncedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLiveSync(String uid) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      if (uid.isNotEmpty) {
        await context.read<ApplicationProvider>().loadApplications(uid);
      }
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _lastSyncedTime = DateTime.now();
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ATS Health index synced in real time',
                  style: AppTypography.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _navigateToTab(int tabIndex) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(initialIndex: tabIndex),
      ),
      (route) => false,
    );
  }

  void _showQuickProfileModal(BuildContext context, UserModel user) {
    final roleCtrl = TextEditingController(text: user.targetRole);
    final locCtrl = TextEditingController(text: user.location);
    int completion = user.profileCompletion < 90 ? 95 : user.profileCompletion;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.badge_outlined, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Complete Profile Details', style: AppTypography.titleMd),
                            Text(
                              'Updates your ATS profile completeness in real time (+5 pts)',
                              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Target Role Headline', style: AppTypography.labelSm),
                  const SizedBox(height: 6),
                  TextField(
                    controller: roleCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Senior Flutter Developer',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Preferred Work Location', style: AppTypography.labelSm),
                  const SizedBox(height: 6),
                  TextField(
                    controller: locCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Bengaluru / Remote',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Completing your portfolio links boosts profile score to $completion% (+5 pts)',
                            style: AppTypography.bodySm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthProvider>().updateProfile(
                          targetRole: roleCtrl.text.trim(),
                          location: locCtrl.text.trim(),
                          profileCompletion: completion,
                        );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile updated! Health Score boosted in real time.'),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save & Boost Score (+5 pts)', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQuickSkillsModal(BuildContext context, UserModel user) {
    final availableSkills = [
      'Docker',
      'Kubernetes',
      'GraphQL',
      'System Design',
      'AWS Cloud',
      'CI/CD Pipelines',
      'State Management',
      'TypeScript',
      'PostgreSQL',
      'Unit Testing',
    ].where((s) => !user.skills.containsKey(s)).toList();

    final selected = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add Verified Skills', style: AppTypography.titleMd),
                            Text(
                              'Select skills to verify and increase ATS score in real time',
                              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSkills.map((skill) {
                      final isSel = selected.contains(skill);
                      return FilterChip(
                        selected: isSel,
                        label: Text(skill),
                        selectedColor: AppColors.accentLight,
                        checkmarkColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.accent : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSel ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selected.add(skill);
                            } else {
                              selected.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              context.read<AuthProvider>().addSkillsToUser(selected.toList());
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${selected.length} skills! Score updated in real time.'),
                                  backgroundColor: AppColors.accent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        selected.isEmpty ? 'Select Skills to Add' : 'Add ${selected.length} Skills (+6 pts)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final user = authUser ?? SeedData.initialUser;
    final appList = context.watch<ApplicationProvider>().applications;
    final apps = appList.isNotEmpty ? appList : SeedData.applications;

    final report = ApplicationHealthCalculator.calculate(
      user: user,
      applications: apps,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Health Score'),
        actions: [
          IconButton(
            tooltip: 'Live Re-sync',
            onPressed: () => _handleLiveSync(user.uid),
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleLiveSync(user.uid),
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Realtime Live Engine Status Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _pulseAnimation,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live ATS Sync Active',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Synced ${_lastSyncedTime.hour.toString().padLeft(2, '0')}:${_lastSyncedTime.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Overall Health Index Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppSpacing.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FitScoreGauge(
                          score: report.overallScore,
                          size: 92,
                          strokeWidth: 8,
                          showLabel: false,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Health Index',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: report.overallScore),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, child) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$val',
                                        style: AppTypography.displayLg.copyWith(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '/ 100',
                                        style: AppTypography.titleMd.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: report.overallScore >= 75
                                      ? AppColors.accentLight
                                      : AppColors.warningBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: report.overallScore >= 75
                                        ? AppColors.accent.withValues(alpha: 0.3)
                                        : AppColors.warning.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      report.overallScore >= 75
                                          ? Icons.verified_rounded
                                          : Icons.trending_up_rounded,
                                      size: 14,
                                      color: report.overallScore >= 75
                                          ? AppColors.accent
                                          : AppColors.warning,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      report.overallScore >= 75
                                          ? 'Strong Profile Momentum'
                                          : 'Optimizations Recommended',
                                      style: AppTypography.labelSm.copyWith(
                                        color: report.overallScore >= 75
                                            ? AppColors.secondary
                                            : AppColors.warning,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 14),
                    // Quick Mini Metric Pills
                    Row(
                      children: [
                        _buildMiniPill('Profile', '${report.profileFactorScore}/25'),
                        const SizedBox(width: 8),
                        _buildMiniPill('Skills', '${report.resumeFactorScore}/25'),
                        const SizedBox(width: 8),
                        _buildMiniPill('Pipeline', '${report.activityFactorScore}/25'),
                        const SizedBox(width: 8),
                        _buildMiniPill('Conversion', '${report.conversionFactorScore}/25'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Recruiter Visibility & Search Impact Section
              Text('Recruiter Visibility & Impact', style: AppTypography.headlineSm),
              const SizedBox(height: 4),
              Text(
                'Direct impact of your health score on ATS and recruiter discovery',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildImpactCard(
                      value: report.overallScore >= 80
                          ? 'Top 8%'
                          : (report.overallScore >= 65 ? 'Top 18%' : 'Top 45%'),
                      label: 'Candidate Rank',
                      subtext: 'In recruiter searches',
                      color: AppColors.primary,
                      icon: Icons.search_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildImpactCard(
                      value: report.overallScore >= 75 ? '3.4x' : '2.1x',
                      label: 'Profile Views',
                      subtext: 'Weekly discovery rate',
                      color: AppColors.accent,
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildImpactCard(
                      value: '98%',
                      label: 'ATS Parse Rate',
                      subtext: 'Clean formatting match',
                      color: AppColors.tertiary,
                      icon: Icons.fact_check_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4 Health Dimensions Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Health Dimensions (25 pts each)', style: AppTypography.headlineSm),
                  Text(
                    '${report.overallScore} / 100',
                    style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildDimensionTile(
                      icon: Icons.badge_outlined,
                      title: 'Profile Completion',
                      score: report.profileFactorScore,
                      maxScore: 25,
                      detail: '${user.profileCompletion}% complete • ${user.targetRole}',
                      onAction: () => _showQuickProfileModal(context, user),
                      actionLabel: report.profileFactorScore < 25 ? 'Quick Edit' : null,
                    ),
                    const Divider(height: 20, color: AppColors.borderSubtle),
                    _buildDimensionTile(
                      icon: Icons.verified_outlined,
                      title: 'Resume & Skill Verification',
                      score: report.resumeFactorScore,
                      maxScore: 25,
                      detail: '${user.skills.length} verified technical skills • Resume attached',
                      onAction: () => _showQuickSkillsModal(context, user),
                      actionLabel: report.resumeFactorScore < 25 ? 'Add Skills' : null,
                    ),
                    const Divider(height: 20, color: AppColors.borderSubtle),
                    _buildDimensionTile(
                      icon: Icons.rocket_launch_outlined,
                      title: 'Active Pipeline Momentum',
                      score: report.activityFactorScore,
                      maxScore: 25,
                      detail: '${apps.length} tracked applications in active pipeline',
                      onAction: () => _navigateToTab(1),
                      actionLabel: report.activityFactorScore < 25 ? 'Explore Jobs' : null,
                    ),
                    const Divider(height: 20, color: AppColors.borderSubtle),
                    _buildDimensionTile(
                      icon: Icons.forum_outlined,
                      title: 'Interview & Response Conversion',
                      score: report.conversionFactorScore,
                      maxScore: 25,
                      detail: '${apps.where((a) => a.status == 'shortlisted' || a.status == 'interview' || a.status == 'selected').length} interviews / shortlists recorded',
                      onAction: () => _navigateToTab(3),
                      actionLabel: 'View Tracker',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Actionable Optimization Steps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Actionable Optimization Steps', style: AppTypography.headlineSm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${report.actionableTips.length} Actions Available',
                      style: AppTypography.labelSm.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Complete any step to immediately increase your score in real time',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              ...report.actionableTips.map((tip) {
                final isProfile = tip.toLowerCase().contains('portfolio') || tip.toLowerCase().contains('profile');
                final isSkills = tip.toLowerCase().contains('skill');
                final isApply = tip.toLowerCase().contains('apply') || tip.toLowerCase().contains('pipeline');

                String actionText = 'Take Action';
                VoidCallback onAction = () {};

                if (isProfile) {
                  actionText = 'Complete Profile';
                  onAction = () => _showQuickProfileModal(context, user);
                } else if (isSkills) {
                  actionText = 'Add Skills';
                  onAction = () => _showQuickSkillsModal(context, user);
                } else if (isApply) {
                  actionText = 'Explore Jobs';
                  onAction = () => _navigateToTab(1);
                } else {
                  actionText = 'View Tracker';
                  onAction = () => _navigateToTab(3);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onAction,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                            label: Text(actionText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Potential Target Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppSpacing.roundedLg,
                  boxShadow: AppSpacing.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.secondaryContainer, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Target Potential: 100 / 100',
                          style: AppTypography.titleMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Achieving an Application Health Score of 90+ places your profile at the top of recruiter searches with up to 3.4x higher interview conversions.',
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.labelSm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard({
    required String value,
    required String label,
    required String subtext,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 18,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtext,
            style: AppTypography.bodySm.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionTile({
    required IconData icon,
    required String title,
    required int score,
    required int maxScore,
    required String detail,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final ratio = (score / maxScore.toDouble()).clamp(0.0, 1.0);
    final isMax = score >= 22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isMax ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: isMax ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        '$score / $maxScore pts',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isMax ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppSpacing.roundedFull,
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHigh,
            color: isMax ? AppColors.accent : AppColors.primary,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.tertiary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

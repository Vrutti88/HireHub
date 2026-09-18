import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/job_fit_calculator.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/job_card.dart';
import '../interviews/interview_prep_screen.dart';
import '../interviews/interviews_calendar_screen.dart';
import '../jobs/job_details_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/job_search_screen.dart';
import '../settings/application_health_screen.dart';
import '../skills/skill_development_screen.dart';
import '../skills/skill_progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  static const List<Map<String, dynamic>> _domainCategories = [
    {
      'id': 'Mobile',
      'title': 'Mobile Apps',
      'subtitle': 'Flutter • iOS • Android',
      'icon': Icons.phone_android_rounded,
      'color': AppColors.primary,
      'badge': '7 Roles',
    },
    {
      'id': 'Frontend',
      'title': 'Frontend Web',
      'subtitle': 'React • Next.js • Web',
      'icon': Icons.laptop_chromebook_rounded,
      'color': Color(0xFF00897B),
      'badge': '3 Roles',
    },
    {
      'id': 'Backend',
      'title': 'Backend Systems',
      'subtitle': 'Go • Python • Node.js',
      'icon': Icons.dns_rounded,
      'color': Color(0xFF3949AB),
      'badge': '3 Roles',
    },
    {
      'id': 'AI/ML',
      'title': 'AI & ML',
      'subtitle': 'PyTorch • LLMs • Data',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFF8E24AA),
      'badge': '3 Roles',
    },
    {
      'id': 'Cloud/DevOps',
      'title': 'Cloud & DevOps',
      'subtitle': 'AWS • Kubernetes • SRE',
      'icon': Icons.cloud_outlined,
      'color': Color(0xFF0288D1),
      'badge': '2 Roles',
    },
    {
      'id': 'Design',
      'title': 'Product Design',
      'subtitle': 'Figma • Design Systems',
      'icon': Icons.palette_outlined,
      'color': Color(0xFFE65100),
      'badge': '1 Role',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final jobProvider = context.watch<JobProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final interviewProvider = context.watch<InterviewProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final skillProvider = context.watch<SkillProvider>();

    final jobs = user != null ? jobProvider.getFilteredJobs(user) : jobProvider.allJobs;
    final topPickJob = jobs.isNotEmpty ? jobs.first : null;
    final topPickFit = (topPickJob != null && user != null)
        ? JobFitCalculator.calculate(user: user, job: topPickJob).overallScore
        : 85;
    final topRecommended = jobs.take(4).toList();
    final upcomingInterview = interviewProvider.interviews.isNotEmpty ? interviewProvider.interviews.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await jobProvider.loadJobs();
            if (user != null) {
              await appProvider.loadApplications(user.uid);
              await notifProvider.loadData(user.uid);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // App Logo (matching Splash Screen)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.work_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_getTimeGreeting()}, ${(user?.name.trim().isNotEmpty == true) ? user!.name.trim().split(" ").first : "Candidate"} 👋',
                                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.targetRole.isNotEmpty == true ? user!.targetRole : 'Job Seeker',
                                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Badge(
                        isLabelVisible: notifProvider.unreadCount > 0,
                        label: Text(notifProvider.unreadCount.toString()),
                        backgroundColor: AppColors.danger,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Prompt Launcher Card
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JobSearchScreen()),
                    );
                  },
                  borderRadius: AppSpacing.roundedMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedMd,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search 19+ tech roles, skills, or companies...',
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Section: Browse by Domain
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Browse by Domain', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JobSearchScreen()),
                        );
                      },
                      child: Text(
                        'View All Roles →',
                        style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Domain Category Carousel
                SizedBox(
                  height: 98,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _domainCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final domain = _domainCategories[index];
                      final color = domain['color'] as Color;
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => JobSearchScreen(initialCategory: domain['id'] as String),
                            ),
                          );
                        },
                        borderRadius: AppSpacing.roundedMd,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppSpacing.roundedMd,
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppSpacing.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: AppSpacing.roundedSm,
                                    ),
                                    child: Icon(domain['icon'] as IconData, size: 18, color: color),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: AppSpacing.roundedFull,
                                    ),
                                    child: Text(
                                      domain['badge'] as String,
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    domain['title'] as String,
                                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    domain['subtitle'] as String,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Top Match Spotlight Banner (Highest Fit Role)
                if (topPickJob != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2E4D), Color(0xFF163E66)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppSpacing.roundedLg,
                      boxShadow: AppSpacing.elevatedShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: AppSpacing.roundedFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'TOP PICK FOR YOU • $topPickFit% MATCH',
                                    style: AppTypography.labelSm.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              topPickJob.formattedSalary,
                              style: AppTypography.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          topPickJob.title,
                          style: AppTypography.headlineSm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${topPickJob.companyName} • ${topPickJob.location} (${topPickJob.workMode})',
                          style: AppTypography.bodySm.copyWith(color: AppColors.surfaceContainerHigh),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 38),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => JobDetailsScreen(job: topPickJob)),
                                  );
                                },
                                child: const Text('View Role & Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Live Improvement Feedback Toast (if skill updated)
                if (skillProvider.lastImprovementFeedback != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: AppSpacing.roundedMd,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            skillProvider.lastImprovementFeedback!,
                            style: AppTypography.labelSm.copyWith(color: AppColors.accent),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.accent),
                          onPressed: () => skillProvider.clearImprovementFeedback(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],

                // Upcoming Interview Card (if scheduled)
                if (upcomingInterview != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedLg,
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: AppSpacing.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.infoBg,
                                borderRadius: AppSpacing.roundedFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.event_available_rounded, size: 12, color: AppColors.info),
                                  const SizedBox(width: 4),
                                  Text(
                                    'UPCOMING INTERVIEW',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'In 2 Days',
                              style: AppTypography.labelSm.copyWith(color: AppColors.info, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          upcomingInterview.roundName,
                          style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${upcomingInterview.companyName} • ${upcomingInterview.type}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const InterviewPrepScreen()),
                                  );
                                },
                                icon: const Icon(Icons.help_outline_rounded, size: 16),
                                label: const Text('Prep Questions', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const InterviewsCalendarScreen()),
                                  );
                                },
                                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                                label: const Text('View Calendar', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Application Pipeline Summary Card
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ApplicationHealthScreen()),
                  ),
                  borderRadius: AppSpacing.roundedLg,
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Application Pipeline', style: AppTypography.titleSm),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
                              ],
                            ),
                            Text(
                              '${appProvider.applications.length} Active',
                              style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPipelineStage(
                            'Applied',
                            appProvider.applications.where((a) => a.status == 'applied').length.toString(),
                            AppColors.primary,
                          ),
                          _buildPipelineDivider(),
                          _buildPipelineStage(
                            'Viewed',
                            appProvider.applications.where((a) => a.status == 'viewed').length.toString(),
                            AppColors.tertiary,
                          ),
                          _buildPipelineDivider(),
                          _buildPipelineStage(
                            'Shortlisted',
                            appProvider.applications.where((a) => a.status == 'shortlisted').length.toString(),
                            AppColors.accent,
                          ),
                          _buildPipelineDivider(),
                          _buildPipelineStage(
                            'Interviews',
                            appProvider.applications.where((a) => a.status == 'interview').length.toString(),
                            AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

                // Skill Gap ROI / Improve Job Fit Card (Stitch Screen 4 highlight)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF12355B), Color(0xFF0A223B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppSpacing.roundedLg,
                    boxShadow: AppSpacing.elevatedShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: AppSpacing.roundedFull,
                            ),
                            child: Text(
                              '+12% FIT BOOST AVAILABLE',
                              style: AppTypography.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Improve Your Job Fit',
                        style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Closing the REST API gap alone increases your fit score to 84% across 14 matching roles.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.surfaceContainerHigh, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 42),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SkillDevelopmentScreen()),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('Start REST API Roadmap'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.insights_rounded, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SkillProgressScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Recommended Jobs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recommended Jobs', style: AppTypography.headlineSm),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JobSearchScreen()),
                        );
                      },
                      child: Text(
                        'See All (${jobs.length}) →',
                        style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Job List
                ...topRecommended.map((job) {
                  return JobCard(
                    job: job,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStage(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTypography.metricMd.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSm.copyWith(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPipelineDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
    );
  }
}

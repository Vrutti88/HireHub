import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../providers/saved_jobs_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/job_card.dart';
import '../../widgets/primary_button.dart';
import 'decision_matrix_screen.dart';
import 'job_comparison_screen.dart';
import 'job_details_screen.dart';
import '../main_navigation_screen.dart';
import '../search/job_search_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCompareMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedJobsProvider = context.watch<SavedJobsProvider>();
    final jobProvider = context.watch<JobProvider>();
    final allJobs = jobProvider.allJobs;

    final savedJobs = allJobs.where((j) => savedJobsProvider.isSaved(j.id)).toList();
    final recentJobs = savedJobsProvider.recentlyViewedJobIds
        .map((id) => allJobs.firstWhere((j) => j.id == id, orElse: () => allJobs.first))
        .toSet()
        .toList();

    final selectedIds = savedJobsProvider.selectedForCompareIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved & Compare'),
        actions: [
          if (savedJobs.isNotEmpty)
            TextButton.icon(
              icon: Icon(
                _isCompareMode ? Icons.close_rounded : Icons.compare_arrows_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                _isCompareMode ? 'Done' : 'Compare',
                style: AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
              onPressed: () {
                setState(() {
                  _isCompareMode = !_isCompareMode;
                  if (!_isCompareMode) {
                    savedJobsProvider.clearCompareSelection();
                  }
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Saved (${savedJobs.length})'),
            Tab(text: 'Recently Viewed (${recentJobs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Saved Jobs Tab
          savedJobs.isEmpty
              ? EmptyStateView(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No saved jobs yet',
                  subtitle: 'Tap the bookmark icon on any job card to save it for later review.',
                  actionText: 'Explore Jobs',
                  onAction: () {
                    final switched = MainNavigationScreen.switchTab(context, 1);
                    if (!switched) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JobSearchScreen()),
                      );
                    }
                  },
                )
              : _buildJobList(savedJobs, savedJobsProvider),

          // Recently Viewed Tab
          recentJobs.isEmpty
              ? EmptyStateView(
                  icon: Icons.history_rounded,
                  title: 'No recently viewed jobs',
                  subtitle: 'Jobs you view will automatically appear here for quick access.',
                  actionText: 'Explore Jobs',
                  onAction: () {
                    final switched = MainNavigationScreen.switchTab(context, 1);
                    if (!switched) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JobSearchScreen()),
                      );
                    }
                  },
                )
              : _buildJobList(recentJobs, savedJobsProvider),
        ],
      ),
      bottomSheet: _isCompareMode && selectedIds.length >= 2
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppSpacing.bottomNavShadow,
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final selectedJobs = allJobs.where((j) => selectedIds.contains(j.id)).toList();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JobComparisonScreen(jobs: selectedJobs),
                          ),
                        );
                      },
                      child: Text('Compare (${selectedIds.length})'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Decision Matrix',
                      onPressed: () {
                        final selectedJobs = allJobs.where((j) => selectedIds.contains(j.id)).toList();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DecisionMatrixScreen(jobs: selectedJobs),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildJobList(List<JobModel> jobs, SavedJobsProvider savedJobsProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final isSelected = savedJobsProvider.selectedForCompareIds.contains(job.id);

        return JobCard(
          job: job,
          isSelectionMode: _isCompareMode,
          isSelected: isSelected,
          onSelectionChanged: (_) => savedJobsProvider.toggleCompareSelection(job.id),
          onTap: () {
            if (_isCompareMode) {
              savedJobsProvider.toggleCompareSelection(job.id);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
              );
            }
          },
        );
      },
    );
  }
}

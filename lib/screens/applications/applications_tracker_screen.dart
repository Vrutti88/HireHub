import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../providers/application_provider.dart';
import '../../widgets/application_card.dart';
import '../../widgets/empty_state_view.dart';
import 'application_details_screen.dart';
import '../main_navigation_screen.dart';
import '../search/job_search_screen.dart';

class ApplicationsTrackerScreen extends StatelessWidget {
  const ApplicationsTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final tabs = ['All', 'Applied', 'Shortlisted', 'Interviews'];
    final filtered = appProvider.filteredApplications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Applications Pipeline'),
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = appProvider.activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => appProvider.setActiveTab(tab),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Application Cards List
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.work_outline_rounded,
                    title: 'No applications in this stage',
                    subtitle: 'Explore recommended jobs matching your profile and submit verified applications.',
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
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final app = filtered[index];
                      return ApplicationCard(
                        application: app,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailsScreen(application: app),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

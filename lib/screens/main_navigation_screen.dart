import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/interview_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/saved_jobs_provider.dart';
import 'applications/applications_tracker_screen.dart';
import 'home/home_screen.dart';
import 'jobs/saved_jobs_screen.dart';
import 'profile/candidate_profile_screen.dart';
import 'search/job_search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  /// Switches the active tab on the nearest [MainNavigationScreen] ancestor.
  static bool switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
    if (state != null) {
      state.setTab(index);
      return true;
    }
    return false;
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  void setTab(int index) {
    if (index >= 0 && index < _screens.length && _currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    JobSearchScreen(),
    SavedJobsScreen(),
    ApplicationsTrackerScreen(),
    CandidateProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid = auth.user?.uid ?? '';
      if (uid.isNotEmpty) {
        context.read<ApplicationProvider>().loadApplications(uid);
        context.read<InterviewProvider>().loadInterviews(uid);
        context.read<NotificationProvider>().loadData(uid);
        context.read<SavedJobsProvider>().loadSavedJobs(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appCount = context.watch<ApplicationProvider>().applications.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppSpacing.bottomNavShadow,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.surfaceContainerHigh,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              label: 'Search',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primary),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: appCount > 0,
                label: Text(appCount.toString()),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.work_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: appCount > 0,
                label: Text(appCount.toString()),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.work_rounded, color: AppColors.primary),
              ),
              label: 'Applications',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

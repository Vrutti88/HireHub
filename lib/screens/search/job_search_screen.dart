import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/job_card.dart';
import '../../widgets/primary_button.dart';
import '../jobs/job_details_screen.dart';

class JobSearchScreen extends StatefulWidget {
  final String? initialCategory;

  const JobSearchScreen({super.key, this.initialCategory});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _quickCategories = const [
    {'id': 'All', 'label': 'All Roles'},
    {'id': 'Best Fit', 'label': '🔥 Best Fit (>80%)'},
    {'id': 'Remote', 'label': '🌐 Remote'},
    {'id': 'Mobile', 'label': '📱 Mobile'},
    {'id': 'Frontend', 'label': '💻 Frontend'},
    {'id': 'Backend', 'label': '⚙️ Backend'},
    {'id': 'AI/ML', 'label': '🤖 AI & ML'},
    {'id': 'Cloud/DevOps', 'label': '☁️ Cloud & SRE'},
    {'id': 'Design', 'label': '🎨 UI/UX Design'},
    {'id': 'High Pay', 'label': '💰 High Pay (₹20L+)'},
  ];

  @override
  void initState() {
    super.initState();
    final jobProvider = context.read<JobProvider>();
    _searchCtrl.text = jobProvider.filters.safeSearchQuery;

    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        jobProvider.setCategory(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    final jobProvider = context.read<JobProvider>();
    var currentFilters = jobProvider.filters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filter Tech Roles', style: AppTypography.headlineSm),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              currentFilters = const JobFilterOptions();
                            });
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Work Mode
                    Text('Work Mode', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Any', 'Remote', 'Hybrid', 'On-site'].map((mode) {
                        final isSelected = currentFilters.safeWorkMode == mode;
                        return ChoiceChip(
                          label: Text(mode),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() => currentFilters = currentFilters.copyWith(workMode: mode));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Minimum Salary Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Minimum Salary', style: AppTypography.labelMd),
                        Text(
                          currentFilters.safeMinSalary > 0
                              ? '₹${currentFilters.safeMinSalary.round()} LPA+'
                              : 'Any Salary',
                          style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Slider(
                      value: currentFilters.safeMinSalary,
                      min: 0,
                      max: 35,
                      divisions: 14,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setModalState(() => currentFilters = currentFilters.copyWith(minSalary: val));
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Filter
                    Text('Tech Hub / Location', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Any', 'Bangalore', 'Mumbai', 'Hyderabad', 'Pune', 'Gurugram', 'Remote'].map((loc) {
                        final isSelected = currentFilters.safeLocation == loc;
                        return ChoiceChip(
                          label: Text(loc),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() => currentFilters = currentFilters.copyWith(location: loc));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Job Type
                    Text('Employment Type', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Any', 'Full-time', 'Contract', 'Internship'].map((type) {
                        final isSelected = currentFilters.safeJobType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() => currentFilters = currentFilters.copyWith(jobType: type));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    PrimaryButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        jobProvider.updateFilters(currentFilters);
                        Navigator.of(ctx).pop();
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final jobProvider = context.watch<JobProvider>();
    final filteredJobs = user != null ? jobProvider.getFilteredJobs(user) : jobProvider.allJobs;
    final filters = jobProvider.filters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Find Tech Jobs', style: AppTypography.titleMd),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.hasActiveCustomFilters,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: _openFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => jobProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search roles, companies, or tech stack (e.g. Flutter, Go, React)...',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                jobProvider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Quick Category Pills Bar
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _quickCategories[index];
                      final isSelected = filters.safeCategory == cat['id'];
                      return ChoiceChip(
                        label: Text(cat['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        onSelected: (_) {
                          jobProvider.setCategory(cat['id']!);
                        },
                      );
                    },
                  ),
                ),

                // Active Filters Chips (if any applied)
                if (filters.hasActiveCustomFilters) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Filtered: ',
                          style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (filters.safeCategory != 'All')
                                  _buildActiveFilterTag(
                                    filters.safeCategory,
                                    () => jobProvider.setCategory('All'),
                                  ),
                                if (filters.safeWorkMode != 'Any')
                                  _buildActiveFilterTag(
                                    filters.safeWorkMode,
                                    () => jobProvider.updateFilters(filters.copyWith(workMode: 'Any')),
                                  ),
                                if (filters.safeLocation != 'Any')
                                  _buildActiveFilterTag(
                                    filters.safeLocation,
                                    () => jobProvider.updateFilters(filters.copyWith(location: 'Any')),
                                  ),
                                if (filters.safeMinSalary > 0)
                                  _buildActiveFilterTag(
                                    '₹${filters.safeMinSalary.round()}L+',
                                    () => jobProvider.updateFilters(filters.copyWith(minSalary: 0)),
                                  ),
                                TextButton(
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    jobProvider.resetFilters();
                                  },
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                  child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 6),
                const Divider(height: 1),

                // Results Count and Sort Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredJobs.length} Positions Available',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: const ['relevance', 'newest', 'salary_high', 'rating'].contains(filters.safeSortBy)
                              ? filters.safeSortBy
                              : 'relevance',
                          style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                          icon: const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
                          items: const [
                            DropdownMenuItem(value: 'relevance', child: Text('Sort: Best Fit')),
                            DropdownMenuItem(value: 'newest', child: Text('Sort: Newest First')),
                            DropdownMenuItem(value: 'salary_high', child: Text('Sort: Highest CTC')),
                            DropdownMenuItem(value: 'rating', child: Text('Sort: Top Rated')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              jobProvider.updateFilters(filters.copyWith(sortBy: val));
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
          const Divider(height: 1),

          // Results List
          Expanded(
            child: filteredJobs.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No matching jobs found',
                    subtitle: 'Try adjusting your search keywords, clearing categories, or lowering salary requirements.',
                    actionText: 'Reset Filters',
                    onAction: () {
                      _searchCtrl.clear();
                      jobProvider.resetFilters();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return JobCard(
                        job: job,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
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

  Widget _buildActiveFilterTag(String? label, VoidCallback onRemove) {
    if (label == null || label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(color: AppColors.tertiaryContainer),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontSize: 11),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 13, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

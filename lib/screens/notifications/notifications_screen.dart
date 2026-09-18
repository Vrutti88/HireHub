import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/job_alert_model.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../interviews/interviews_calendar_screen.dart';
import '../skills/skill_development_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _showCreateAlertModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final keywordsCtrl = TextEditingController(text: 'Flutter, Mobile');
    final notifProvider = context.read<NotificationProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Job Alert', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Alert Name (e.g. Remote Flutter Roles)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keywordsCtrl,
              decoration: const InputDecoration(labelText: 'Keywords (comma separated)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                final newAlert = JobAlertModel(
                  id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
                  userId: auth.user?.uid ?? 'uid_current_user',
                  title: titleCtrl.text.trim(),
                  keywords: keywordsCtrl.text.trim(),
                  createdAt: DateTime.now(),
                );
                notifProvider.addJobAlert(newAlert);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save Alert'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.filteredNotifications;
    final jobAlerts = notifProvider.jobAlerts;
    final tabs = ['All', 'Interviews', 'Applications'];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Notifications & Alerts'),
          actions: [
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(context.read<AuthProvider>().user?.uid ?? ''),
              child: const Text('Read All'),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Notifications Feed'),
              Tab(text: 'Job Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Notifications Feed
            Column(
              children: [
                // Category Pills
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: tabs.map((cat) {
                      final isSelected = notifProvider.activeCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => notifProvider.setActiveCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: notifications.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.notifications_none_rounded,
                          title: 'You\'re all caught up',
                          subtitle: 'No new notifications right now.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.screenMargin),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return _buildNotificationCard(context, notif, notifProvider);
                          },
                        ),
                ),
              ],
            ),

            // Tab 2: Job Alerts
            Scaffold(
              backgroundColor: AppColors.background,
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_alert_rounded),
                label: const Text('Create Alert'),
                onPressed: () => _showCreateAlertModal(context),
              ),
              body: jobAlerts.isEmpty
                  ? EmptyStateView(
                      icon: Icons.add_alert_rounded,
                      title: 'No Job Alerts Created',
                      subtitle: 'Set up custom alerts to receive daily or weekly updates on high-fit roles.',
                      actionText: 'Create Alert',
                      onAction: () => _showCreateAlertModal(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.screenMargin),
                      itemCount: jobAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = jobAlerts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppSpacing.roundedLg,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(alert.title, style: AppTypography.titleSm),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Keywords: ${alert.keywords} • ${alert.frequency}',
                                      style: AppTypography.bodySm.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: alert.isActive,
                                activeThumbColor: AppColors.accent,
                                onChanged: (_) => notifProvider.toggleJobAlert(alert.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notif,
    NotificationProvider notifProvider,
  ) {
    final timeFormat = DateFormat('MMM dd, hh:mm a');

    return InkWell(
      onTap: () {
        notifProvider.markAsRead(notif.id);
        if (notif.routeTarget == '/interviews') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InterviewsCalendarScreen()),
          );
        } else if (notif.routeTarget == '/skills') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SkillDevelopmentScreen()),
          );
        }
      },
      borderRadius: AppSpacing.roundedLg,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.surfaceContainerLow,
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(
            color: notif.isCritical ? AppColors.warning : AppColors.border,
            width: notif.isCritical ? 1.5 : 1.0,
          ),
          boxShadow: AppSpacing.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notif.isCritical ? AppColors.warningBg : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.isCritical ? Icons.alarm_rounded : Icons.info_outline_rounded,
                color: notif.isCritical ? AppColors.warning : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(notif.message, style: AppTypography.bodySm),
                  const SizedBox(height: 6),
                  Text(
                    timeFormat.format(notif.createdAt),
                    style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

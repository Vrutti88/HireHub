import 'package:flutter/material.dart';
import '../models/job_alert_model.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<NotificationModel> _notifications = [];
  List<JobAlertModel> _jobAlerts = [];
  bool _isLoading = false;
  String _activeCategory = 'All';

  NotificationProvider(this._firestoreService);

  List<NotificationModel> get notifications => _notifications;
  List<JobAlertModel> get jobAlerts => _jobAlerts;
  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadData(String userId) async {
    if (userId.isEmpty) {
      _notifications = [];
      _jobAlerts = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _notifications = await _firestoreService.getNotifications(userId);
    _jobAlerts = await _firestoreService.getJobAlerts(userId);
    _isLoading = false;
    notifyListeners();
  }

  void setActiveCategory(String cat) {
    _activeCategory = cat;
    notifyListeners();
  }

  List<NotificationModel> get filteredNotifications {
    if (_activeCategory == 'All') return _notifications;
    if (_activeCategory == 'Interviews') {
      return _notifications.where((n) => n.type == 'interview').toList();
    }
    if (_activeCategory == 'Applications') {
      return _notifications.where((n) => n.type == 'application' || n.type == 'offer').toList();
    }
    return _notifications;
  }

  Future<void> markAsRead(String id) async {
    await _firestoreService.markNotificationAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _firestoreService.markAllNotificationsAsRead(userId);
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  Future<void> addJobAlert(JobAlertModel alert) async {
    await _firestoreService.saveJobAlert(alert);
    _jobAlerts.add(alert);
    notifyListeners();
  }

  Future<void> toggleJobAlert(String alertId) async {
    await _firestoreService.toggleJobAlert(alertId);
    final idx = _jobAlerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _jobAlerts[idx] = _jobAlerts[idx].copyWith(isActive: !_jobAlerts[idx].isActive);
      notifyListeners();
    }
  }

  void clear() {
    _notifications = [];
    _jobAlerts = [];
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/firestore_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String _activeTab = 'All';

  ApplicationProvider(this._firestoreService);

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String get activeTab => _activeTab;

  Future<void> loadApplications(String userId) async {
    if (userId.isEmpty) {
      _applications = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _applications = await _firestoreService.getApplications(userId);
    _isLoading = false;
    notifyListeners();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  List<ApplicationModel> get filteredApplications {
    if (_activeTab == 'All') return _applications;
    return _applications.where((a) {
      if (_activeTab == 'Interviews') return a.status == 'interview';
      if (_activeTab == 'Shortlisted') return a.status == 'shortlisted';
      if (_activeTab == 'Applied') return a.status == 'applied' || a.status == 'viewed';
      return a.status.toLowerCase() == _activeTab.toLowerCase();
    }).toList();
  }

  Future<bool> submitApplication(ApplicationModel application) async {
    try {
      final created = await _firestoreService.submitApplication(application);
      _applications.removeWhere((a) => a.id == created.id);
      _applications.insert(0, created);
      notifyListeners();
      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateStatus(String applicationId, String newStatus) async {
    await _firestoreService.updateApplicationStatus(applicationId, newStatus);
    final idx = _applications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      final old = _applications[idx];
      _applications[idx] = old.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void clear() {
    _applications = [];
    notifyListeners();
  }
}

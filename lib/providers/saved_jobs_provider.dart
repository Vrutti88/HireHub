import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class SavedJobsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  Set<String> _savedJobIds = {};
  List<String> _recentlyViewedJobIds = [];
  final Set<String> _selectedForCompareIds = {};
  String? _currentUserId;

  SavedJobsProvider(this._firestoreService) {
    _recentlyViewedJobIds = List.from(_firestoreService.getRecentlyViewedJobIds());
  }

  Set<String> get savedJobIds => _savedJobIds;
  List<String> get recentlyViewedJobIds => _recentlyViewedJobIds;
  Set<String> get selectedForCompareIds => _selectedForCompareIds;

  bool isSaved(String jobId) => _savedJobIds.contains(jobId);

  Future<void> loadSavedJobs(String userId) async {
    _currentUserId = userId;
    if (userId.isEmpty) {
      _savedJobIds = {};
      notifyListeners();
      return;
    }
    _savedJobIds = Set.from(await _firestoreService.getSavedJobIds(userId));
    notifyListeners();
  }

  Future<void> toggleSave(String jobId, [String? userId]) async {
    final uid = userId ?? _currentUserId ?? '';
    await _firestoreService.toggleSaveJob(uid, jobId);
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
    notifyListeners();
  }

  void recordView(String jobId) {
    _firestoreService.recordJobView(jobId);
    _recentlyViewedJobIds = List.from(_firestoreService.getRecentlyViewedJobIds());
    notifyListeners();
  }

  void toggleCompareSelection(String jobId) {
    if (_selectedForCompareIds.contains(jobId)) {
      _selectedForCompareIds.remove(jobId);
    } else {
      if (_selectedForCompareIds.length < 3) {
        _selectedForCompareIds.add(jobId);
      }
    }
    notifyListeners();
  }

  void clearCompareSelection() {
    _selectedForCompareIds.clear();
    notifyListeners();
  }

  void clear() {
    _savedJobIds = {};
    _selectedForCompareIds.clear();
    _currentUserId = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/interview_model.dart';
import '../services/firestore_service.dart';

class InterviewProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<InterviewModel> _interviews = [];
  bool _isLoading = false;

  InterviewProvider(this._firestoreService);

  List<InterviewModel> get interviews => _interviews;
  bool get isLoading => _isLoading;

  Future<void> loadInterviews(String userId) async {
    if (userId.isEmpty) {
      _interviews = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _interviews = await _firestoreService.getInterviews(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder(String interviewId) async {
    await _firestoreService.toggleInterviewReminder(interviewId);
    final idx = _interviews.indexWhere((i) => i.id == interviewId);
    if (idx != -1) {
      final old = _interviews[idx];
      _interviews[idx] = old.copyWith(reminderActive: !old.reminderActive);
      notifyListeners();
    }
  }

  void clear() {
    _interviews = [];
    notifyListeners();
  }
}

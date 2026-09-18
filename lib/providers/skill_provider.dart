import 'package:flutter/material.dart';
import '../models/learning_resource_model.dart';
import '../models/skill_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

class SkillProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<SkillModel> _skills = [];
  List<LearningResourceModel> _currentResources = [];
  String? _activeSkillId = 'skill_rest_api';
  bool _isLoading = false;
  String? _lastImprovementFeedback;

  SkillProvider(this._firestoreService) {
    loadSkills();
    if (_activeSkillId != null) {
      loadResourcesForSkill(_activeSkillId!);
    }
  }

  List<SkillModel> get skills => _skills;
  List<LearningResourceModel> get currentResources => _currentResources;
  String? get activeSkillId => _activeSkillId;
  bool get isLoading => _isLoading;
  String? get lastImprovementFeedback => _lastImprovementFeedback;

  Future<void> loadSkills() async {
    _skills = await _firestoreService.getSkills();
    notifyListeners();
  }

  Future<void> loadResourcesForSkill(String skillId) async {
    _activeSkillId = skillId;
    _isLoading = true;
    notifyListeners();
    _currentResources = await _firestoreService.getLearningResources(skillId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleResource(String resourceId, AuthProvider authProvider) async {
    await _firestoreService.toggleResourceCompletion(resourceId);
    final idx = _currentResources.indexWhere((r) => r.id == resourceId);
    if (idx != -1) {
      final updated = _currentResources[idx].copyWith(isCompleted: !_currentResources[idx].isCompleted);
      _currentResources[idx] = updated;

      // Check how many resources are complete for this skill
      final completedCount = _currentResources.where((r) => r.isCompleted).length;
      final total = _currentResources.length;
      final newPercentage = total > 0 ? ((completedCount / total) * 100).round() : 0;

      // Update skill mastery in user profile & recalculate fit!
      final skillName = updated.skillName;
      final user = authProvider.user;
      if (user != null) {
        final updatedSkills = Map<String, int>.from(user.skills);
        final oldLevel = updatedSkills[skillName] ?? 0;
        updatedSkills[skillName] = newPercentage;

        authProvider.updateProfile(skills: updatedSkills);

        if (newPercentage > oldLevel) {
          _lastImprovementFeedback = '$skillName mastery increased from $oldLevel% → $newPercentage%! Job Fit scores recalculated.';
        }
      }
      notifyListeners();
    }
  }

  void updateSkillProficiency(String skillName, int newLevel, AuthProvider authProvider) {
    final user = authProvider.user;
    if (user != null) {
      final updatedSkills = Map<String, int>.from(user.skills);
      final oldLevel = updatedSkills[skillName] ?? 0;
      updatedSkills[skillName] = newLevel;
      authProvider.updateProfile(skills: updatedSkills);
      _lastImprovementFeedback = '$skillName updated from $oldLevel% → $newLevel%. Verified across all matching job requirements.';
      notifyListeners();
    }
  }

  void clearImprovementFeedback() {
    _lastImprovementFeedback = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../core/utils/resume_parser.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _user = _authService.currentUser;
  }

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null || _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(name: name, email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? targetRole,
    int? experienceYears,
    String? location,
    double? expectedSalaryLPA,
    String? preferredWorkMode,
    String? preferredJobType,
    Map<String, int>? skills,
    String? resumeName,
    String? resumeUrl,
    List<String>? education,
    List<String>? experience,
    int? profileCompletion,
    bool? stealthMode,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      targetRole: targetRole,
      experienceYears: experienceYears,
      location: location,
      expectedSalaryLPA: expectedSalaryLPA,
      preferredWorkMode: preferredWorkMode,
      preferredJobType: preferredJobType,
      skills: skills,
      resumeName: resumeName,
      resumeUrl: resumeUrl,
      education: education,
      experience: experience,
      profileCompletion: profileCompletion ?? 80,
      stealthMode: stealthMode,
    );
    _authService.updateUser(_user!);
    notifyListeners();
  }

  List<String> parseResumeSkills(String resumeText) {
    return ResumeParser.detectSkills(resumeText);
  }

  void addSkillsToUser(List<String> detectedSkills) {
    if (_user == null) return;
    final updatedSkills = Map<String, int>.from(_user!.skills);
    for (final skill in detectedSkills) {
      if (!updatedSkills.containsKey(skill)) {
        updatedSkills[skill] = 75; // initial proficiency
      }
    }
    _user = _user!.copyWith(skills: updatedSkills);
    _authService.updateUser(_user!);
    notifyListeners();
  }
}

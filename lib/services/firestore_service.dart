import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/seed_data.dart';
import '../models/application_model.dart';
import '../models/company_model.dart';
import '../models/interview_model.dart';
import '../models/job_alert_model.dart';
import '../models/job_model.dart';
import '../models/learning_resource_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/skill_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  // Local reactive cache synchronized with Firestore
  final List<JobModel> _localJobs = [];
  final List<CompanyModel> _localCompanies = [];
  final List<SkillModel> _localSkills = [];
  final List<LearningResourceModel> _localLearningResources = [];
  final List<ApplicationModel> _localApplications = [];
  final List<InterviewModel> _localInterviews = [];
  final List<NotificationModel> _localNotifications = [];
  final List<JobAlertModel> _localJobAlerts = [];
  final Set<String> _localSavedJobIds = {};
  final List<String> _recentlyViewedJobIds = [];

  FirestoreService() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firestore instance not available: $e');
    }
    // Initialize base catalogs
    _localJobs.addAll(SeedData.jobs);
    _localCompanies.addAll(SeedData.companies);
    _localSkills.addAll(SeedData.skills);
    _localLearningResources.addAll(SeedData.learningResources);
  }

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  // ================= USERS =================

  Future<UserModel?> getUser(String uid) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      } catch (e) {
        debugPrint('Error getting user from Firestore: $e');
      }
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Error saving user to Firestore: $e');
      }
    }
  }

  // ================= JOBS =================

  Future<List<JobModel>> getJobs() async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!.collection('jobs').get();
        if (snap.docs.isNotEmpty) {
          final jobs = snap.docs.map((d) => JobModel.fromMap(d.data(), d.id)).toList();
          _localJobs.clear();
          _localJobs.addAll(jobs);
          return jobs;
        } else {
          // If remote jobs collection is freshly initialized and empty, seed it to Firestore
          await syncCatalogToFirestore();
        }
      } catch (e) {
        debugPrint('Error fetching jobs from Firestore: $e');
      }
    }
    return List.unmodifiable(_localJobs);
  }

  Future<JobModel?> getJobById(String id) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final doc = await _firestore!.collection('jobs').doc(id).get();
        if (doc.exists && doc.data() != null) {
          return JobModel.fromMap(doc.data()!, doc.id);
        }
      } catch (e) {
        debugPrint('Error getting job by id: $e');
      }
    }
    try {
      return _localJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Syncs default job catalog and company data to Firestore so database is populated
  Future<void> syncCatalogToFirestore() async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      final batch = _firestore!.batch();
      for (final job in SeedData.jobs) {
        final ref = _firestore!.collection('jobs').doc(job.id);
        batch.set(ref, job.toMap());
      }
      for (final company in SeedData.companies) {
        final ref = _firestore!.collection('companies').doc(company.id);
        batch.set(ref, company.toMap());
      }
      for (final skill in SeedData.skills) {
        final ref = _firestore!.collection('skills').doc(skill.id);
        batch.set(ref, skill.toMap());
      }
      await batch.commit();
      debugPrint('Successfully synced job and company catalog to Cloud Firestore!');
    } catch (e) {
      debugPrint('Firestore batch sync notice: $e');
    }
  }

  // ================= SAVED JOBS =================

  Future<Set<String>> getSavedJobIds(String userId) async {
    if (_isFirebaseAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('saved_jobs')
            .get();
        _localSavedJobIds.clear();
        for (final doc in snap.docs) {
          _localSavedJobIds.add(doc.id);
        }
        return Set.unmodifiable(_localSavedJobIds);
      } catch (e) {
        debugPrint('Error fetching saved jobs from Firestore: $e');
      }
    }
    return Set.unmodifiable(_localSavedJobIds);
  }

  Future<void> toggleSaveJob(String userId, String jobId) async {
    final willBeSaved = !_localSavedJobIds.contains(jobId);
    if (willBeSaved) {
      _localSavedJobIds.add(jobId);
    } else {
      _localSavedJobIds.remove(jobId);
    }

    if (_isFirebaseAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final ref = _firestore!
            .collection('users')
            .doc(userId)
            .collection('saved_jobs')
            .doc(jobId);
        if (willBeSaved) {
          await ref.set({
            'jobId': jobId,
            'savedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await ref.delete();
        }
      } catch (e) {
        debugPrint('Error updating saved job in Firestore: $e');
      }
    }
  }

  List<String> getRecentlyViewedJobIds() => List.unmodifiable(_recentlyViewedJobIds);

  void recordJobView(String jobId) {
    _recentlyViewedJobIds.remove(jobId);
    _recentlyViewedJobIds.insert(0, jobId);
    if (_recentlyViewedJobIds.length > 10) {
      _recentlyViewedJobIds.removeLast();
    }
  }

  // ================= APPLICATIONS =================

  Future<List<ApplicationModel>> getApplications(String userId) async {
    if (userId.isEmpty) return [];

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!
            .collection('applications')
            .where('userId', isEqualTo: userId)
            .get();
        if (snap.docs.isNotEmpty) {
          final apps = snap.docs.map((d) => ApplicationModel.fromMap(d.data(), d.id)).toList();
          _localApplications.clear();
          _localApplications.addAll(apps);
          return apps;
        }
      } catch (e) {
        debugPrint('Error getting applications from Firestore: $e');
      }
    }
    if (_localApplications.where((a) => a.userId == userId).isEmpty && userId.isNotEmpty) {
      _seedUserApplications(userId);
    }
    return _localApplications.where((a) => a.userId == userId).toList();
  }

  Future<ApplicationModel> submitApplication(ApplicationModel application) async {
    final existing = _localApplications.any(
      (a) => a.userId == application.userId && a.jobId == application.jobId && a.status != 'withdrawn',
    );
    if (existing) {
      throw Exception('You have already applied for this job.');
    }

    _localApplications.insert(0, application);

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('applications').doc(application.id).set(application.toMap());
      } catch (e) {
        debugPrint('Error submitting application to Firestore: $e');
      }
    }

    return application;
  }

  Future<void> updateApplicationStatus(String applicationId, String newStatus) async {
    final idx = _localApplications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      final old = _localApplications[idx];
      final newTimeline = List<ApplicationTimelineEvent>.from(old.timeline)
        ..add(
          ApplicationTimelineEvent(
            title: 'Status: ${newStatus.toUpperCase()}',
            description: 'Application advanced to $newStatus',
            timestamp: DateTime.now(),
          ),
        );
      _localApplications[idx] = old.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        timeline: newTimeline,
      );

      if (_isFirebaseAvailable && _firestore != null) {
        try {
          await _firestore!.collection('applications').doc(applicationId).update({
            'status': newStatus,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error updating application status in Firestore: $e');
        }
      }
    }
  }

  // ================= SKILLS & LEARNING =================

  Future<List<SkillModel>> getSkills() async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!.collection('skills').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => SkillModel.fromMap(d.data(), d.id)).toList();
        }
      } catch (_) {}
    }
    return List.unmodifiable(_localSkills);
  }

  Future<List<LearningResourceModel>> getLearningResources(String skillId) async {
    return _localLearningResources.where((r) => r.skillId == skillId).toList();
  }

  Future<void> toggleResourceCompletion(String resourceId) async {
    final idx = _localLearningResources.indexWhere((r) => r.id == resourceId);
    if (idx != -1) {
      final old = _localLearningResources[idx];
      _localLearningResources[idx] = old.copyWith(isCompleted: !old.isCompleted);
    }
  }

  // ================= INTERVIEWS =================

  Future<List<InterviewModel>> getInterviews(String userId) async {
    if (userId.isEmpty) return [];

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!
            .collection('interviews')
            .where('userId', isEqualTo: userId)
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => InterviewModel.fromMap(d.data(), d.id)).toList();
          _localInterviews.clear();
          _localInterviews.addAll(list);
          return list;
        }
      } catch (e) {
        debugPrint('Error getting interviews from Firestore: $e');
      }
    }
    if (_localInterviews.where((i) => i.userId == userId).isEmpty && userId.isNotEmpty) {
      _seedUserInterviews(userId);
    }
    return _localInterviews.where((i) => i.userId == userId).toList();
  }

  Future<void> toggleInterviewReminder(String interviewId) async {
    final idx = _localInterviews.indexWhere((i) => i.id == interviewId);
    if (idx != -1) {
      final old = _localInterviews[idx];
      _localInterviews[idx] = old.copyWith(reminderActive: !old.reminderActive);
    }
  }

  // ================= NOTIFICATIONS =================

  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (userId.isEmpty) return [];

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .get();
        if (snap.docs.isNotEmpty) {
          final notifs = snap.docs.map((d) => NotificationModel.fromMap(d.data(), d.id)).toList();
          _localNotifications.clear();
          _localNotifications.addAll(notifs);
          return notifs;
        }
      } catch (e) {
        debugPrint('Error getting notifications from Firestore: $e');
      }
    }
    if (_localNotifications.where((n) => n.userId == userId).isEmpty && userId.isNotEmpty) {
      _seedUserNotifications(userId);
    }
    return _localNotifications.where((n) => n.userId == userId).toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    final idx = _localNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _localNotifications[idx] = _localNotifications[idx].copyWith(isRead: true);
      if (_isFirebaseAvailable && _firestore != null) {
        try {
          await _firestore!.collection('notifications').doc(id).update({'isRead': true});
        } catch (_) {}
      }
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    for (int i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i].userId == userId) {
        _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
      }
    }
  }

  // ================= JOB ALERTS =================

  Future<List<JobAlertModel>> getJobAlerts(String userId) async {
    if (userId.isEmpty) return [];

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snap = await _firestore!
            .collection('job_alerts')
            .where('userId', isEqualTo: userId)
            .get();
        if (snap.docs.isNotEmpty) {
          final alerts = snap.docs.map((d) => JobAlertModel.fromMap(d.data(), d.id)).toList();
          _localJobAlerts.clear();
          _localJobAlerts.addAll(alerts);
          return alerts;
        }
      } catch (_) {}
    }
    return _localJobAlerts.where((a) => a.userId == userId).toList();
  }

  Future<void> saveJobAlert(JobAlertModel alert) async {
    final idx = _localJobAlerts.indexWhere((a) => a.id == alert.id);
    if (idx != -1) {
      _localJobAlerts[idx] = alert;
    } else {
      _localJobAlerts.add(alert);
    }
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('job_alerts').doc(alert.id).set(alert.toMap());
      } catch (_) {}
    }
  }

  Future<void> toggleJobAlert(String alertId) async {
    final idx = _localJobAlerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      final updated = _localJobAlerts[idx].copyWith(isActive: !_localJobAlerts[idx].isActive);
      _localJobAlerts[idx] = updated;
      if (_isFirebaseAvailable && _firestore != null) {
        try {
          await _firestore!.collection('job_alerts').doc(alertId).update({'isActive': updated.isActive});
        } catch (_) {}
      }
    }
  }

  // ================= COMPANIES & REVIEWS =================

  Future<List<CompanyModel>> getCompanies() async => List.unmodifiable(_localCompanies);

  Future<CompanyModel?> getCompanyById(String id) async {
    try {
      return _localCompanies.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ReviewModel>> getReviews(String companyId) async {
    return SeedData.reviews.where((r) => r.companyId == companyId).toList();
  }

  // ================= REPORTS =================

  Future<void> reportJob({
    required String userId,
    required String jobId,
    required String reason,
    required String description,
  }) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('reports').add({
          'userId': userId,
          'jobId': jobId,
          'reason': reason,
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  void _seedUserApplications(String userId) {
    _localApplications.addAll([
      ApplicationModel(
        id: 'app_${userId}_cloudmatrix',
        userId: userId,
        jobId: 'job_cloudmatrix_mobile',
        jobTitle: 'Junior Software Engineer (Mobile)',
        companyId: 'comp_cloudmatrix',
        companyName: 'CloudMatrix',
        location: 'Mumbai (Hybrid)',
        salaryFormatted: '₹8–12 LPA',
        resumeName: 'Candidate_Verified_Resume.pdf',
        status: 'interview',
        appliedAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        timeline: [
          ApplicationTimelineEvent(
            title: 'Application Submitted',
            description: 'Resume and profile forwarded to engineering team.',
            timestamp: DateTime.now().subtract(const Duration(days: 6)),
            isDone: true,
          ),
          ApplicationTimelineEvent(
            title: 'Profile Viewed',
            description: 'Technical recruiter reviewed verified Flutter skills.',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            isDone: true,
          ),
          ApplicationTimelineEvent(
            title: 'Shortlisted for Interview',
            description: 'Candidate passed algorithmic screening with 88% match.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isDone: true,
          ),
          ApplicationTimelineEvent(
            title: 'Technical Round 1 Scheduled',
            description: 'System architecture & live Flutter problem solving.',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            isDone: true,
          ),
        ],
        interviewId: 'int_${userId}_round1',
      ),
      ApplicationModel(
        id: 'app_${userId}_technova',
        userId: userId,
        jobId: 'job_technova_flutter',
        jobTitle: 'Senior Flutter Developer',
        companyId: 'comp_technova',
        companyName: 'TechNova Solutions',
        location: 'Mumbai (Hybrid)',
        salaryFormatted: '₹12–18 LPA',
        resumeName: 'Candidate_Verified_Resume.pdf',
        status: 'shortlisted',
        appliedAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        timeline: [
          ApplicationTimelineEvent(
            title: 'Application Submitted',
            description: 'Direct candidate application received.',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            isDone: true,
          ),
          ApplicationTimelineEvent(
            title: 'Shortlisted',
            description: 'Passed recruiter initial review.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isDone: true,
          ),
        ],
      ),
      ApplicationModel(
        id: 'app_${userId}_hypercart',
        userId: userId,
        jobId: 'job_hypercart_fe',
        jobTitle: 'Senior Frontend Engineer (React/Next.js)',
        companyId: 'comp_hypercart',
        companyName: 'HyperCart Commerce',
        location: 'Bangalore (Hybrid)',
        salaryFormatted: '₹18–28 LPA',
        resumeName: 'Candidate_Verified_Resume.pdf',
        status: 'applied',
        appliedAt: DateTime.now().subtract(const Duration(hours: 18)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
        timeline: [
          ApplicationTimelineEvent(
            title: 'Application Submitted',
            description: 'Profile queued for hiring manager triage.',
            timestamp: DateTime.now().subtract(const Duration(hours: 18)),
            isDone: true,
          ),
        ],
      ),
    ]);
  }

  void _seedUserInterviews(String userId) {
    _localInterviews.addAll([
      InterviewModel(
        id: 'int_${userId}_round1',
        userId: userId,
        applicationId: 'app_${userId}_cloudmatrix',
        jobId: 'job_cloudmatrix_mobile',
        jobTitle: 'Junior Software Engineer (Mobile)',
        companyName: 'CloudMatrix',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
        type: 'Online (Google Meet)',
        meetingLink: 'https://meet.google.com/hrc-tech-demo',
        roundName: 'Technical Architecture & Flutter Round',
        notes: 'Discussion on state management, asynchronous Dart, and custom animations.',
        reminderActive: true,
      ),
      InterviewModel(
        id: 'int_${userId}_technova',
        userId: userId,
        applicationId: 'app_${userId}_technova',
        jobId: 'job_technova_flutter',
        jobTitle: 'Senior Flutter Developer',
        companyName: 'TechNova Solutions',
        dateTime: DateTime.now().add(const Duration(days: 4, hours: 1)),
        type: 'Online (Zoom)',
        meetingLink: 'https://zoom.us/j/9876543210',
        roundName: 'Engineering Lead Conversation',
        notes: 'Discussion on past mobile app architectures and team collaboration.',
        reminderActive: false,
      ),
    ]);
  }

  void _seedUserNotifications(String userId) {
    _localNotifications.addAll([
      NotificationModel(
        id: 'notif_${userId}_1',
        userId: userId,
        title: 'Interview Scheduled: CloudMatrix',
        message: 'Technical Round 1 for Junior Software Engineer (Mobile) scheduled for tomorrow.',
        type: 'interview',
        isCritical: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        routeTarget: '/interviews',
      ),
      NotificationModel(
        id: 'notif_${userId}_2',
        userId: userId,
        title: 'Application Shortlisted',
        message: 'TechNova Solutions has shortlisted your profile for Senior Flutter Developer.',
        type: 'application',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        routeTarget: '/applications',
      ),
      NotificationModel(
        id: 'notif_${userId}_3',
        userId: userId,
        title: 'New Jobs Matching Your Verified Stack',
        message: '3 new Flutter & Dart roles added matching your career profile.',
        type: 'alert',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        routeTarget: '/search',
      ),
    ]);
  }
}

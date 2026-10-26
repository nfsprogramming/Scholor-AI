import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'auth_service.dart';

class Course {
  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final String duration;
  final double rating;
  final String description;
  final List<Lesson> lessons;
  bool isDownloaded;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.duration,
    required this.rating,
    required this.description,
    required this.lessons,
    this.isDownloaded = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? 'unknown_id',
      title: json['title']?.toString() ?? 'Untitled Course',
      instructor: json['instructor']?.toString() ?? 'Unknown Instructor',
      thumbnail: json['thumbnail']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '0h 0m',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      lessons: (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ?? [],
      isDownloaded: json['isDownloaded'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'instructor': instructor,
    'thumbnail': thumbnail,
    'duration': duration,
    'rating': rating,
    'description': description,
    'lessons': lessons.map((l) => l.toJson()).toList(),
    'isDownloaded': isDownloaded,
  };
}

class Lesson {
  final String id;
  final String title;
  final String duration;
  final String audioAsset;
  final String imageAsset;
  final List<SyncedLine> content;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.audioAsset,
    required this.imageAsset,
    required this.content,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? 'unknown_lesson',
      title: json['title']?.toString() ?? 'Untitled Lesson',
      duration: json['duration']?.toString() ?? '0:00',
      audioAsset: json['audioAsset']?.toString() ?? '',
      imageAsset: json['imageAsset']?.toString() ?? '',
      content: (json['content'] as List?)?.map((c) => SyncedLine.fromJson(c)).toList() ?? [],
      isCompleted: json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration': duration,
    'audioAsset': audioAsset,
    'imageAsset': imageAsset,
    'content': content.map((c) => c.toJson()).toList(),
    'isCompleted': isCompleted,
  };
}

class SyncedLine {
  final Duration timestamp;
  final String text;

  SyncedLine({required this.timestamp, required this.text});

  factory SyncedLine.fromJson(Map<String, dynamic> json) {
    return SyncedLine(
      timestamp: Duration(milliseconds: (json['timestamp'] as num?)?.toInt() ?? 0),
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.inMilliseconds,
    'text': text,
  };
}

class AppState with ChangeNotifier {
  List<Course> _allCourses = [];
  bool _isLoading = true;
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = "The Fluid Scholor";
  String? _userImage;

  String get userName => _userName;
  String? get userImage => _userImage;

  List<Course> get allCourses => _allCourses;
  List<Course> get downloadedCourses => _allCourses.where((c) => c.isDownloaded).toList();
  bool get isLoading => _isLoading;

  DateTime? lastSyncTime;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  final Map<String, double> _downloadingProgress = {};
  double getDownloadProgress(String courseId) => _downloadingProgress[courseId] ?? 0.0;
  bool isDownloading(String courseId) => _downloadingProgress.containsKey(courseId);

  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('courses_cache');
      final int? cachedSyncTime = prefs.getInt('last_sync_time');

      if (cachedSyncTime != null) {
        lastSyncTime = DateTime.fromMillisecondsSinceEpoch(cachedSyncTime);
      }

      if (cachedData != null) {
        try {
          final List decoded = jsonDecode(cachedData);
          _allCourses = decoded.map((c) => Course.fromJson(c)).toList();
          
          _userName = prefs.getString('user_name') ?? "The Fluid Scholor";
          _userImage = prefs.getString('user_image');
        } catch (e) {
          debugPrint("Error decoding cached courses: $e");
          _allCourses = _getDefaultMockData();
          await _saveToPrefs();
        }
      } else {
        _allCourses = _getDefaultMockData();
        await _saveToPrefs();
      }

      // Try to sync with cloud if logged in
      try {
        await refreshFromCloud();
      } catch (e) {
        debugPrint("Initial cloud refresh failed (probably offline): $e");
      }

      // Listen for auth changes to re-sync
      _auth.userStream.listen((user) {
        if (user != null) {
          refreshFromCloud();
        }
      }, onError: (e) => debugPrint("Auth Stream Error: $e"));

    } catch (e) {
      debugPrint("Critical AppState Init Error: $e");
      // Ensure we have at least defaults if initialization crashes hard
      _allCourses = _getDefaultMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).collection('data').doc('progress').get();
      if (!doc.exists) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      final Map<String, dynamic> data = doc.data()!;
      // data['progress'] is a Map<CourseId, Map<LessonId, bool>>
      // data['downloads'] is a List<CourseId>
      
      bool changed = false;
      final progress = data['progress'] as Map<String, dynamic>? ?? {};
      final downloads = List<String>.from(data['downloads'] ?? []);

      for (var course in _allCourses) {
        // Sync downloads
        if (downloads.contains(course.id)) {
          if (!course.isDownloaded) {
            course.isDownloaded = true;
            changed = true;
          }
        }

        // Sync lesson completion
        final courseProgress = progress[course.id] as Map<String, dynamic>? ?? {};
        for (var lesson in course.lessons) {
          if (courseProgress[lesson.id] == true) {
            if (!lesson.isCompleted) {
              lesson.isCompleted = true;
              changed = true;
            }
          }
        }
      }

      lastSyncTime = (data['lastUpdated'] as Timestamp?)?.toDate();

      // Sync user info
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _userName = userData['displayName'] ?? user.displayName ?? "The Fluid Scholor";
        _userImage = userData['photoUrl'] ?? user.photoURL;
        changed = true;
      }

      if (changed) {
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint("Error refreshing from cloud: $e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncToCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final Map<String, Map<String, bool>> progressMap = {};
      final List<String> downloadedIds = [];

      for (var course in _allCourses) {
        if (course.isDownloaded) downloadedIds.add(course.id);
        
        final Map<String, bool> lessonProgress = {};
        for (var lesson in course.lessons) {
          if (lesson.isCompleted) lessonProgress[lesson.id] = true;
        }
        if (lessonProgress.isNotEmpty) progressMap[course.id] = lessonProgress;
      }

      await _firestore.collection('users').doc(user.uid).collection('data').doc('progress').set({
        'progress': progressMap,
        'downloads': downloadedIds,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      lastSyncTime = DateTime.now();
      await _saveToPrefs();
    } catch (e) {
      debugPrint("Error syncing to cloud: $e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_allCourses.map((c) => c.toJson()).toList());
    await prefs.setString('courses_cache', encoded);
    await prefs.setString('user_name', _userName);
    if (_userImage != null) {
      await prefs.setString('user_image', _userImage!);
    } else {
      await prefs.remove('user_image');
    }
    if (lastSyncTime != null) {
      await prefs.setInt('last_sync_time', lastSyncTime!.millisecondsSinceEpoch);
    }
  }

  Future<void> toggleDownload(String courseId) async {
    final index = _allCourses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;

    if (_allCourses[index].isDownloaded) {
      // Uninstall/Remove
      _allCourses[index].isDownloaded = false;
      notifyListeners();
      await _saveToPrefs();
      syncToCloud();
    } else {
      // Simulate download process if not already downloading
      if (_downloadingProgress.containsKey(courseId)) return;

      _downloadingProgress[courseId] = 0.01;
      notifyListeners();

      // Simulated steps: 10 steps of 400ms = 4 seconds
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        _downloadingProgress[courseId] = i / 10.0;
        notifyListeners();
      }

      _downloadingProgress.remove(courseId);
      _allCourses[index].isDownloaded = true;
      notifyListeners();
      await _saveToPrefs();
      syncToCloud();
    }
  }

  Future<void> completeLesson(String courseId, String lessonId) async {
    final courseIndex = _allCourses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      final lessonIndex = _allCourses[courseIndex].lessons.indexWhere((l) => l.id == lessonId);
      if (lessonIndex != -1) {
        _allCourses[courseIndex].lessons[lessonIndex].isCompleted = true;
        await _saveToPrefs();
        syncToCloud(); // Async sync
        notifyListeners();
      }
    }
  }

  double getCourseProgress(String courseId) {
    final course = _allCourses.firstWhere((c) => c.id == courseId);
    if (course.lessons.isEmpty) return 0;
    final completedCount = course.lessons.where((l) => l.isCompleted).length;
    return completedCount / course.lessons.length;
  }

  List<Course> _getDefaultMockData() {
    return [
      Course(
        id: "python_master",
        title: "Master Modern Python: From Zero to Pro",
        instructor: "Dr. Angela Yu",
        thumbnail: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=600&auto=format&fit=crop",
        duration: "18h 45m",
        rating: 4.9,
        description: "The most comprehensive Python course available. Go from absolute beginner to building professional-grade applications involving AI, web development, and data science. Perfect for offline self-study.",
        isDownloaded: false,
        lessons: [
          Lesson(
            id: "py_1",
            title: "Introduction to Python & Setup",
            duration: "12:45",
            audioAsset: "audio/python_intro.mp3",
            imageAsset: "images/python_1.png",
            content: [
              SyncedLine(timestamp: const Duration(seconds: 0), text: "Welcome to the Master Modern Python course!"),
              SyncedLine(timestamp: const Duration(seconds: 4), text: "In this first lesson, we are going to set up your local environment."),
              SyncedLine(timestamp: const Duration(seconds: 8), text: "Python is one of the most versatile languages in the world."),
              SyncedLine(timestamp: const Duration(seconds: 12), text: "Whether you want to build websites, analyze data, or even train AI models, Python is the way to go."),
            ],
          ),
          Lesson(
            id: "py_2",
            title: "Variables and Data Types",
            duration: "15:20",
            audioAsset: "audio/python_datatypes.mp3",
            imageAsset: "images/python_2.png",
            content: [
              SyncedLine(timestamp: const Duration(seconds: 0), text: "Today we are diving into variables and data types."),
              SyncedLine(timestamp: const Duration(seconds: 5), text: "Think of a variable as a box that can store information."),
              SyncedLine(timestamp: const Duration(seconds: 10), text: "We'll cover integers, strings, floats, and booleans."),
            ],
          ),
          Lesson(
            id: "py_3",
            title: "Logic and Control Flow",
            duration: "22:10",
            audioAsset: "audio/python_logic.mp3",
            imageAsset: "images/python_3.png",
            content: [
              SyncedLine(timestamp: const Duration(seconds: 0), text: "Moving on to control flow: if, else, and elif statements."),
              SyncedLine(timestamp: const Duration(seconds: 6), text: "This is how we give our programs the ability to make decisions."),
            ],
          ),
        ],
      ),
      Course(
        id: "ai_funda",
        title: "AI Fundamentals for Everyone",
        instructor: "Andrew Ng",
        thumbnail: "https://images.unsplash.com/photo-1677442136019-21780ecad995?q=80&w=600&auto=format&fit=crop",
        duration: "6h 20m",
        rating: 4.8,
        description: "Understand the core concepts behind modern AI, from neural networks to large language models. No coding experience required.",
        isDownloaded: false,
        lessons: [
          Lesson(
            id: "ai_1",
            title: "What is Artificial Intelligence?",
            duration: "08:15",
            audioAsset: "audio/ai_intro.mp3",
            imageAsset: "images/ai_1.png",
            content: [
              SyncedLine(timestamp: const Duration(seconds: 0), text: "Hello everyone. Today we define what AI really is."),
              SyncedLine(timestamp: const Duration(seconds: 5), text: "AI is the simulation of human intelligence by hardware or software systems."),
            ],
          ),
        ],
      ),
      Course(
        id: "react_native",
        title: "Build Mobile Apps with React Native",
        instructor: "Maximilian Schwarzmüller",
        thumbnail: "https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=600&auto=format&fit=crop",
        duration: "32h 10m",
        rating: 4.7,
        description: "Learn how to build beautiful, native mobile apps for iOS and Android using a single codebase and JavaScript.",
        isDownloaded: false,
        lessons: [],
      ),
    ];
  }
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class DownloadService {
  final Dio _dio = Dio();

  // Simulated list of downloaded courses
  static final List<Map<String, dynamic>> downloadedCourses = [];

  // Downloads a simulated curriculum video file to local app storage
  Future<void> downloadCourse({
    required String courseId,
    required String title,
    required String videoUrl,
    required Function(double) onProgress,
    required Function(String) onComplete,
    required Function(String) onError,
  }) async {
    try {
      // 1. Get the local storage directory (Works on Android/iOS/Windows)
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      
      // 2. Create an isolated folder for offline courses
      final String courseDirectoryPath = '${appDocDir.path}/offline_courses';
      final Directory courseDir = Directory(courseDirectoryPath);
      if (!await courseDir.exists()) {
        await courseDir.create(recursive: true);
      }

      // 3. Define the local file path where the video will be saved securely
      final String savePath = '$courseDirectoryPath/$courseId.mp4';

      // 4. Start the file streaming and chunking process using Dio
      await _dio.download(
        videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            onProgress(progress);
          }
        },
      );

      // 5. Register the course to the local 'database' cache so it shows on the Downloads Screen
      downloadedCourses.add({
        "id": courseId,
        "title": title,
        "localPath": savePath,
        "size": "${(File(savePath).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB"
      });

      onComplete(savePath);
    } catch (e) {
      if (kDebugMode) {
        print("Download error: $e");
      }
      onError("Failed to download course for offline view.");
    }
  }

  // Deletes an offline course to free up storage
  Future<void> deleteCourse(String courseId) async {
    try {
      final courseInfo = downloadedCourses.firstWhere((c) => c["id"] == courseId);
      final file = File(courseInfo["localPath"]);
      
      if (await file.exists()) {
        await file.delete();
      }
      
      downloadedCourses.removeWhere((c) => c["id"] == courseId);
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting course: $e");
      }
    }
  }
}

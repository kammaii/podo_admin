import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class CloudStorage {
  static final CloudStorage _instance = CloudStorage.init();

  factory CloudStorage() {
    return _instance;
  }

  final storage = FirebaseStorage.instance;

  CloudStorage.init() {
    print('CloudStorage 초기화');
  }

  Future<String?> getCourseImage({required String courseId}) async {
    String imageUrl = '';
    try {
      final ref = storage.ref().child("LessonCourseImages/$courseId.jpeg");
      imageUrl = await ref.getDownloadURL();
      print('IMAGE DOWNLOADED: $imageUrl');
      return imageUrl;

    } catch (e) {
      print('ERROR: $e');
    }
    return null;
  }

  Future<void> uploadCourseImage({required File image, required String fileName}) async {
      try {
        final ref = storage.ref().child('LessonCourseImages/$fileName');
        ref.putFile((await image.readAsBytes()) as File);
        print('IMAGE UPLOADED');
      } catch (e) {
        print('Storage error: $e');
      }
  }
}
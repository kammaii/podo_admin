import 'package:podo_admin/screens/user/premium.dart';

class User {

  late String id;
  late String email;
  late String name;
  late String language;
  late List<Premium>? premiumRecord;
  late Map<String, dynamic> lessonRecord;
  late Map<String, dynamic> readingRecord;
  String? fcmToken;
  String? fcmState;
  late int status;


  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String LANGUAGE = 'language';
  static const String PREMIUM_RECORD = 'premiumRecord';
  static const String LESSON_RECORD = 'lessonRecord';
  static const String READING_RECORD = 'readingRecord';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';
  static const String STATUS = 'status';

  User.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    email = json[EMAIL];
    name = json[NAME];
    language = json[LANGUAGE];
    premiumRecord = json[PREMIUM_RECORD];
    lessonRecord = json[LESSON_RECORD];
    readingRecord = json[READING_RECORD];
    if(json[FCM_TOKEN] != null) {
      fcmToken = json[FCM_TOKEN];
    }
    if(json[FCM_STATE] != null) {
      fcmState = json[FCM_STATE];
    }
    status = json[STATUS];
    print('HERE: $status');

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      EMAIL: email,
      NAME: name,
      LANGUAGE: language,
      LESSON_RECORD: lessonRecord,
      READING_RECORD: readingRecord,
      STATUS: status,
    };
    if(fcmToken != null) {
      map[FCM_TOKEN] = fcmToken;
    }
    if(fcmState != null) {
      map[FCM_STATE] = fcmState;
    }
    return map;
  }
}
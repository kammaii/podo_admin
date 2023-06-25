import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/user/premium.dart';

class User {

  String id = '';
  String email = '';
  String name = '';
  late DateTime dateSignUp;
  late DateTime dateSignIn;
  String language = '';
  List<Premium>? premiumRecord = [];
  Map<String, dynamic> lessonHistory = {};
  Map<String, dynamic> readingHistory = {};
  Map<String, dynamic> cloudMessageHistory = {};
  String? fcmToken;
  String? fcmState;
  int status = 0;

  User();


  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String DATE_SIGNUP = 'dateSignUp';
  static const String DATE_SIGNIN = 'dateSignIn';
  static const String LANGUAGE = 'language';
  static const String PREMIUM_RECORD = 'premiumRecord';
  static const String LESSON_HISTORY = 'lessonHistory';
  static const String READING_HISTORY = 'readingHistory';
  static const String CLOUD_MESSAGE_HISTORY = 'cloudMessageHistory';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_STATE = 'fcmState';
  static const String STATUS = 'status';

  User.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    email = json[EMAIL];
    name = json[NAME];
    Timestamp stamp = json[DATE_SIGNUP];
    dateSignUp = stamp.toDate();
    stamp = json[DATE_SIGNIN];
    dateSignIn = stamp.toDate();
    language = json[LANGUAGE];
    premiumRecord = json[PREMIUM_RECORD];
    lessonHistory = json[LESSON_HISTORY];
    readingHistory = json[READING_HISTORY];
    cloudMessageHistory = json[CLOUD_MESSAGE_HISTORY];
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
      DATE_SIGNUP: Timestamp.fromDate(dateSignUp),
      DATE_SIGNIN: Timestamp.fromDate(dateSignIn),
      LANGUAGE: language,
      LESSON_HISTORY: lessonHistory,
      READING_HISTORY: readingHistory,
      CLOUD_MESSAGE_HISTORY: cloudMessageHistory,
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
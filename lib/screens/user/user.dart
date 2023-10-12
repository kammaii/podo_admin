import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/user/premium.dart';

class User {

  String id = '';
  String os = '';
  String email = '';
  String name = '';
  late DateTime dateSignUp;
  late DateTime dateSignIn;
  DateTime? trialStart;
  DateTime? trialEnd;
  String language = '';
  String? fcmToken;
  List<String>? fcmTopic;
  bool fcmPermission = false;
  int status = 0;

  User();


  static const String ID = 'id';
  static const String OS = 'os';
  static const String EMAIL = 'email';
  static const String NAME = 'name';
  static const String DATE_SIGNUP = 'dateSignUp';
  static const String DATE_SIGNIN = 'dateSignIn';
  static const String TRIAL_START = 'trialStart';
  static const String TRIAL_END = 'trialEnd';
  static const String LANGUAGE = 'language';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_TOPIC = 'fcmTopic';
  static const String FCM_PERMISSION = 'fcmPermission';
  static const String STATUS = 'status';

  User.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    os = json[OS];
    email = json[EMAIL];
    name = json[NAME];
    Timestamp stamp = json[DATE_SIGNUP];
    dateSignUp = stamp.toDate();
    stamp = json[DATE_SIGNIN];
    dateSignIn = stamp.toDate();
    language = json[LANGUAGE];
    fcmPermission = json[FCM_PERMISSION];
    if(json[FCM_TOKEN] != null) {
      fcmToken = json[FCM_TOKEN];
    }
    if(json[FCM_TOPIC] != null) {
      fcmTopic = json[FCM_TOPIC];
    }
    if(json[TRIAL_START] != null) {
      Timestamp stamp = json[TRIAL_START];
      trialStart = stamp.toDate();
    }
    if(json[TRIAL_END] != null) {
      Timestamp stamp = json[TRIAL_END];
      trialEnd = stamp.toDate();
    }
    status = json[STATUS];
  }
}
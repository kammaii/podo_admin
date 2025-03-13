import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';
import 'package:uuid/uuid.dart';

class UserCount {

  late DateTime date;
  late int statusNew;
  late int statusBasic;
  late int statusPremium;
  late int statusTrial;
  late int totalUsers;
  late int activeNew;
  late int activeBasic;
  late int activePremium;
  late int activeTrial;
  late int activeTotal;
  late int signUpUsers;
  late int deletedUsers;
  late int emailSentUsers;


  static const String DATE = 'date';
  static const String STATUS_NEW = 'statusNew';
  static const String STATUS_BASIC = 'statusBasic';
  static const String STATUS_PREMIUM = 'statusPremium';
  static const String STATUS_TRIAL = 'statusTrial';
  static const String TOTAL_USERS = 'totalUsers';
  static const String ACTIVE_NEW = 'activeNew';
  static const String ACTIVE_BASIC = 'activeBasic';
  static const String ACTIVE_PREMIUM = 'activePremium';
  static const String ACTIVE_TRIAL = 'activeTrial';
  static const String ACTIVE_TOTAL = 'activeTotal';
  static const String SIGN_UP_USERS = 'signUpUsers';
  static const String DELETED_USERS = 'deletedUsers';
  static const String EMAIL_SENT_USERS = 'emailSentUsers';

  UserCount.fromJson(Map<String, dynamic> json) {
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    statusNew = json[STATUS_NEW];
    statusBasic = json[STATUS_BASIC];
    statusPremium = json[STATUS_PREMIUM];
    statusTrial = json[STATUS_TRIAL];
    totalUsers = json[TOTAL_USERS];
    activeNew = json[ACTIVE_NEW];
    activeBasic = json[ACTIVE_BASIC];
    activePremium = json[ACTIVE_PREMIUM];
    activeTrial = json[ACTIVE_TRIAL];
    activeTotal = json[ACTIVE_TOTAL];
    signUpUsers = json[SIGN_UP_USERS];
    deletedUsers = json[DELETED_USERS];
    emailSentUsers = json[EMAIL_SENT_USERS];
  }
}
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/user/premium.dart';

class UserInfo {

  // 비가입 유저
  late String language;
  late bool isBeginnerMode;
  late bool isPremium;
  late DateTime dateSignIn;
  late List<String> completeLessons;

  // + 가입 유저
  String? userEmail;
  String? userName;
  String? image;
  String? learningReason;
  DateTime? dateSignUp;
  String? fcmToken;
  String? fcmState;

  // + 구독유저
  DateTime? datePremiumStart;
  DateTime? datePremiumEnd;
  List<Premium>? premiumRecord;


  static const String USEREMAIL = 'userEmail';
  static const String USERNAME = 'userName';
  static const String LANGUAGE = 'language';
  static const String LEARNINGREASON = 'learningReason';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String ISPREMIUM = 'isPremium';
  static const String DATESIGNUP = 'dateSignUp';
  static const String DATESIGNIN = 'dateSignIn';
  static const String DATEPREMIUMSTART = 'datePremiumStart';
  static const String DATEPREMIUMEND = 'datePremiumEnd';
  static const String PREMIUMRECORD = 'premiumRecord';
  static const String COMPLETELESSONS = 'completeLessons';
  static const String FCMTOKEN = 'fcmToken';
  static const String FCMSTATE = 'fcmState';


  UserInfo.fromJson(Map<String, dynamic> json) {
    if(json[DATESIGNUP] != null) {
      userEmail = json[USEREMAIL];
      userName = json[USERNAME];
      learningReason = json[LEARNINGREASON];
      Timestamp signUpStamp = json[DATESIGNUP];
      dateSignUp = signUpStamp.toDate();
      fcmState = json[FCMSTATE];
    }
    language = json[LANGUAGE];
    isBeginnerMode = json[ISBEGINNERMODE];
    isPremium = json[ISPREMIUM];
    Timestamp signInStamp = json[DATESIGNIN];
    dateSignIn = signInStamp.toDate();
    if(json[DATEPREMIUMSTART] != null) {
      Timestamp premiumStartStamp = json[DATEPREMIUMSTART];
      datePremiumStart = premiumStartStamp.toDate();
    }
    if(json[DATEPREMIUMEND] != null) {
      Timestamp premiumEndStamp = json[DATEPREMIUMEND];
      datePremiumEnd = premiumEndStamp.toDate();
    }
    premiumRecord = json[PREMIUMRECORD];
    completeLessons = json[COMPLETELESSONS];
    if(json[FCMTOKEN] != null) {
      fcmToken = json[FCMTOKEN];
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      LANGUAGE: language,
      ISBEGINNERMODE: isBeginnerMode,
      ISPREMIUM: isPremium,
      DATESIGNIN: Timestamp.fromDate(dateSignIn),
      COMPLETELESSONS: completeLessons,
    };
    if(dateSignUp != null) {
      map[USEREMAIL] = userEmail;
      map[USERNAME] = userName;
      map[LEARNINGREASON] = learningReason;
      map[DATESIGNUP] = Timestamp.fromDate(dateSignUp!);
      map[FCMSTATE] = fcmState;
    }
    if(fcmToken != null) {
      map[FCMTOKEN] = fcmToken;
    }
    if(datePremiumStart != null) {
      map[DATEPREMIUMSTART] = Timestamp.fromDate(datePremiumStart!);
    }
    if(datePremiumEnd != null) {
      map[DATEPREMIUMEND] = Timestamp.fromDate(datePremiumEnd!);
    }
    if(premiumRecord != null) {
      map[PREMIUMRECORD] = premiumRecord!;
    }
    return map;
  }
}
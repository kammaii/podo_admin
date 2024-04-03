import 'package:cloud_firestore/cloud_firestore.dart';

class Writing {
  late String id;
  late String questionId;
  late String questionTitle;
  late int questionLevel;
  late String userId;
  late String userName;
  late String userWriting;
  late String correction;
  late DateTime dateWriting;
  DateTime? dateReply;
  late int status;
  String? comments;
  bool isPremiumUser = false; // 교정 화면용

  static const String ID = 'id';
  static const String QUESTIONID = 'questionId';
  static const String QUESTIONTITLE = 'questionTitle';
  static const String QUESTIONLEVEL = 'questionLevel';
  static const String USERID = 'userId';
  static const String USERNAME = 'userName';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String DATEWRITING = 'dateWriting';
  static const String DATEREPLY = 'dateReply';
  static const String STATUS = 'status';
  static const String COMMENTS = 'comments';

  Writing.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    questionId = json[QUESTIONID];
    questionTitle = json[QUESTIONTITLE];
    questionLevel = json[QUESTIONLEVEL];
    userId = json[USERID];
    userName = json[USERNAME] ?? '';

    userWriting = json[USERWRITING];
    correction = json[CORRECTION];
    Timestamp writingStamp = json[DATEWRITING];
    dateWriting = writingStamp.toDate();
    if (json[DATEREPLY] != null) {
      Timestamp replyStamp = json[DATEREPLY];
      dateReply = replyStamp.toDate();
    }
    status = json[STATUS];
    if (json[COMMENTS] != null) {
      comments = json[COMMENTS];
    }
  }
}

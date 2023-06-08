import 'package:cloud_firestore/cloud_firestore.dart';

class Writing {
  late String id;
  late String questionId;
  late String questionTitle;
  late String userEmail;
  late String userWriting;
  late String correction;
  late DateTime dateWriting;
  DateTime? dateReply;
  late int status;

  static const String ID = 'id';
  static const String QUESTIONID = 'questionId';
  static const String QUESTIONTITLE = 'questionTitle';
  static const String USEREMAIL = 'userEmail';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String DATEWRITING = 'dateWriting';
  static const String DATEREPLY = 'dateReply';
  static const String STATUS = 'status';

  Writing.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    questionId = json[QUESTIONID];
    questionTitle = json[QUESTIONTITLE];
    userEmail = json[USEREMAIL];
    userWriting = json[USERWRITING];
    correction = json[CORRECTION];
    Timestamp writingStamp = json[DATEWRITING];
    dateWriting = writingStamp.toDate();
    if (json[DATEREPLY] != null) {
      Timestamp replyStamp = json[DATEREPLY];
      dateReply = replyStamp.toDate();
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      QUESTIONID: questionId,
      QUESTIONTITLE: questionTitle,
      USEREMAIL: userEmail,
      USERWRITING: userWriting,
      CORRECTION: correction,
      DATEWRITING: Timestamp.fromDate(dateWriting),
      STATUS: status,
    };
    if(dateReply != null) {
      map[DATEREPLY] = Timestamp.fromDate(dateReply!);
    }
    return map;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Writing {
  late String writingId;
  late String writingTitle;
  late String userEmail;
  late String userWriting;
  String? correction;
  late DateTime dateWriting;
  DateTime? dateReply;
  late int status;

  static const String WRITINGID = 'writingId';
  static const String WRITINGTITLE = 'writingTitle';
  static const String USEREMAIL = 'userEmail';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String DATEWRITING = 'dateWriting';
  static const String DATEREPLY = 'dateReply';
  static const String STATUS = 'status';

  Writing.fromJson(Map<String, dynamic> json) {
    writingId = json[WRITINGID];
    writingTitle = json[WRITINGTITLE];
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
      WRITINGID: writingId,
      WRITINGTITLE: writingTitle,
      USEREMAIL: userEmail,
      USERWRITING: userWriting,
      DATEWRITING: Timestamp.fromDate(dateWriting),
      STATUS: status,
    };
    if(correction!= null) {
      map[CORRECTION] = correction;
    }
    if(dateReply != null) {
      map[DATEREPLY] = Timestamp.fromDate(dateReply!);
    }
    return map;
  }
}

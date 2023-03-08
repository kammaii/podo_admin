import 'package:cloud_firestore/cloud_firestore.dart';

class Writing {
  late String writingId;
  late String writingTitle;
  late String userEmail;
  late String userWriting;
  String? correction;
  late DateTime writingDate;
  DateTime? replyDate;
  late int status;

  static const String WRITINGID = 'writingId';
  static const String WRITINGTITLE = 'writingTitle';
  static const String USEREMAIL = 'userEmail';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String WRITINGDATE = 'writingDate';
  static const String REPLYDATE = 'replyDate';
  static const String STATUS = 'status';

  Writing.fromJson(Map<String, dynamic> json) {
    writingId = json[WRITINGID];
    writingTitle = json[WRITINGTITLE];
    userEmail = json[USEREMAIL];
    userWriting = json[USERWRITING];
    correction = json[CORRECTION];
    Timestamp writingStamp = json[WRITINGDATE];
    writingDate = writingStamp.toDate();
    if (json[REPLYDATE] != null) {
      Timestamp replyStamp = json[REPLYDATE];
      replyDate = replyStamp.toDate();
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      WRITINGID: writingId,
      WRITINGTITLE: writingTitle,
      USEREMAIL: userEmail,
      USERWRITING: userWriting,
      WRITINGDATE: Timestamp.fromDate(writingDate),
      STATUS: status,
    };
    if(correction!= null) {
      map[CORRECTION] = correction;
    }
    if(replyDate != null) {
      map[REPLYDATE] = Timestamp.fromDate(replyDate!);
    }
    return map;
  }
}

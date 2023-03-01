import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class Writing {
  late String writingId;
  late String writingTitle;
  late String userEmail;
  late String userWriting;
  late String? correction;
  late DateTime writingDate;
  late DateTime? correctionDate;
  late int status;

  Writing();

  void setCorrection(String correction) {
    correction = correction;
    correctionDate = DateTime.now();
    status = 1;
  }

  List<Writing> getSampleWritings() {
    Map<String, dynamic> sampleJson1 = {
      WRITINGID: '0000-0000-0000',
      WRITINGTITLE: 'writingTitle1',
      USEREMAIL: 'sample1@gmail.com',
      USERWRITING: '안냥하세여',
      WRITINGDATE: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson2 = {
      WRITINGID: '1111-1111-1111',
      WRITINGTITLE: 'writingTitle2',
      USEREMAIL: 'sample2@gmail.com',
      USERWRITING: '질문~~~~',
      WRITINGDATE: Timestamp.now(),
      STATUS: 0,
    };
    return [Writing.fromJson(sampleJson1), Writing.fromJson(sampleJson2)];
  }

  static const String WRITINGID = 'writingId';
  static const String WRITINGTITLE = 'writingTitle';
  static const String USEREMAIL = 'userEmail';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String WRITINGDATE = 'writingDate';
  static const String CORRECTIONDATE = 'correctionDate';
  static const String STATUS = 'status';

  Writing.fromJson(Map<String, dynamic> json) {
    writingId = json[WRITINGID];
    writingTitle = json[WRITINGTITLE];
    userEmail = json[USEREMAIL];
    userWriting = json[USERWRITING];
    correction = json[CORRECTION];
    Timestamp writingStamp = json[WRITINGDATE];
    writingDate = writingStamp.toDate();
    if (json[CORRECTIONDATE] != null) {
      Timestamp replyStamp = json[CORRECTIONDATE];
      correctionDate = replyStamp.toDate();
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() => {
        WRITINGID: writingId,
        WRITINGTITLE: writingTitle,
        USEREMAIL: userEmail,
        USERWRITING: userWriting,
        CORRECTION: correction!,
        WRITINGDATE: Timestamp.fromDate(writingDate),
        CORRECTIONDATE: Timestamp.fromDate(correctionDate!),
        STATUS: status,
      };
}

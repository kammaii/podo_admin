import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:uuid/uuid.dart';

class Notice {
  late String noticeId;
  late String tag;
  late String title;
  late String contents;
  late bool isActive;
  DateTime? deadLine;

  Notice() {
    noticeId = const Uuid().v4();
    tag = MyStrings.tagInfo;
    title = '';
    contents = '';
    isActive = false;
  }

  static const String NOTICEID = 'noticeId';
  static const String TAG = 'tag';
  static const String TITLE = 'title';
  static const String CONTENTS = 'contents';
  static const String ISACTIVE = 'isActive';
  static const String DEADLINE = 'deadLine';


  Notice.fromJson(Map<String, dynamic> json) {
    noticeId = json[NOTICEID];
    tag = json[TAG];
    title = json[TITLE];
    contents = json[CONTENTS];
    isActive = json[ISACTIVE];
    if(json[DEADLINE] != null) {
      Timestamp deadLineStamp = json[DEADLINE];
      deadLine = deadLineStamp?.toDate();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      NOTICEID: noticeId,
      TAG: tag,
      TITLE: title,
      CONTENTS: contents,
      ISACTIVE: isActive,
    };
    if(deadLine != null) {
      map[DEADLINE] = Timestamp.fromDate(deadLine!);
    }
    return map;
  }

  static List<Notice> getSampleNotices() {
    Map<String, dynamic> sampleJson1 = {
      NOTICEID: '0000-0000-0000',
      TAG: MyStrings.tagInfo,
      TITLE: 'Notice',
      CONTENTS: 'New version has been updated',
      ISACTIVE: false,
    };

    Map<String, dynamic> sampleJson2 = {
      NOTICEID: '1111-1111-1111',
      TAG: MyStrings.tagLiveLesson,
      TITLE: 'Free live lesson',
      CONTENTS: '<span style="color:red">Live lesson</span> is coming',
      ISACTIVE: true,
      DEADLINE: Timestamp.now(),
    };
    return [Notice.fromJson(sampleJson1), Notice.fromJson(sampleJson2)];
  }
}
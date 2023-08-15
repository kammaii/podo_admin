import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PodoMessage {
  late String id;
  late Map<String, dynamic> title;
  String? content;
  late DateTime dateSaved;
  DateTime? dateStart;
  DateTime? dateEnd;
  late bool isActive;
  late bool hasBestReply;

  PodoMessage() {
    id = const Uuid().v4();
    title = {};
    isActive = false;
    hasBestReply = false;
  }

  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String CONTENT = 'content';
  static const String DATESAVED = 'dateSaved';
  static const String DATESTART = 'dateStart';
  static const String DATEEND = 'dateEnd';
  static const String ISACTIVE = 'isActive';
  static const String HASREPLY = 'hasBestReply';


  PodoMessage.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    title = json[TITLE];
    Timestamp stamp = json[DATESAVED];
    dateSaved = stamp.toDate();
    if(json[CONTENT] != null) {
    content = json[CONTENT];
    }
    if(json[DATESTART] != null) {
      Timestamp stamp = json[DATESTART];
      dateStart = stamp.toDate();
    }
    if(json[DATEEND] != null) {
      Timestamp stamp = json[DATEEND];
      dateEnd = stamp.toDate();
    }
    isActive = json[ISACTIVE];
    hasBestReply = json[HASREPLY];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      TITLE: title,
      DATESAVED: dateSaved,
      CONTENT: content,
      ISACTIVE: isActive,
      HASREPLY: hasBestReply,
    };
    if(dateStart != null) {
      map[DATESTART] = Timestamp.fromDate(dateStart!);
    }
    if(dateEnd != null) {
      map[DATEEND] = Timestamp.fromDate(dateEnd!);
    }
    return map;
  }
}
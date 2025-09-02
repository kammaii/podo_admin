import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';
import 'package:uuid/uuid.dart';

class KoreanBite {

  late String id;
  late int orderId;
  late Map<String, dynamic> title;
  late List<dynamic> tags;
  late DateTime date;
  late Map<String, dynamic> explain;
  bool isReleased = false;
  late int like;

  bool? hasAudio;

  KoreanBite(int index) {
    id = const Uuid().v4();
    orderId = index;
    title = {};
    tags = [];
    explain = {};
    date = DateTime.now();
  }

  static const String ID = 'id';
  static const String ORDER_ID = 'orderId';
  static const String TITLE = 'title';
  static const String CATEGORY = 'category';
  static const String TAGS = 'tags';
  static const String DATE = 'date';
  static const String EXPLAIN = 'explain';
  static const String IS_RELEASED = 'isReleased';
  static const String LIKE = 'like';
  static const String HAS_AUDIO = 'hasAudio';

  KoreanBite.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDER_ID];
    title = json[TITLE];
    if(json[TAGS] != null) {
      tags =json[TAGS];
    }
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    explain = json[EXPLAIN];
    isReleased = json[IS_RELEASED];
    like = json[LIKE] ?? 0;
    if(json[HAS_AUDIO] != null) {
      hasAudio = json[HAS_AUDIO];
    }
  }

  Map<String, dynamic> toJson() => {
    ID: id,
    ORDER_ID: orderId,
    TITLE: title,
    TAGS: tags,
    DATE: Timestamp.fromDate(date),
    EXPLAIN: explain,
    IS_RELEASED: isReleased,
    HAS_AUDIO: hasAudio,
  };
}
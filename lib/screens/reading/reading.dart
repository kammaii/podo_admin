import 'package:cloud_firestore/cloud_firestore.dart';

class Reading {
  late String id;
  late int orderId;
  late Map<String, String> title;
  late int level;
  late String category;
  String? tag;
  late String image;
  late Map<String, String> content;
  late Map<String, List<String>> words;
  late List<Map<String, String>> quizzes;
  late int likeCount;
  late bool isReleased;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
  static const String IMAGE = 'image';
  static const String CONTENT = 'content';
  static const String WORDS = 'words';
  static const String QUIZZES = 'quizzes';
  static const String LIKECOUNT = 'likeCount';
  static const String ISRELEASED = 'isReleased';

  Reading.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG] ?? null;
    image = json[IMAGE];
    content = json[CONTENT];
    words = json[WORDS];
    quizzes = json[QUIZZES];
    likeCount = json[LIKECOUNT];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      TITLE: title,
      LEVEL: level,
      CATEGORY: category,
      IMAGE: image,
      CONTENT: content,
      WORDS: words,
      QUIZZES: quizzes,
      LIKECOUNT: likeCount,
      ISRELEASED: isReleased,
    };
    map[TAG] = tag ?? null;
    return map;
  }
}

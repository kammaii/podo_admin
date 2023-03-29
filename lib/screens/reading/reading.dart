import 'dart:convert';
import 'package:get/get.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:uuid/uuid.dart';

class Reading {
  late String id;
  late int orderId;
  late Map<String, dynamic> title;
  late int level;
  late String category;
  String? tag;
  late Map<String, dynamic> content;
  late Map<String, dynamic> words;
  late Map<int, dynamic> quizzes;
  late int likeCount;
  late bool isReleased;

  Reading() {
    final controller = Get.find<ReadingStateManager>();
    id = const Uuid().v4();
    orderId = controller.readings.length;
    title = {};
    level = 0;
    category = controller.categories[0];
    content = {};
    words = {};
    quizzes = {0: List.generate(5, (index) => '')};
    likeCount = 0;
    isReleased = false;
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
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
    content = json[CONTENT];
    words = json[WORDS];
    quizzes = {};
    Map<String, dynamic> quizzesMap = json[QUIZZES];
    quizzesMap.forEach((key, value) {
      quizzes[int.parse(key)] = value;
    });
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
      CONTENT: content,
      WORDS: words,
      LIKECOUNT: likeCount,
      ISRELEASED: isReleased,
    };
    Map<String, dynamic> quizzesJson = {};
    quizzes.forEach((key, value) {
      quizzesJson[key.toString()] = value;
    });
    map[QUIZZES] = quizzesJson;
    map[TAG] = tag ?? null;
    return map;
  }
}

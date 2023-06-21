import 'package:get/get.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:uuid/uuid.dart';

class Reading {
  late String id;
  late int orderId;
  late Map<String, dynamic> title;
  late int level;
  late String category;
  late String tag;
  late Map<String, dynamic> content;
  late Map<String, dynamic> words;
  late bool isReleased;
  late bool isFree;
  late List<dynamic> audios;

  Reading() {
    final controller = Get.find<ReadingStateManager>();
    id = const Uuid().v4();
    orderId = controller.readings.length;
    title = {};
    level = 0;
    category = controller.categories[0];
    tag = '';
    content = {};
    words = {};
    isReleased = false;
    isFree = false;
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
  static const String ISRELEASED = 'isReleased';
  static const String ISFREE = 'isFree';
  static const String AUDIOS = 'audios';

  Reading.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG];
    content = json[CONTENT] ?? {};
    words = json[WORDS];
    isReleased = json[ISRELEASED];
    isFree = json[ISFREE];
    audios = json[AUDIOS];
  }

  Map<String, dynamic> toJson() => {
        ID: id,
        ORDERID: orderId,
        TITLE: title,
        LEVEL: level,
        CATEGORY: category,
        TAG: tag,
        CONTENT: content,
        WORDS: words,
        ISRELEASED: isReleased,
        ISFREE: isFree,
        AUDIOS: audios,
      };
}

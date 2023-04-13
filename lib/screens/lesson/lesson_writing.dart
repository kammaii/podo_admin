import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:uuid/uuid.dart';

class LessonWriting {

  late String id;
  late int orderId;
  late int level;
  late Map<String,dynamic> title;
  late bool isFree;

  LessonWriting() {
    id = const Uuid().v4();
    orderId = Get.find<LessonStateManager>().lessonWritings.length;
    level = 0;
    title = {};
    isFree = true;
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String LEVEL = 'level';
  static const String TITLE = 'title';
  static const String ISFREE = 'isFree';

  LessonWriting.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    level = json[LEVEL];
    title = json[TITLE];
    isFree = json[ISFREE];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      LEVEL: level,
      TITLE: title,
      ISFREE: isFree,
    };
    return map;
  }
}
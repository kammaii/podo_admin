import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:uuid/uuid.dart';

class WritingQuestion {
  late String id;
  late int orderId;
  late int level;
  late Map<String, dynamic> title;

  WritingQuestion() {
    id = const Uuid().v4();
    orderId = Get.find<LessonStateManager>().writingQuestions.length;
    level = 1;
    title = {};
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String LEVEL = 'level';
  static const String TITLE = 'title';

  WritingQuestion.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    level = json[LEVEL];
    title = json[TITLE];
  }

  Map<String, dynamic> toJson() => {
        ID: id,
        ORDERID: orderId,
        LEVEL: level,
        TITLE: title,
      };
}

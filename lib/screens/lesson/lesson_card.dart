import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:uuid/uuid.dart';

class LessonCard {
  late String id;
  late int orderId;
  late String type;
  late Map<String, dynamic> content;
  Map<String, dynamic>? detailTitle;
  Map<String, dynamic>? detailContent;

  LessonCard() {
    id = const Uuid().v4();
    final controller = Get.find<LessonStateManager>();
    int index = controller.cards.length;
    orderId = index;
    type = controller.cardType;
    content = {};
    controller.setEditMode(id: id);
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TYPE = 'type';
  static const String CONTENT = 'content';
  static const String DETAIL_TITLE = 'detailTitle';
  static const String DETAIL_CONTENT = 'detailContent';

  LessonCard.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    type = json[TYPE];
    content = json[CONTENT];
    detailTitle = json[DETAIL_TITLE] ?? null;
    detailContent = json[DETAIL_CONTENT] ?? null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      TYPE: type,
      CONTENT: content,
    };
    if (detailTitle != null) {
      map[DETAIL_TITLE] = detailTitle;
    }
    if (detailContent != null) {
      map[DETAIL_CONTENT] = detailContent;
    }
    return map;
  }
}

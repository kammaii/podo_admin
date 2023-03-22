import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:uuid/uuid.dart';

class LessonSubject {
  late String id;
  late int orderId;
  String? image;
  late Map<String,dynamic> subject;
  late Map<String,dynamic> description;
  late bool isBeginnerMode;
  String? tag;
  late List<dynamic> titles;
  late bool isReleased;

  LessonSubject() {
    id = const Uuid().v4();
    int index = Get.find<LessonStateManager>().lessonSubjects.length;
    orderId = index;
    subject = {};
    description = {};
    titles = [];
    isReleased = false;
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String SUBJECT = 'subject';
  static const String DESCRIPTION = 'description';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String TAG = 'tag';
  static const String TITLES = 'titles';
  static const String ISRELEASED = 'isReleased';

  LessonSubject.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    subject = json[SUBJECT];
    description = json[DESCRIPTION];
    isBeginnerMode = json[ISBEGINNERMODE];
    tag = json[TAG] ?? null;
    titles = json[TITLES];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      SUBJECT: subject,
      DESCRIPTION: description,
      ISBEGINNERMODE: isBeginnerMode,
      TITLES: titles,
      ISRELEASED: isReleased
    };
    map[IMAGE] = image ?? null;
    map[TAG] = tag ?? null;
    return map;
  }
}
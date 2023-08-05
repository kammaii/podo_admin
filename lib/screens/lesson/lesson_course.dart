import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:uuid/uuid.dart';

class LessonCourse {
  late String id;
  late int orderId;
  String? image;
  late Map<String,dynamic> title;
  late Map<String,dynamic> description;
  late bool isBeginnerMode;
  String? tag;
  late List<dynamic> lessons;
  late bool isReleased;

  LessonCourse() {
    id = const Uuid().v4();
    int index = Get.find<LessonStateManager>().lessonCourses.length;
    orderId = index;
    title = {};
    description = {};
    lessons = [];
    isReleased = false;
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String TAG = 'tag';
  static const String LESSONS = 'lessons';
  static const String ISRELEASED = 'isReleased';

  LessonCourse.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image =json[IMAGE] ?? null;
    title = json[TITLE];
    description = json[DESCRIPTION];
    isBeginnerMode = json[ISBEGINNERMODE];
    tag = json[TAG] ?? null;
    lessons = json[LESSONS];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      TITLE: title,
      DESCRIPTION: description,
      ISBEGINNERMODE: isBeginnerMode,
      LESSONS: lessons,
      ISRELEASED: isReleased
    };
    map[TAG] = tag ?? null;
    map[IMAGE] = image ?? null;
    return map;
  }
}
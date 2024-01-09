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
  late bool isTopicMode;
  String? tag;
  late List<dynamic> lessons;
  late bool isReleased;
  late bool hasWorkbook;

  LessonCourse() {
    id = const Uuid().v4();
    int index = Get.find<LessonStateManager>().lessonCourses.length;
    orderId = index;
    title = {};
    description = {};
    lessons = [];
    isReleased = false;
    hasWorkbook = false;
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String ISTOPICMODE = 'isTopicMode';
  static const String TAG = 'tag';
  static const String LESSONS = 'lessons';
  static const String ISRELEASED = 'isReleased';
  static const String HASWORKBOOK = 'hasWorkbook';

  LessonCourse.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image =json[IMAGE] ?? null;
    title = json[TITLE];
    description = json[DESCRIPTION];
    isTopicMode = json[ISTOPICMODE];
    tag = json[TAG] ?? null;
    lessons = json[LESSONS];
    isReleased = json[ISRELEASED];
    hasWorkbook = json[HASWORKBOOK] ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      TITLE: title,
      DESCRIPTION: description,
      ISTOPICMODE: isTopicMode,
      LESSONS: lessons,
      ISRELEASED: isReleased,
      HASWORKBOOK: hasWorkbook
    };
    map[TAG] = tag ?? null;
    map[IMAGE] = image ?? null;
    return map;
  }
}
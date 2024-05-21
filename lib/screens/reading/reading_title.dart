import 'package:get/get.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:uuid/uuid.dart';

class ReadingTitle {
  late String id;
  int? orderId;
  String? image;
  late Map<String, dynamic> title;
  late int level;
  late String category;
  late String tag;
  late bool isReleased;
  late bool isFree;
  Map<String,dynamic>? summary;

  ReadingTitle({bool isLesson = false}) {
    final controller = Get.find<ReadingStateManager>();
    id = const Uuid().v4();
    if(!isLesson) {
      orderId = controller.totalReadingTitleLength;
      category = controller.selectedCategory;
    } else {
      category = 'Lesson';
    }
    isReleased = false;
    isFree = false;
    title = {};
    level = 1;
    tag = '';
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String TITLE = 'title';
  static const String LEVEL = 'level';
  static const String CATEGORY = 'category';
  static const String TAG = 'tag';
  static const String ISRELEASED = 'isReleased';
  static const String ISFREE = 'isFree';
  static const String SUMMARY = 'summary';

  ReadingTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG];
    isReleased = json[ISRELEASED] ?? false;
    isFree = json[ISFREE];
    if(json[SUMMARY] != null) {
      summary = json[SUMMARY];
    }
  }

  Map<String, dynamic> toJson() => {
        ID: id,
        ORDERID: orderId,
        IMAGE: image ?? null,
        TITLE: title,
        LEVEL: level,
        CATEGORY: category,
        TAG: tag,
        ISRELEASED: isReleased,
        ISFREE: isFree,
        SUMMARY: summary ?? null,
      };
}

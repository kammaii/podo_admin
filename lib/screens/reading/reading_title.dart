import 'package:get/get.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:uuid/uuid.dart';

class ReadingTitle {
  late String id;
  late int orderId;
  String? image;
  late Map<String, dynamic> title;
  late int level;
  late String category;
  late String tag;
  late bool isReleased;
  late bool isFree;

  ReadingTitle() {
    final controller = Get.find<ReadingStateManager>();
    id = const Uuid().v4();
    orderId = controller.totalReadingTitleLength;
    title = {};
    level = 1;
    category = controller.selectedCategory;
    tag = '';
    isReleased = false;
    isFree = false;
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

  ReadingTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    title = json[TITLE];
    level = json[LEVEL];
    category = json[CATEGORY];
    tag = json[TAG];
    isReleased = json[ISRELEASED];
    isFree = json[ISFREE];
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
      };
}

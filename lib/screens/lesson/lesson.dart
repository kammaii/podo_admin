import 'package:uuid/uuid.dart';

class Lesson {

  late String id;
  late String type;
  late Map<String,dynamic> title;
  late bool isReleased;
  String? tag;
  late bool hasOptions;

  Lesson() {
    id = const Uuid().v4();
    type = 'Lesson';
    title = {};
    isReleased = false;
    hasOptions = true;
  }

  static const String ID = 'id';
  static const String TYPE = 'type';
  static const String TITLE = 'title';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';
  static const String HAS_OPTIONS = 'hasOptions';

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    type = json[TYPE];
    title = json[TITLE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
    hasOptions = json[HAS_OPTIONS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      TYPE: type,
      TITLE: title,
      ISRELEASED: isReleased,
      HAS_OPTIONS: hasOptions,
    };
    map[TAG] = tag ?? null;
    return map;
  }
}
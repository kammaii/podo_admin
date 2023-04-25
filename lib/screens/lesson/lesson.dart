import 'package:uuid/uuid.dart';

class Lesson {

  late String id;
  late String type;
  late Map<String,dynamic> title;
  late bool isFree;
  late bool isReleased;
  String? tag;

  Lesson() {
    id = const Uuid().v4();
    type = 'Lesson';
    title = {};
    isFree = true;
    isReleased = false;
  }

  static const String ID = 'id';
  static const String TYPE = 'type';
  static const String TITLE = 'title';
  static const String ISFREE = 'isFree';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    type = json[TYPE];
    title = json[TITLE];
    isFree = json[ISFREE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      TYPE: type,
      TITLE: title,
      ISFREE: isFree,
      ISRELEASED: isReleased,
    };
    map[TAG] = tag ?? null;
    return map;
  }
}
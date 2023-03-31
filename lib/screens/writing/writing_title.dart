import 'package:uuid/uuid.dart';

class WritingTitle {
  late String id;
  late int level;
  late Map<String, dynamic> title;
  late bool isFree;

  WritingTitle() {
    id = const Uuid().v4();
    level = 0;
    title = {};
    isFree = false;
  }

  static const String ID = 'id';
  static const String LEVEL = 'level';
  static const String TITLE = 'title';
  static const String ISFREE = 'isFree';

  WritingTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    level = json[LEVEL];
    title = json[TITLE];
    isFree = json[ISFREE];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      LEVEL: level,
      TITLE: title,
      ISFREE: isFree,
    };
    return map;
  }
}
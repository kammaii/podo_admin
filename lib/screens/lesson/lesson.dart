import 'package:uuid/uuid.dart';

class Lesson {

  late String id;
  late String type;
  late Map<String,dynamic> title;
  late bool isReleased;
  String? tag;
  late bool hasOptions;
  late bool isFree;
  bool? isFreeOptions;
  String? speakingId;
  String? readingId;
  bool? isSpeakingReleased;
  bool? isReadingReleased;


  Lesson() {
    id = const Uuid().v4();
    type = 'Lesson';
    title = {};
    isReleased = false;
    hasOptions = true;
    isFree = false;
    isFreeOptions = false;
  }

  static const String ID = 'id';
  static const String TYPE = 'type';
  static const String TITLE = 'title';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';
  static const String HAS_OPTIONS = 'hasOptions';
  static const String IS_FREE = 'isFree';
  static const String IS_FREE_OPTIONS = 'isFreeOptions';
  static const String SPEAKING_ID = 'speakingId';
  static const String READING_ID = 'readingId';
  static const String IS_SPEAKING_RELEASED = 'isSpeakingReleased';
  static const String IS_READING_RELEASED = 'isReadingReleased';


  Lesson.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    type = json[TYPE];
    title = json[TITLE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
    hasOptions = json[HAS_OPTIONS];
    isFree = json[IS_FREE];
    if(json[IS_FREE_OPTIONS] != null) {
      isFreeOptions = json[IS_FREE_OPTIONS];
    }
    if(json[SPEAKING_ID] != null) {
      speakingId = json[SPEAKING_ID];
    }
    if(json[READING_ID] != null) {
      readingId = json[READING_ID];
    }
    isReadingReleased = json[IS_READING_RELEASED] ?? false;
    isSpeakingReleased = json[IS_SPEAKING_RELEASED] ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      TYPE: type,
      TITLE: title,
      ISRELEASED: isReleased,
      HAS_OPTIONS: hasOptions,
      IS_FREE: isFree,
    };
    map[TAG] = tag ?? null;
    map[IS_FREE_OPTIONS] = isFreeOptions ?? null;
    if(speakingId != null) {
      map[SPEAKING_ID] = speakingId;
      map[IS_SPEAKING_RELEASED] = isSpeakingReleased ?? false;
    }
    if(readingId != null) {
      map[READING_ID] = readingId;
      map[IS_READING_RELEASED] = isReadingReleased ?? false;
    }
    return map;
  }
}
class LessonSubject {
  late String subjectId;
  late int orderId;
  String? image;
  String? subject_ko;
  String? subject_en;
  String? content_en;
  late bool isBeginnerMode;
  String? tag;
  late List<String> lessons;
  late bool isReleased;

  static const String SUBJECTID = 'subjectId';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String SUBJECTKO = 'subject_ko';
  static const String SUBJECTEN = 'subject_en';
  static const String CONTENTEN = 'content_en';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String TAG = 'tag';
  static const String LESSONS = 'lessons';
  static const String ISRELEASED = 'isReleased';

  LessonSubject.fromJson(Map<String, dynamic> json) {
    subjectId = json[SUBJECTID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    subject_ko = json[SUBJECTKO] ?? null;
    subject_en = json[SUBJECTEN] ?? null;
    content_en = json[CONTENTEN] ?? null;
    isBeginnerMode = json[ISBEGINNERMODE];
    tag = json[TAG] ?? null;
    lessons = json[LESSONS];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      SUBJECTID: subjectId,
      ORDERID: orderId,
      ISBEGINNERMODE: isBeginnerMode,
      LESSONS: lessons,
      ISRELEASED: isReleased
    };
    map[IMAGE] = image ?? null;
    map[SUBJECTKO] = subject_ko ?? null;
    map[SUBJECTEN] = subject_en ?? null;
    map[CONTENTEN] = content_en ?? null;
    map[TAG] = tag ?? null;
    return map;
  }
}
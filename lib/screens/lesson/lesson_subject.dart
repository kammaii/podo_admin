class LessonSubject {
  late String subjectId;
  late int orderId;
  String? image;
  late String subject_ko;
  late Map<String,String> subject_foreign = {};
  late Map<String,String> content_foreign = {};
  late bool isBeginnerMode;
  String? tag;
  late List<String> lessons;
  late bool isReleased;

  LessonSubject();

  static const String SUBJECTID = 'subjectId';
  static const String ORDERID = 'orderId';
  static const String IMAGE = 'image';
  static const String SUBJECTKO = 'subject_ko';
  static const String SUBJECTFOREIGN = 'subject_foreign';
  static const String CONTENTFOREIGN = 'content_foreign';
  static const String ISBEGINNERMODE = 'isBeginnerMode';
  static const String TAG = 'tag';
  static const String LESSONS = 'lessons';
  static const String ISRELEASED = 'isReleased';

  LessonSubject.fromJson(Map<String, dynamic> json) {
    subjectId = json[SUBJECTID];
    orderId = json[ORDERID];
    image = json[IMAGE] ?? null;
    subject_ko = json[SUBJECTKO];
    subject_foreign = json[SUBJECTFOREIGN];
    content_foreign = json[CONTENTFOREIGN];
    isBeginnerMode = json[ISBEGINNERMODE];
    tag = json[TAG] ?? null;
    lessons = json[LESSONS];
    isReleased = json[ISRELEASED];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      SUBJECTID: subjectId,
      ORDERID: orderId,
      SUBJECTKO: subject_ko,
      SUBJECTFOREIGN: subject_foreign,
      CONTENTFOREIGN: content_foreign,
      ISBEGINNERMODE: isBeginnerMode,
      LESSONS: lessons,
      ISRELEASED: isReleased
    };
    map[IMAGE] = image ?? null;
    map[TAG] = tag ?? null;
    return map;
  }
}
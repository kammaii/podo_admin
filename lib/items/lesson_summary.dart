class LessonSummary {
  String lessonId;
  int orderId;
  String? subjectKr;
  String? subjectEn;
  String? explain;
  List<String>? examples;

  LessonSummary({
    required this.lessonId,
    required this.orderId,
    required this.subjectKr,
    required this.subjectEn,
  });

  static const String LESSONID = 'lessonId';
  static const String ORDERID = 'orderId';
  static const String SUBJECTKR = 'subjectKr';
  static const String SUBJECTEN = 'subjectEn';
  static const String EXPLAIN = 'explain';
  static const String EXAMPLES = 'examples';

  LessonSummary.fromJson(Map<String, dynamic> json) :
        lessonId = json[LESSONID],
        orderId = json[ORDERID],
        subjectKr = json[SUBJECTKR],
        subjectEn = json[SUBJECTEN],
        explain = json[EXPLAIN],
        examples = json[EXAMPLES];

  Map<String, dynamic> toJson() => {
    LESSONID : lessonId,
    ORDERID : orderId,
    SUBJECTKR : subjectKr,
    SUBJECTEN : subjectEn,
    EXPLAIN : explain,
    EXAMPLES : examples,
  };
}

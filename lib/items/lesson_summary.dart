class LessonSummary {
  String lessonId;
  List<LessonSummaryItem> contents;

  LessonSummary({
    required this.lessonId,
    required this.contents,
  });
}

class LessonSummaryItem {
  String subjectKr;
  String subjectEn;
  String explain;
  List<String> examples;

  LessonSummaryItem({
    this.subjectKr = '',
    this.subjectEn = '',
    this.explain = '',
    this.examples = const [],
  });
}

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
  late String explain;
  late List<String> examples;

  LessonSummaryItem({
    this.subjectKr = '',
    this.subjectEn = '',
  }) {
    explain = '';
    examples = [];
  }
}

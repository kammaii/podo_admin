class LessonSummary {
  String lessonId;
  List<LessonSummaryItem>? contents;

  LessonSummary({
    required this.lessonId,
    this.contents,
  });

  void initContents(int length) {
    contents = List<LessonSummaryItem>.generate(length, (index) => LessonSummaryItem());
  }
}

class LessonSummaryItem {
  String? subjectKr;
  String? subjectEn;
  String? explain;
  List<String>? examples;
  List<String>? audios;
}
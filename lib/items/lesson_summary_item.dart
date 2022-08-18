class LessonSummaryItem {
  final String lessonId;
  final List<Map<String, List<String>>> contents; // subject: [kr, en], explain: , example: [], audio: []

  LessonSummaryItem({
    required this.lessonId,
    required this.contents,
  });
}
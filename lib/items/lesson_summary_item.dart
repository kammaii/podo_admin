import 'package:podo_admin/screens/value/my_strings.dart';

class LessonSummaryItem {
  String lessonId;
  List<Map<String, List<String>>>? contents; // subject: [kr, en], explain: [] , examples: [], audios: []

  LessonSummaryItem({
    required this.lessonId,
    this.contents,
  }) {
    contents ??= [];
  }

  void setSubject({required int index, String? kr, String? en}) {
  }
}
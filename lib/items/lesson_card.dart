import 'package:flutter_html/flutter_html.dart';

class LessonCard {
  String lessonId;
  int orderId;
  late String uniqueId;
  String type;
  String? kr;
  String? en;
  String? pronun;
  String? explain;
  String? audio;
  String? question;
  List<String>? examples;
  bool? isFavorite;

  LessonCard({
    required this.lessonId,
    required this.orderId,
    required this.type,
    this.kr,
    this.en,
    this.pronun,
    this.explain,
    this.audio,
    this.question,
    this.examples,
    this.isFavorite,
  }) {
    uniqueId = '${lessonId}_${orderId.toString()}';
  }
}
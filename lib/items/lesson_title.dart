class LessonTitle {

  late final String lessonId;
  late String level;
  late int orderId;
  late String category;
  late String title;
  late bool isVideo;
  late String? videoLink;
  late bool isPublished;

  LessonTitle({
    required this.level,
    required this.orderId,
    required this.category,
    required this.title,
    this.isVideo = false,
    this.videoLink,
    required this.isPublished,
  }) {
    lessonId = '${level}_${orderId.toString()}';
  }
}
class LessonTitle {

  late final String lessonId;
  late String lessonGroup;
  late int orderId;
  late String category;
  late String title;
  late bool isVideo;
  late String? videoLink;
  late bool isPublished;

  LessonTitle({
    required this.lessonGroup,
    required this.orderId,
    required this.category,
    required this.title,
    this.isVideo = false,
    this.videoLink,
    required this.isPublished,
  }) {
    lessonId = '${lessonGroup}_${orderId.toString()}';
  }
}
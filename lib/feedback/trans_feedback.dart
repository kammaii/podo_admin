import 'package:cloud_firestore/cloud_firestore.dart';

class TransFeedback {

  late String id;
  late String userId;
  late String userName;
  late String lessonTitle;
  late String lessonId;
  late String cardId;
  late String language;
  late String feedback;
  late DateTime date;
  late bool isChecked;

  static const String ID = 'id';
  static const String USER_ID = 'userId';
  static const String USER_NAME = 'userName';
  static const String LESSON_TITLE = 'lessonTitle';
  static const String LESSON_ID = 'lessonId';
  static const String CARD_ID = 'cardId';
  static const String LANGUAGE = 'language';
  static const String FEEDBACK = 'feedback';
  static const String DATE = 'date';
  static const String IS_CHECKED = 'isChecked';

  TransFeedback.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    userId = json[USER_ID];
    userName = json[USER_NAME] ?? '';
    lessonTitle = json[LESSON_TITLE];
    lessonId = json[LESSON_ID];
    cardId = json[CARD_ID];
    language = json[LANGUAGE];
    feedback = json[FEEDBACK];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    isChecked = json[IS_CHECKED];
  }
}
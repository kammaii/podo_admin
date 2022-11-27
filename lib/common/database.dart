import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<void> saveLessonCard(LessonCard card) {
    DocumentReference ref = firestore.doc('lessonCard/${card.uniqueId}');
    return ref.set(card.toJson()).then((value) {
      print('${card.uniqueId} is saved.');
    }).catchError((e) => print(e));
  }

  Future<void> saveLessonSummary(LessonSummary summary) {
    String uniqueId = '${summary.lessonId}_${summary.orderId}';
    DocumentReference ref = firestore.doc('lessonSummary/$uniqueId');
    return ref.set(summary.toJson()).then((value) {
      print('$uniqueId is saved.');
    }).catchError((e) => print(e));
  }

}
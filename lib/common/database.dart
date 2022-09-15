import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/items/lesson_card.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  Database.init() {
    print('Database 초기화');
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveLessonCard(LessonCard card) {
    DocumentReference ref = firestore.doc('collection/document');
    return ref.set(card.toJson()).then((value) {
      print('${card.uniqueId} is saved.');
    }).catchError((e) => print(e));
  }

}
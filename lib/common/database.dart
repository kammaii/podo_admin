import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/question/question_state_manager.dart';


class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<List<Question>> getQuestions(int status) async {
    List<Question> questions = [];
    final ref = firestore.collection('Questions');
    final query = ref.where('status', isEqualTo: status);
    await query.get().then((QuerySnapshot snapshot) {
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        Question question = Question.fromJson(documentSnapshot.data() as Map<String, dynamic>);
        questions.add(question);
      }
    }, onError: (e) => print('ERROR : $e'));
    // Get.find<QuestionStateManager>().questions = questions;
    return questions;
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

  Future<void> saveSampleQuestion(Question question) {
    CollectionReference ref = firestore.collection('Questions');
    return ref.add(question.toJson()).then((value) {}).catchError((e) => print(e));
  }
}

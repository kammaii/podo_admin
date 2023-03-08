import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/question/question_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class Database {
  static final Database _instance = Database.init();

  factory Database() {
    return _instance;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Database.init() {
    print('Database 초기화');
  }

  Future<List<dynamic>> getDocumentsFromDb(
      {int? status, required String reference, required String orderBy}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(reference);
    final query;
    if (status != null) {
      query = ref.where('status', isEqualTo: status).orderBy(orderBy, descending: true);
    } else {
      query = ref.orderBy(orderBy, descending: true);
    }
    await query.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  updateCorrection({required String writingId, String? correction, bool isUncorrectable = false}) {
    DocumentReference ref = firestore.collection('Writings').doc(writingId);
    if (isUncorrectable) {
      return ref
          .update({'correction': MyStrings.unCorrectable, 'replyDate': Timestamp.now(), 'status': 3})
          .then((value) => print('Correction updated'))
          .catchError((e) => print('ERROR : $e'));
    } else {
      return ref
          .update({'correction': correction, 'replyDate': Timestamp.now(), 'status': 1})
          .then((value) => print('Correction updated'))
          .catchError((e) => print('ERROR : $e'));
    }
  }

  updateQuestion({required Question question}) {
    DocumentReference ref = firestore.collection('Questions').doc(question.questionId);
    if (question.status != 0) {
      if (question.status == 2) {
        // 미선정
        return ref
            .update({'status': 2, 'answerDate': Timestamp.now()})
            .then((value) => print('Answer updated'))
            .catchError((e) => print('ERROR : $e'));
      } else {
        // 선정, 게시중
        return ref
            .update({
              'question': question.question,
              'answer': (question.answer != null) ? question.answer : null,
              'answerDate': Timestamp.now(),
              'tag': (question.tag != null) ? question.tag : null,
              'status': question.status
            })
            .then((value) => print('Correction updated'))
            .catchError((e) => print('ERROR : $e'));
      }
    }
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

  Future<void> saveSampleDb({required String id, required dynamic sample, required String reference}) {
    DocumentReference ref = firestore.collection(reference).doc(id);
    return ref.set(sample.toJson()).then((value) {}).catchError((e) => print(e));
  }
}
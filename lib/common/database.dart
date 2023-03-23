import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';
import 'package:podo_admin/screens/question/question.dart';
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
      {required String reference,
      dynamic field,
      dynamic equalTo,
      required String orderBy,
      bool descending = true}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(reference);
    final queryRef;
    if (field != null) {
      queryRef = ref.where(field, isEqualTo: equalTo).orderBy(orderBy, descending: descending);
    } else {
      queryRef = ref.orderBy(orderBy, descending: true);
    }
    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getListFieldFromDb(
      {required String reference, required String field, required String arrayContains}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(reference);
    final queryRef;
    queryRef = ref.where(field, arrayContains: arrayContains);
    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quiring');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getDocsFromList({required String collection, required String field, required List<dynamic> list}) async {
    List<dynamic> titles = [];
    final ref = firestore.collection(collection).where(field, whereIn: list);
    await ref.get().then((QuerySnapshot snapshot) {
      print('Get docs from list');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        titles.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    });
    return titles;
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

  Future<void> saveLessonToDb({required String reference, required dynamic lesson}) async {
    DocumentReference ref = firestore.collection(reference).doc(lesson.id);
    return await ref.set(lesson.toJson()).then((value) {
      print('Lesson is Saved');
      Get.snackbar('Lesson is saved', 'id: ${lesson.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> updateLessonToDb(
      {required String reference, required dynamic lesson, required Map<String, dynamic> map}) async {
    DocumentReference ref = firestore.collection(reference).doc(lesson.id);
    return await ref.update(map).then((value) {
      print('Lesson is Updated');
      Get.snackbar('Lesson is Updated', 'id: ${lesson.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> addListTransaction(
      {required String collection, required String docId, required String field, required dynamic addValue}) async {
    firestore.runTransaction((transaction) async {
      final ref = firestore.collection(collection).doc(docId);
      final doc = await transaction.get(ref);
      final newValue = doc.get(field);
      newValue.add(addValue);
      print('Transaction updating');
      transaction.update(ref, {field: newValue});
    }).then((_) {
      print('Transaction completed');
      Get.snackbar('타이틀이 추가되었습니다.', addValue, snackPosition: SnackPosition.BOTTOM);
      Get.find<LessonStateManager>().update();
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> deleteLessonFromDb({required String reference, required dynamic lesson}) async {
    DocumentReference ref = firestore.collection(reference).doc(lesson.id);
    return await ref.delete().then((value) {
      print('Lesson is Deleted');
      Get.snackbar('Lesson is Deleted', 'id: ${lesson.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
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

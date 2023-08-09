import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/feedback/feedback.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:podo_admin/screens/reading/reading_title.dart';
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

  Future<int> getCount({required String collection, String? field, dynamic equalTo}) async {
    int count = 0;
    late final Query<Map<String, dynamic>> ref;
    if (field != null) {
      ref = firestore.collection(collection).where(field, isEqualTo: equalTo);
    } else {
      ref = firestore.collection(collection);
    }
    await ref.count().get().then((snapshot) {
      count = snapshot.count;
    }, onError: (error) => print('Count error: $error'));
    return count;
  }

  Future<List<dynamic>> getDocs(
      {required String collection,
      dynamic field,
      dynamic equalTo,
      required String orderBy,
      bool hasLimit = false,
      bool descending = true}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(collection);
    final queryRef;
    if (field != null) {
      queryRef = ref.where(field, isEqualTo: equalTo).orderBy(orderBy, descending: descending);
    } else {
      queryRef = ref.orderBy(orderBy, descending: descending);
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
      {required String collection, required String field, required String arrayContains}) async {
    List<dynamic> documents = [];
    final ref = firestore.collection(collection);
    final queryRef;
    queryRef = ref.where(field, arrayContains: arrayContains);
    await queryRef.get().then((QuerySnapshot snapshot) {
      print('quering');
      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        documents.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }, onError: (e) => print('ERROR : $e'));
    return documents;
  }

  Future<List<dynamic>> getDocsFromList(
      {required String collection, required String field, required List<dynamic> list}) async {
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

  updateCorrection({required String writingId, String? correction, required int status}) {
    DocumentReference ref = firestore.collection('Writings').doc(writingId);
    String correctionText = '';
    switch (status) {
      case 1:
        correctionText = correction!;
        break;

      case 2:
        correctionText = MyStrings.perfect;
        break;

      case 3:
        correctionText = MyStrings.unCorrectable;
        break;
    }

    return ref
        .update({'correction': correctionText, 'dateReply': Timestamp.now(), 'status': status})
        .then((value) => print('Correction updated'))
        .catchError((e) => print('ERROR : $e'));
  }

  Future<void> setDoc({required String collection, required dynamic doc}) async {
    DocumentReference ref = firestore.collection(collection).doc(doc.id);
    return await ref.set(doc.toJson()).then((value) {
      print('Document is Saved');
      Get.snackbar('Document is saved', 'id: ${doc.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> setEmptyDoc({required String collection, required String docId}) async {
    DocumentReference ref = firestore.collection(collection).doc(docId);
    Map<String, dynamic> emptyMap = {};
    return await ref.set(emptyMap).then((value) {
      print('Document is Saved');
      Get.snackbar('Document is saved', 'id: ${docId}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }


  Future<void> runLessonBatch({required String lessonId, required String collection}) async {
    final batch = firestore.batch();
    final controller = Get.find<LessonStateManager>();
    final types = ['LessonCards', 'LessonSummaries', 'WritingQuestions'];
    final List<List<dynamic>> docs = [controller.cards, controller.lessonSummaries, controller.writingQuestions];
    final snapshotIndex = types.indexOf(collection);

    // 기존에 저장된 ids
    List<String> beforeIds = [];
    for (dynamic snapshot in controller.snapshots[collection]!) {
      beforeIds.add(snapshot.id);
    }

    for (dynamic doc in docs[snapshotIndex]) {
      final ref = firestore.collection('Lessons/$lessonId/$collection').doc(doc.id);
      batch.set(ref, doc.toJson());
      if (beforeIds.contains(doc.id)) {
        beforeIds.remove(doc.id);
      }
    }

    // 삭제된 ids 가 있으면 DB 에서 제거
    if (beforeIds.isNotEmpty) {
      for (final id in beforeIds) {
        final ref = firestore.collection('Lessons/$lessonId/$collection').doc(id);
        batch.delete(ref);
      }
    }

    await batch.commit().then((value) {
      controller.snapshots[collection] = [...docs[snapshotIndex]];
      Get.snackbar('$collection are saved', '', snackPosition: SnackPosition.BOTTOM);
      print('$collection are saved');
    }).catchError((e) {
      print(e);
      Get.snackbar('Error', e, snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> updateField(
      {required String collection, required String docId, required Map<String, dynamic> map}) async {
    DocumentReference ref = firestore.collection(collection).doc(docId);
    return await ref.update(map).then((value) {
      print('Updated');
      Get.snackbar('Updated', 'id: ${docId}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> switchOrderTransaction(
      {required String collection, required String docId1, required String docId2}) async {
    await firestore.runTransaction((transaction) async {
      final ref1 = firestore.collection(collection).doc(docId1);
      final ref2 = firestore.collection(collection).doc(docId2);
      final doc1 = await transaction.get(ref1);
      final doc2 = await transaction.get(ref2);
      final doc1Index = doc1.get('orderId');
      final doc2Index = doc2.get('orderId');
      print('Transaction updating');
      transaction.update(ref1, {'orderId': doc2Index});
      transaction.update(ref2, {'orderId': doc1Index});
    }).then((value) {
      print('Transaction completed');
      Get.snackbar('Transaction completed', '', snackPosition: SnackPosition.BOTTOM);
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> addValueTransaction(
      {required String collection,
      required String docId,
      required String field,
      required dynamic addValue}) async {
    firestore.runTransaction((transaction) async {
      final ref = firestore.collection(collection).doc(docId);
      final doc = await transaction.get(ref);
      final newValue = doc.get(field);
      newValue.add(addValue);
      print('Transaction updating');
      transaction.update(ref, {field: newValue});
    }).then((_) {
      print('Transaction completed');
      Get.snackbar('레슨이 추가되었습니다.', addValue, snackPosition: SnackPosition.BOTTOM);
      Get.find<LessonStateManager>().update();
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> deleteDoc({required String collection, required dynamic doc}) async {
    DocumentReference ref = firestore.collection(collection).doc(doc.id);
    return await ref.delete().then((value) {
      print('${doc.id} is Deleted');
      Get.snackbar('Document is deleted', 'id: ${doc.id}', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }

  Future<void> deleteListAndReorderBatch({required String collection, required String docId, required List<dynamic> list}) async {
    final batch = firestore.batch();
    DocumentReference ref = firestore.collection(collection).doc(docId);
    batch.delete(ref);
    List<dynamic> docs = [...list];
    docs.removeWhere((element) => element.id == docId);
    print('Deleted: $docId');
    for (int i = 0; i < docs.length; i++) {
      ref = firestore.collection(collection).doc(docs[i].id);
      batch.update(ref, {'orderId': docs.length - (i+1)});
      print('Reordered: ${docs[i].orderId}');
    }
    await batch.commit().then((value) {
      print('Batch completed');
      Get.snackbar('Document is deleted', '', snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) => print(e));
  }
}

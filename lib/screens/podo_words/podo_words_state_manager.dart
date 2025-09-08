import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/podo_words/topic.dart';

class PodoWordsStateManager extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: Firebase.app('podoWords'));
  static const int topicsPerPage = 20;
  late Future<void> futureTopics;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> removeTopic(Topic topic) async {
    final wordsRef = _db.collection('Topics/${topic.id}/Words');
    QuerySnapshot snapshot = await wordsRef.get();
    final batch = _db.batch();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    final topicRef = _db.collection('Topics').doc(topic.id);
    batch.delete(topicRef);
    batch.commit().then((_) {
      Get.snackbar('토픽과 단어를 삭제했습니다.', topic.id, snackPosition: SnackPosition.BOTTOM);
    });
  }

  Stream<List<Topic>> getTopicsStream() {
    return _db
        .collection('Topics')
        .orderBy('orderId', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Topic.fromJson(doc.data())).toList());
  }

  Future<void> updateTopic(Topic topic) async {
    final ref = _db.collection('Topics').doc(topic.id);
    return await ref.update(topic.toJson()).then((value) {
      print('Topic 업데이트 완료');
      Get.snackbar('Topic이 업데이트 되었습니다.', topic.id,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }).catchError((e) => print(e));
  }

  Future<void> addTopic(Topic topic) async {
    final ref = _db.collection('Topics').doc(topic.id);
    return await ref.set(topic.toJson()).then((value) {
      print('Topic 저장 완료');
      Get.snackbar('Topic이 저장 되었습니다.', topic.id,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }).catchError((e) => print(e));
  }


  void switchTopicsOrder({required Topic topic1, required Topic topic2}) async {
    await _db.runTransaction((transaction) async {
      final ref1 = _db.collection('Topics').doc(topic1.id);
      final ref2 = _db.collection('Topics').doc(topic2.id);
      transaction.update(ref1, {'orderId': topic2.orderId});
      transaction.update(ref2, {'orderId': topic1.orderId});
    }).then((value) {
      print('Topic 순서 변경 성공');
      Get.snackbar('Topic 순서 변경 성공', '',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }
}

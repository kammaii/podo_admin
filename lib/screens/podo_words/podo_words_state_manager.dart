import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/podo_words/topic.dart';
import 'package:podo_admin/screens/podo_words/word.dart';

class PodoWordsStateManager extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: Firebase.app('podoWords'));
  static const int topicsPerPage = 20;
  late Future<void> futureTopics;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> removeTopicAndReorder(Topic topic) async {

    final topicRef = _db.collection('Topics').doc(topic.id);

    try {
      // 트랜잭션 실행
      await _db.runTransaction((transaction) async {
        // --- 1. 모든 읽기(Read) 작업 ---

        // (읽기 1) 삭제할 Topic 문서를 가져와 orderId 확인
        final topicSnapshot = await transaction.get(topicRef);
        if (!topicSnapshot.exists) {
          throw Exception("삭제하려는 Topic이 존재하지 않습니다!");
        }
        final deletedOrderId = topicSnapshot.data()!['orderId'] as int;

        // (읽기 2) 삭제할 Topic보다 orderId가 큰 모든 Topic 문서 조회
        // (반드시 orderId로 정렬해서 가져와야 순서가 보장됩니다)
        final subsequentTopicsQuery = _db
            .collection('Topics')
            .where('orderId', isGreaterThan: deletedOrderId)
            .orderBy('orderId');

        // 트랜잭션 내에서는 일반 .get()을 사용합니다.
        final subsequentTopicsSnapshot = await subsequentTopicsQuery.get();

        // (읽기 3) 삭제할 Topic 하위의 모든 Word 문서 조회
        final wordsSnapshot = await topicRef.collection('Words').get();


        // --- 2. 모든 쓰기(Write) 작업 ---

        // (쓰기 1 - 하위 문서 삭제) 조회된 모든 Word 문서를 삭제
        for (final doc in wordsSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // (쓰기 2 - 상위 문서 삭제) Topic 문서를 삭제
        transaction.delete(topicRef);

        // (쓰기 3 - 재정렬) 조회된 모든 후순위 Topic의 orderId를 1씩 감소
        for (final doc in subsequentTopicsSnapshot.docs) {
          transaction.update(doc.reference, {'orderId': doc.data()['orderId'] - 1});
        }
      });
      print("Topic(${topic.id}) 및 하위 문서 삭제와 재정렬이 완료되었습니다.");
      Get.snackbar('Topic(${topic.id}) 및 하위 문서 삭제와 재정렬이 완료되었습니다.', '', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print("작업 실패! 데이터가 롤백되었습니다. 오류: $e");
      Get.snackbar('작업 실패! 데이터가 롤백되었습니다. 오류: $e', '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeWordAndReorder(String topicId, Word word) async {
    // 1. 작업할 Word 컬렉션의 참조를 가져옵니다.
    final wordCollectionRef =
    _db.collection('Topics').doc(topicId).collection('Words');

    // 2. 삭제할 특정 Word 문서의 참조를 가져옵니다.
    final wordRef = wordCollectionRef.doc(word.id);

    try {
      // 3. 트랜잭션 실행
      await _db.runTransaction((transaction) async {

        // --- (읽기 1) ---
        // 삭제할 Word 문서를 가져와 orderId 확인
        final wordSnapshot = await transaction.get(wordRef);
        if (!wordSnapshot.exists) {
          throw Exception("삭제하려는 Word가 존재하지 않습니다!");
        }
        final deletedOrderId = wordSnapshot.data()!['orderId'] as int;

        // --- (읽기 2) ---
        // 삭제할 Word보다 orderId가 큰 (같은 Topic 내의) 모든 Word 문서 조회
        final subsequentWordsQuery = wordCollectionRef
            .where('orderId', isGreaterThan: deletedOrderId)
            .orderBy('orderId');

        final subsequentWordsSnapshot = await subsequentWordsQuery.get();

        // --- (쓰기 1: 삭제) ---
        // 대상 Word 문서를 삭제
        transaction.delete(wordRef);

        // --- (쓰기 2: 재정렬) ---
        // 조회된 모든 후순위 Word의 orderId를 1씩 감소
        for (final doc in subsequentWordsSnapshot.docs) {
          transaction.update(doc.reference, {'orderId': doc.data()['orderId'] - 1});
        }
      });
      print("Word(${word.id}) 삭제 및 재정렬이 완료되었습니다.");
      Get.snackbar('Word(${word.id}) 삭제 및 재정렬이 완료되었습니다.', '', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      print("Word 삭제 작업 실패! 데이터가 롤백되었습니다. 오류: $e");
      Get.snackbar('Word 삭제 작업 실패! 데이터가 롤백되었습니다. 오류: $e', '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Stream<List<Topic>> getTopicsStream() {
    return _db
        .collection('Topics')
        .orderBy('orderId', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Topic.fromJson(doc.data())).toList());
  }

  Stream<List<Word>> getWordsStream(String topicId) {
    return _db
        .collection('Topics/$topicId/Words')
        .orderBy('orderId')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Word.fromJson(doc.data())).toList());
  }

  Future<void> updateTopic(Topic topic) async {
    final ref = _db.collection('Topics').doc(topic.id);
    return await ref.update(topic.toJson()).then((value) {
      print('Topic 업데이트 완료');
      Get.snackbar('Topic이 업데이트 되었습니다.', topic.id,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }).catchError((e) => print(e));
  }

  Future<void> updateWord(String topicId, Word word) async {
    final ref = _db.collection('Topics/$topicId/Words').doc(word.id);
    return await ref.update(word.toJson()).then((value) {
      print('단어 업데이트 완료');
      Get.snackbar('단어가 업데이트 되었습니다.', word.id,
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

  Future<void> addWord(String topicId, Word word) async {
    final ref = _db.collection('Topics/$topicId/Words').doc(word.id);
    return await ref.set(word.toJson(), SetOptions(merge: true)).then((value) {
      print('단어 저장 완료');
      Get.snackbar('단어가 저장 되었습니다.', word.id,
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
  void switchWordsOrder({required String topicId, required Word word1, required Word word2}) async {
    await _db.runTransaction((transaction) async {
      final ref1 = _db.collection('Topics/$topicId/Words').doc(word1.id);
      final ref2 = _db.collection('Topics/$topicId/Words').doc(word2.id);
      transaction.update(ref1, {'orderId': word2.orderId});
      transaction.update(ref2, {'orderId': word1.orderId});
    }).then((value) {
      print('단어 순서 변경 성공');
      Get.snackbar('단어 순서 변경 성공', '',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }).onError((e, stackTrace) {
      Get.snackbar('에러', e.toString(), snackPosition: SnackPosition.BOTTOM);
    });
  }
}

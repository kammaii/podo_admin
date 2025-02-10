import 'package:get/get.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_example.dart';

class KoreanBiteStateManager extends GetxController {
  final tags = [
    'Vocabulary',
    'Expressions',
    'Grammar',
    'Pronunciation',
    'Conversation ',
  ];
  late String selectedCategory;
  late Future<List<dynamic>> futureKoreanBite;
  late Future<List<dynamic>> futureExampleList;
  List<KoreanBite> koreanBites = [];
  bool isTranslating = false;
  Map<String, bool> isEditMode = {}; // 설명 카드 수정 모드
  List<KoreanBiteExample> examples = [];
  List<KoreanBiteExample> fetchedExamples = [];

  @override
  void onInit() {
    super.onInit();
    selectedCategory = 'All';
  }

  fetchExamples(List<dynamic> docs) {
    examples = [];
    fetchedExamples = [];
    for (dynamic doc in docs) {
      examples.add(KoreanBiteExample.fromJson(doc));
    }
    fetchedExamples = List.from(examples);
  }

  void changeTransState(bool b) {
    isTranslating = b;
    update();
  }

  void setEditMode({String? id}) {
    isEditMode.updateAll((key, value) => value = false);
    id != null ? isEditMode[id] = true : null;
  }

  void reorderExampleCardItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final KoreanBiteExample example = examples.removeAt(oldIndex);
    examples.insert(newIndex, example);
    setNewIndex();
  }

  void setNewIndex() {
    for (int i = 0; i < examples.length; i++) {
      examples[i].orderId = i;
    }
  }
}

import 'package:get/get.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {
  late String lessonLevel;
  late bool isVideoChecked;
  late String lessonId;
  late String cardType;
  late List<LessonCard> cardItems;
  late String quizQuestionLang;
  late Map<String, bool> isEditMode;
  late LessonSummary lessonSummary;

  //LessonStateManager({required this.lessonId});
  //todo: 코멘트 해제하기

  @override
  void onInit() {
    super.onInit();
    lessonLevel = MyStrings.hangul;
    isVideoChecked = false;
    lessonId = '';
    cardType = MyStrings.subject;
    cardItems = [];
    quizQuestionLang = MyStrings.korean;
    isEditMode = {};
    lessonId = 'b_01'; //todo: 이 줄 삭제하고 lessonMain 에서  setLessonId로 설정하기
    lessonSummary = LessonSummary(lessonId: lessonId, contents: []);
  }

  void setLessonId(String id) {
    lessonId = id;
  }

  void setEditMode({String? id}) {
    isEditMode.updateAll((key, value) => value = false);
    id != null ? isEditMode[id] = true : '';
  }

  void setNewIndex() {
    int newIndex = 0;
    for (LessonCard card in cardItems) {
      card.changeOrderId(newIndex);
      newIndex++;
    }
    setEditMode();
  }

  void addCardItem() {
    LessonCard card = LessonCard(lessonId: lessonId, orderId: cardItems.length, type: cardType);
    cardItems.add(card);
    setEditMode(id: card.uniqueId);
  }

  void removeCardItem(int index) {
    cardItems.removeAt(index);
    setNewIndex();
  }

  void reorderCardItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final LessonCard card = cardItems.removeAt(oldIndex);
    cardItems.insert(newIndex, card);
    setNewIndex();
  }

  void changeQuizQuestionLang(String? lang) {
    quizQuestionLang = lang!;
    update();
  }

  void changeCardType(String? type) {
    cardType = type!;
    update();
  }

  void changeLessonLevel(String? level) {
    lessonLevel = level!;
    update();
  }

  void setVideoChecked(bool b) {
    isVideoChecked = b;
    update();
  }
}

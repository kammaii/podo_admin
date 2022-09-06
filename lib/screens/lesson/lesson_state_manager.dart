import 'package:get/get.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {

  late String lessonLevel;
  late bool isVideoChecked;
  late String cardType;
  late List<LessonCard> cardItems;
  late String quizQuestionLang;

  @override
  void onInit() {
    super.onInit();
    lessonLevel = MyStrings.hangul;
    isVideoChecked = false;
    cardType = MyStrings.subject;
    cardItems = [];
    quizQuestionLang = MyStrings.korean;
  }

  void setNewIndex() {
    int newIndex = 0;
    for(LessonCard card in cardItems) {
      card.orderId = newIndex;
      newIndex++;
    }
  }

  void addCardItem() {
    LessonCard card = LessonCard(lessonId: 'b_01', orderId: cardItems.length, type: cardType); //todo: lessonId는 lessonMain 에서 가져오기
    cardItems.add(card);
  }

  void removeCardItem(int index) {
    cardItems.removeAt(index);
    setNewIndex();
  }

  void reorderCardItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    } //todo: 이거 무슨 뜻이지?
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
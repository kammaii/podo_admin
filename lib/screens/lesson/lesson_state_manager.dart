import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {
  late String lessonGroup;
  late bool isVideoChecked;
  late String lessonId;
  late String cardType;
  late List<LessonCard> cardItems;
  late String quizQuestionLang;
  late Map<String, bool> isEditMode;
  late List<LessonSummary> lessonSummaries;
  RxString selectedLanguage = '영어'.obs;
  Map<String, String> languageMap = {
    'en': '영어',
    'es': '스페인어',
    'fr': '프랑스어',
    'de': '독일어',
    'pt': '포르투갈어',
    'id': '인도네시아어',
    'ru': '러시아어',
  };
  RxBool isChecked = true.obs;
  RxList<String> levelDropdownList = ['Level1', 'Level2', 'Level3'].obs;

  //LessonStateManager({required this.lessonId});
  //todo: 코멘트 해제하기

  @override
  void onInit() {
    super.onInit();
    lessonGroup = '한글';
    isVideoChecked = false;
    lessonId = '';
    cardType = MyStrings.subject;
    cardItems = [];
    quizQuestionLang = MyStrings.korean;
    isEditMode = {};
    lessonId = 'b_01'; //todo: 이 줄 삭제하고 lessonMain 에서  setLessonId로 설정하기
    lessonSummaries = [];
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

  Function(String? value) changeQuizQuestionLangRadio() {
    return (String? value) {
      quizQuestionLang = value!;
      update();
    };
  }

  Function(String? value) changeCardTypeRadio() {
    return (String? value) {
      cardType = value!;
      update();
    };
  }

  Function(String? value) changeLessonGroupRadio() {
    return (String? value) {
      lessonGroup = value!;
      update();
    };
  }

  void setVideoChecked(bool b) {
    isVideoChecked = b;
    update();
  }
}

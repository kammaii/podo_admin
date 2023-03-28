import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {
  late String lessonGroup;
  late bool isVideoChecked;
  late String lessonId;
  late String cardType;
  late List<dynamic> cards;
  late String quizQuestionLang;
  late Map<String, bool> isEditMode;
  late List<LessonSummary> lessonSummaries;
  String selectedLanguage = 'en';
  bool isFreeLessonChecked = true;
  List<String> levelDropdownList = ['Level1', 'Level2', 'Level3'];
  late Future<List<dynamic>> futureList;
  late List<LessonSubject> lessonSubjects;
  late List<LessonTitle> lessonTitles;
  RxInt getXTrigger = 0.obs;



  //LessonStateManager({required this.lessonId});
  //todo: 코멘트 해제하기

  @override
  void onInit() {
    super.onInit();
    lessonGroup = '한글';
    isVideoChecked = false;
    lessonId = '';
    cardType = MyStrings.subject;
    cards = [];
    quizQuestionLang = MyStrings.korean;
    isEditMode = {};
    lessonId = 'b_01'; //todo: 이 줄 삭제하고 lessonMain 에서  setLessonId로 설정하기
    lessonSummaries = [];
    lessonSubjects = [];
    lessonTitles = [];
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
    for (LessonCard card in cards) {
      card.changeOrderId(newIndex);
      newIndex++;
    }
    setEditMode();
  }

  void addCardItem() {
    LessonCard card = LessonCard();
    card.orderId = cards.length;
    card.type = cardType;
    cards.add(card);
    setEditMode(id: card.id);
  }

  void removeCardItem(int index) {
    cards.removeAt(index);
    setNewIndex();
  }

  void reorderCardItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final LessonCard card = cards.removeAt(oldIndex);
    cards.insert(newIndex, card);
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

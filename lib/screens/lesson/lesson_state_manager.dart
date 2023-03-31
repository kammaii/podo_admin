import 'package:get/get.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {
  late String cardType;
  late List<LessonCard> cards;
  late Map<String, bool> isEditMode;
  late List<LessonSummary> lessonSummaries;
  late String selectedLanguage;
  bool isFreeLessonChecked = true;
  List<String> writingLevel = ['쉬움', '보통', '어려움'];
  late Future<List<dynamic>> futureList;
  late List<LessonSubject> lessonSubjects;
  late List<Lesson> lessons;

  @override
  void onInit() {
    super.onInit();
    cardType = MyStrings.subject;
    cards = [];
    selectedLanguage = Languages().getFos[0];
    isEditMode = {};
    lessonSummaries = [];
    lessonSubjects = [];
    lessons = [];
  }

  void setEditMode({String? id}) {
    isEditMode.updateAll((key, value) => value = false);
    id != null ? isEditMode[id] = true : '';
  }

  void setNewIndex() {
    int newIndex = 0;
    for (LessonCard card in cards) {
      card.orderId = newIndex;
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

  Function(String? value) changeCardTypeRadio() {
    return (String? value) {
      cardType = value!;
      update();
    };
  }
}

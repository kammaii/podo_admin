import 'package:get/get.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/writing/writing_question.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class WorkbookStateManager extends GetxController {
  late String cardType;
  late List<LessonCard> cards;
  late Map<String, bool> isEditMode;
  late List<LessonSummary> lessonSummaries;
  late List<WritingQuestion> writingQuestions;
  late String selectedLanguage;
  List<String> writingLevel = ['쉬움', '보통', '어려움'];
  late Future<List<dynamic>> futureList;
  late List<LessonCourse> lessonCourses;
  late List<Lesson> lessons;
  final LESSON_CARDS = 'LessonCards';
  final LESSON_SUMMARIES = 'LessonSummaries';
  final WRITING_QUESTIONS = 'WritingQuestions';
  late Map<String, List<dynamic>> snapshots;
  final KO = 'ko';
  final AUDIO = 'audio';
  final PRONUN = 'pronun';
  bool isTranslating = false;

  @override
  void onInit() {
    super.onInit();
    cardType = MyStrings.subject;
    cards = [];
    selectedLanguage = Languages().getFos[0];
    isEditMode = {};
    lessonSummaries = [];
    writingQuestions = [];
    lessonCourses = [];
    lessons = [];
  }


  void setEditMode({String? id}) {
    isEditMode.updateAll((key, value) => value = false);
    id != null ? isEditMode[id] = true : null;
  }

  void setNewIndex() {
    for(int i=0; i<cards.length; i++) {
      cards[i].orderId = i;
    }
    setEditMode();
  }

  void copyRepeat(LessonCard repeat) {
    LessonCard card = LessonCard();
    card.orderId = cards.length;
    card.type = MyStrings.repeat;
    card.content = Map.from(repeat.content);
    card.content[MyStrings.audio] = repeat.id;
    cards.add(card);
    setEditMode(id: card.id);
  }

  void copyMention(LessonCard mention) {
    LessonCard card = LessonCard();
    card.orderId = cards.length;
    card.type = MyStrings.mention;
    card.content = Map.from(mention.content);
    cards.add(card);
    setEditMode(id: card.id);
  }


  void makeQuiz(LessonCard repeat) {
    LessonCard card = LessonCard();
    card.orderId = cards.length;
    card.type = MyStrings.quiz;
    card.content = Map.from(repeat.content);
    if(card.content.containsKey(KO)) {
      card.content.remove(KO);
    }
    if(card.content.containsKey(AUDIO)) {
      card.content.remove(AUDIO);
    }
    if(card.content.containsKey(PRONUN)) {
      card.content.remove(PRONUN);
    }
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

  void changeTransState(bool b) {
    isTranslating = b;
    update();
  }
}

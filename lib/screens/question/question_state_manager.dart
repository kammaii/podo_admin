import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/question/question.dart';

class QuestionStateManager extends GetxController {

  RxString searchRadio = '신규'.obs;
  String statusRadio = '';
  bool isSelectedQuestion = false;
  bool isChecked = true;
  late Future<List<dynamic>> futureQuestions;
  List<Question> questions = [];
  int questionIndex = 0;
  Map<int, String> statusMap = {0: '신규', 1: '선정', 2: '미선정', 3: '게시중'};
  Map<int, Color> statusColor = {
    0: Colors.orange,
    1: Colors.green,
    2: Colors.grey,
    3: Colors.purple
  };
  final List<String> tags = const [
    'grammar',
    'pronunciation',
    'speaking',
    'reading',
    'writing',
    'listening',
    'others',
  ];
  List<bool> selectedTags = [false, false, false, false, false, false, false];


  @override
  void onInit() async {
    futureQuestions = Database().getDocumentsFromDb(reference: 'Questions', query: 'status', equalTo: 0, orderBy: 'dateQuestion');
  }

  void changeQuestionIndex({required isNext}) {
    isNext ? questionIndex++ : questionIndex--;
    if(questionIndex < 0) {
      questionIndex = questions.length - 1;
    } else if(questionIndex >= questions.length) {
      questionIndex = 0;
    }
    update();
  }

  void setQuestionOptions() {
    Question question = questions[questionIndex];
    (question.status == 0) ? statusRadio = '' : statusRadio = statusMap[question.status]!;
    (question.status == 1 || question.status == 3) ? isSelectedQuestion = true : isSelectedQuestion = false;
    initTagToggle();
    if(question.tag != null && tags.contains(question.tag)) {
      selectedTags[tags.indexOf(question.tag!)] = true;
    }
  }

  Function(String? value) changeSearchRadio() {
    return (String? value) {
      searchRadio.value = value!;
      if(value != '전체') {
        int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
        futureQuestions = Database().getDocumentsFromDb(reference: 'Questions', query: 'status', equalTo: key, orderBy: 'dateQuestion');
      } else {
        futureQuestions = Database().getDocumentsFromDb(reference: 'Questions', orderBy: 'dateQuestion');
      }
    };
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
      Question question = questions[questionIndex];
      question.status = key;
      (key == 1 || key == 3) ? isSelectedQuestion = true : isSelectedQuestion = false;
      statusRadio = value!;
      update();
    };
  }

  Function(int? value) changeTagToggle() {
    return (int? idx) {
      Question question = questions[questionIndex];

      if(tags[idx!] == question.tag) {
        initTagToggle();
        question.tag = null;
      } else {
        for (int i = 0; i < selectedTags.length; i++) {
          selectedTags[i] = i == idx;
        }
        question.tag = tags[idx!];
      }
      update();
    };
  }

  void initTagToggle() {
    for(int i=0; i<selectedTags.length; i++) {
      selectedTags[i] = false;
    }
  }

  List<Widget> getTagWidgets() {
    List<Widget> widgets = [];
    for(String tag in tags) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(tag),
      ));
    }
    return widgets;
  }


}




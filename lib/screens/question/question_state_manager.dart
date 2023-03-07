import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/question/question.dart';

class QuestionStateManager extends GetxController {

  RxString searchRadio = '신규'.obs;
  RxString statusRadio = ''.obs;
  RxBool isSelectedQuestion = false.obs;
  RxBool isChecked = true.obs;
  late Future<List<Question>> futureQuestions;
  late List<Question> questions;
  late int questionIndex;
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
  RxList<bool> selectedTags = [false, false, false, false, false, false, false].obs;


  @override
  void onInit() async {
    questionIndex = 0;
    futureQuestions = Database().getQuestions(0);
  }

  void getQuestion({required isNext}) {
    isNext ? questionIndex++ : questionIndex--;

    if(questionIndex < 0) {
      questionIndex = questions.length - 1;
    } else if(questionIndex >= questions.length) {
      questionIndex = 0;
    }
    Question question = questions[questionIndex];
    (question.status == 0) ? statusRadio.value = '' : statusRadio.value = statusMap[question.status]!;
    (question.status == 1 || question.status == 3) ? isSelectedQuestion.value = true : isSelectedQuestion.value = false;
    initTagToggle();
    if(question.tag != null && tags.contains(question.tag)) {
     selectedTags[tags.indexOf(question.tag!)] = true;
    }
    update();
  }

  void saveAnswer() {
    //todo: writingId 로 검색하고 업데이트
    //Writing writing =
    //correction = correction;
    //replyDate = DateTime.now();
    //status = 1;
    // update();
  }

  Function(String? value) changeSearchRadio() {
    return (String? value) {
      searchRadio.value = value!;
      int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
      futureQuestions = Database().getQuestions(key);
    };
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
      Question question = questions[questionIndex];
      question.status = key;
      (key == 1 || key == 3) ? isSelectedQuestion.value = true : isSelectedQuestion.value = false;
      statusRadio.value = value!;
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




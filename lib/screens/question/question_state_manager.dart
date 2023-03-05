import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/question/question.dart';

class QuestionStateManager extends GetxController {

  late String searchRadio;
  late String selectRadio;
  late List<Question> questions;
  late int index;
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
    'listening'
    'others',
  ];
  final List<bool> selectedTags = [false, false, false, false, false, false];


  @override
  void onInit() {
    searchRadio = '신규';
    selectRadio = '미선정';
    index = 0;
    getQuestions();
  }

  void getQuestions() {
    questions = Question().getSampleQuestions();
  }


  void getQuestion() {
    if(index < 0) {
      index = questions.length - 1;
    } else if(index >= questions.length) {
      index = 0;
    }
    Question question = questions[index];
    (question.status == 0) ? selectRadio = '' : selectRadio = statusMap[question.status]!;
    update();
  }

  void setAnswer({required String questionId, required String answer}) {
    //todo: writingId 로 검색하고 업데이트
    //Writing writing =
    //correction = correction;
    //replyDate = DateTime.now();
    //status = 1;
    update();
  }

  Function(String? value) changeSearchRadio() {
    return (String? value) {
      searchRadio = value!;

      update();
    };
  }

  Function(String? value) changeSelectRadio() {
    return (String? value) {
      selectRadio = value!;
      update();
    };
  }

  Function(int? value) changeTagToggle() {
    return (int? index) {
      for (int i = 0; i < selectedTags.length; i++) {
        selectedTags[i] = i == index;
      }
      update();
    };
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




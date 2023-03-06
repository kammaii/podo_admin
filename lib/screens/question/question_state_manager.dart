import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/question/question.dart';

class QuestionStateManager extends GetxController {

  late String searchRadio;
  late String selectRadio;
  late List<Question> questions;
  late Question question;
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
    'listening',
    'others',
  ];
  final List<bool> selectedTags = [false, false, false, false, false, false, false];


  @override
  void onInit() {
    searchRadio = '신규';
    selectRadio = '';
    index = 0;
    getQuestionList();
  }

  void getQuestionList() {
    //todo: DB에서 searchRadio로 검색해서가져오기
    questions = Question().getSampleQuestions();
  }


  void getQuestion() {
    if(index < 0) {
      index = questions.length - 1;
    } else if(index >= questions.length) {
      index = 0;
    }
    question = questions[index];
    (question.status == 0) ? selectRadio = '' : selectRadio = statusMap[question.status]!;
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
      searchRadio = value!;
      update();
    };
  }

  Function(String? value) changeSelectRadio() {
    return (String? value) {
      int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
      questions[index].status = key;
      selectRadio = value!;
      update();
    };
  }

  Function(int? value) changeTagToggle() {
    return (int? idx) {
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




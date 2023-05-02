import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';

class InnerCardTextField {
  final LessonStateManager _controller = Get.find<LessonStateManager>();
  String? cardValue;
  Function(String)? f;
  String? label;

  Widget getKo(int index, String lab) {
    cardValue = _controller.cards[index].content[lab];
    label = lab;
    f = (text) {
      _controller.cards[index].content[lab] = text;
      _controller.update();
    };
    return getTextField();
  }

  Widget getFos(int index, {String lab = ''}) {
    List<Widget> widgets = [];
    for(String language in Languages().getFos) {
      cardValue = _controller.cards[index].content[language];
      label = lab == '' ? language : lab;
      f = (text) {
        _controller.cards[index].content[language] = text;
        _controller.update();
      };
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: getTextField(),
      ));
    }
    return Column(
      children: widgets,
    );
  }

  Widget getAudio(int index, String lab) {
    cardValue = _controller.cards[index].content[lab];
    label = lab;
    f = (text) {
      _controller.cards[index].content[lab] = text;
      _controller.update();
    };
    return getTextField();
  }

  Widget getSummaryKo(int index) {
    cardValue = _controller.lessonSummaries[index].content['ko'];
    label = '타이틀(한국어)';
    f = (text) {
      _controller.lessonSummaries[index].content['ko'] = text;
    };
    return getTextField();
  }

  Widget getSummaryFos(int index) {
    List<Widget> widgets = [];
    for(String language in Languages().getFos) {
      cardValue = _controller.lessonSummaries[index].content[language];
      label = '설명($language)';
      f = (text) {
        _controller.lessonSummaries[index].content[language] = text;
      };
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: getTextField(),
      ));
    }
    return Column(
      children: widgets,
    );
  }

  Widget getSummaryEx({required int summaryIndex, required int exampleIndex}) {
    cardValue = _controller.lessonSummaries[summaryIndex].examples![exampleIndex];
    label = '예문 $exampleIndex';
    f = (text) {
      _controller.lessonSummaries[summaryIndex].examples![exampleIndex] = text;
    };
    return getTextField();
  }



  Widget getTextField() {
    return MyTextField().getTextField(
      controller: TextEditingController(text: cardValue),
      label: label,
      autoFocus: true,
      fn: f,
    );
  }

  Widget getQuizExam(
      {required int index, required String label}) {
    cardValue = _controller.cards[index].content[label];
    return TextField(
      controller: TextEditingController(text: cardValue),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      autofocus: false,
      onChanged: (text) {
        _controller.cards[index].content[label] = text;
      },
      maxLines: null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class InnerCardTextField {
  final LessonStateManager _controller = Get.find<LessonStateManager>();
  String? cardValue;
  Function(String)? f;
  String? label;

  Widget getKr(int index, {String lab = ''}) {
    cardValue = _controller.cardItems[index].kr;
    label = lab == '' ? MyStrings.korean : lab;
    f = (text) {
      _controller.cardItems[index].kr = text;
      _controller.update();
    };
    return getTextField(MyStrings.korean);
  }

  Widget getEn(int index, {String lab = ''}) {
    cardValue = _controller.cardItems[index].en;
    label = lab == '' ? MyStrings.english : lab;
    f = (text) {
      _controller.cardItems[index].en = text;
      _controller.update();
    };
    return getTextField(MyStrings.english);
  }

  Widget getExplain(int index) {
    cardValue = _controller.cardItems[index].explain;
    label = MyStrings.exp;
    f = (text) {
      _controller.cardItems[index].explain = text;
      _controller.update();
    };
    return getTextField(MyStrings.explain);
  }

  Widget getPronun(int index) {
    cardValue = _controller.cardItems[index].pronun;
    label = MyStrings.pronun;
    f = (text) {
      _controller.cardItems[index].pronun = text;
      _controller.update();
    };
    return getTextField(MyStrings.pronun);
  }

  Widget getAudio(int index) {
    cardValue = _controller.cardItems[index].audio;
    label = MyStrings.audio;
    f = (text) {
      _controller.cardItems[index].audio = text;
      _controller.update();
    };
    return getTextField(MyStrings.audio);
  }

  Widget getSummary({required String textValue, required String lab, required Function(String) function}) {
    cardValue = textValue;
    label = lab;
    f = function;
    return getTextField(MyStrings.korean);
  }

  Widget getTextField(String type, {String lab = ''}) {

    TextEditingController controller = TextEditingController(text: cardValue);

    return MyTextField().getTextField(
      controller: controller,
      label: label,
      autoFocus: true,
      onChangedFunction: f,
    );
  }

  Widget getQuizExam(
      {TextEditingController? controller,
      String? label,
      bool autoFocus = false,
      Function(String)? onChangedFunction}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      autofocus: autoFocus,
      onChanged: onChangedFunction,
      maxLines: null,
    );
  }
}

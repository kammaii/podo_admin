import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common_widgets/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class InnerCardTextField {
  final LessonStateManager _controller = Get.find<LessonStateManager>();

  Widget getKr(int index, {String label = ''}) {
    return getTextField(index, MyStrings.korean);
  }

  Widget getEn(int index, {String label = ''}) {
    return getTextField(index, MyStrings.english);
  }

  Widget getExplain(int index, {String label = ''}) {
    return getTextField(index, MyStrings.explain);
  }

  Widget getPronun(int index) {
    return getTextField(index, MyStrings.pronun);
  }

  Widget getAudio(int index) {
    return getTextField(index, MyStrings.audio);
  }

  Widget getTextField(int index, String type, {String lab = ''}) {
    String? cardValue = '';
    String label = lab;
    switch (type) {
      case MyStrings.korean:
        cardValue = _controller.cardItems[index].kr;
        label = label == '' ? MyStrings.korean : label;
        break;

      case MyStrings.english:
        cardValue = _controller.cardItems[index].en;
        label = label == '' ? MyStrings.english : label;
        break;

      case MyStrings.explain:
        cardValue = _controller.cardItems[index].explain;
        label = label == '' ? MyStrings.exp : label;
        break;

      case MyStrings.pronun:
        cardValue = _controller.cardItems[index].pronun;
        label = MyStrings.pronun;
        break;

      case MyStrings.audio:
        cardValue = _controller.cardItems[index].audio;
        label = MyStrings.audio;
        break;
    }

    return MyTextField().getTextField(
      label: label,
      autoFocus: true,
      onChangedFunction: (text) {
        cardValue = text;
      },
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

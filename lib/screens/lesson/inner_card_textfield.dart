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
    String? cardValue;
    Function(String)? f;
    String label = lab;
    switch (type) {
      case MyStrings.korean:
        cardValue = _controller.cardItems[index].kr;
        label = label == '' ? MyStrings.korean : label;
        f = (text) {
          _controller.cardItems[index].kr = text;
          _controller.update();
        };
        break;

      case MyStrings.english:
        cardValue = _controller.cardItems[index].en;
        label = label == '' ? MyStrings.english : label;
        f = (text) {
          _controller.cardItems[index].en = text;
          _controller.update();
        };
        break;

      case MyStrings.explain:
        cardValue = _controller.cardItems[index].explain;
        label = label == '' ? MyStrings.exp : label;
        f = (text) {
          _controller.cardItems[index].explain = text;
          _controller.update();
        };
        break;

      case MyStrings.pronun:
        cardValue = _controller.cardItems[index].pronun;
        label = MyStrings.pronun;
        f = (text) {
          _controller.cardItems[index].pronun = text;
          _controller.update();
        };
        break;

      case MyStrings.audio:
        cardValue = _controller.cardItems[index].audio;
        label = MyStrings.audio;
        f = (text) {
          _controller.cardItems[index].audio = text;
          _controller.update();
        };
        break;
    }

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

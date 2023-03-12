import 'package:flutter/material.dart';

class MyRadioBtn {
  Widget getRadioButton({
    required BuildContext context,
    required String value,
    required String groupValue,
    double width = 150,
    required Function(String? value) f,
  }) {
    return SizedBox(
      width: width,
      child: ListTile(
        title: Text(value),
        leading: Radio(
          value: value,
          activeColor: Theme.of(context).colorScheme.primary,
          groupValue: groupValue,
          onChanged: f,
        ),
      ),
    );
  }
}

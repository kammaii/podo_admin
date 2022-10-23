import 'package:flutter/material.dart';

class MyRadioBtn {
  Widget getRadioButton({
    required BuildContext context,
    required String title,
    required String radio,
    double width = 150,
    required Function(String? value) f,
  }) {
    return SizedBox(
      width: width,
      child: ListTile(
        title: Text(title),
        leading: Radio(
          value: title,
          activeColor: Theme.of(context).colorScheme.primary,
          groupValue: radio,
          onChanged: f,
        ),
      ),
    );
  }
}

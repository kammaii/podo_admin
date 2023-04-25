import 'package:flutter/material.dart';

class MyTextField {
  TextField getTextField({TextEditingController? controller, String? label, bool autoFocus = false, Function(String)? fn, int minLine = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      minLines: minLine,
      autofocus: autoFocus,
      onChanged: fn,
      maxLines: null,
    );
  }
}
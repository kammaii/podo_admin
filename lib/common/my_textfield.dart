import 'package:flutter/material.dart';

class MyTextField {
  TextField getTextField({TextEditingController? controller, String? label, bool autoFocus = false, Function(String)? onChangedFunction}) {
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
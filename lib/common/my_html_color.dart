import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class MyHtmlColor {
  void changeHtmlColor(HtmlEditorController controller, String textColor) async {
    const String KEY = '!SELECTED!';
    String selectedText = await controller.getSelectedTextWeb();
    if (selectedText.isNotEmpty) {
      controller.insertHtml(KEY);
      String wholeText = await controller.getText();
      List<String> splitText = wholeText.split(KEY);
      String newText = '${splitText[0]}<span style="color:$textColor">$selectedText</span>${splitText[1]}';
      controller.setText(newText);
    }
  }

  Widget colorButton({required HtmlEditorController controller, required String color}) {
    return TextButton(
      onPressed: () async {
        changeHtmlColor(controller, color);
      },
      child: Text(color.toUpperCase()),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:podo_admin/common/languages.dart';

class DeeplTranslator {
  Widget getTransBtn(dynamic controller, Map<String, dynamic> map) {
    return TextButton(
      onPressed: () {
        controller.changeTransState(true);
        getTranslations(map).then((value) {
          print('번역완료');
          controller.changeTransState(false);
        }).catchError((e) {
          Get.snackbar('번역 오류 발생', e.toString(), snackPosition: SnackPosition.BOTTOM);
          controller.changeTransState(false);
        });
      },
      child: Row(
        children: [
          const Text('번역'),
          const SizedBox(width: 10),
          controller.isTranslating
              ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 1.5))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Future<void> getTranslations(Map<String, dynamic> map) async {
    String? en = map['en'];
    print(en);
    if (en != null && en.isNotEmpty) {
      final response = await http.post(
        Uri.parse('https://us-central1-podo-49335.cloudfunctions.net/onDeepl'),
        body: en,
      );

      if (response.statusCode == 200) {
        String fos = response.body;
        List<String> translations = jsonDecode(fos).cast<String>();
        int index = 1;
        for (String tr in translations) {
          map[Languages().getFos[index]] = tr;
          index++;
        }
      } else {
        print('오류 발생: ${response.statusCode}');
      }
    }
  }

  Future<void> getWordTranslations(dynamic controller, Map<String, dynamic> map) async {
    List<dynamic> enWords = map['en'];
    if (enWords.isNotEmpty) {
      controller.changeTransState(true);
      for (int i = 0; i < enWords.length; i++) {
        final response = await http.post(
          Uri.parse('https://us-central1-podo-49335.cloudfunctions.net/onDeepl'),
          headers: {
            'Content-Type': 'text/plain',
          },
          body: enWords[i],
        );

        if (response.statusCode == 200) {
          String fos = response.body;
          List<String> translations = jsonDecode(fos).cast<String>();
          for (int j = 0; j < translations.length; j++) {
            String trWord = translations[j];
            map[Languages().getFos[j + 1]][i] = trWord;
          }
        } else {
          Get.snackbar('번역 오류 발생', response.statusCode.toString(), snackPosition: SnackPosition.BOTTOM);
          print('오류 발생: ${response.statusCode}');
          controller.changeTransState(false);
          break;
        }
      }
      controller.changeTransState(false);
    }
  }
}

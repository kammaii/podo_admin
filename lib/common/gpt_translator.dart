import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podo_admin/common/languages.dart';

class GPTTranslator {
  Future<void> getTranslations(Map<String, dynamic> map) async {
    String? en = map['en'];
    print(en);
    if (en != null && en.isNotEmpty) {
      final response = await http.post(
        Uri.parse('https://onchatgpt-7yvptwuwwq-uc.a.run.app'),
        headers: {
          'Content-Type': 'text/plain',
        },
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

  Future<void> getWordTranslations(Map<String, dynamic> map) async {
    List<dynamic> enWords = map['en'];
    if (enWords.isNotEmpty) {
      for(int i=0; i<enWords.length; i++) {
        final response = await http.post(
          Uri.parse('https://onchatgpt-7yvptwuwwq-uc.a.run.app'),
          headers: {
            'Content-Type': 'text/plain',
          },
          body: enWords[i],
        );

        if (response.statusCode == 200) {
          String fos = response.body;
          List<String> translations = jsonDecode(fos).cast<String>();
          for(int j=0; j<translations.length; j++) {
            String trWord = translations[j];
            map[Languages().getFos[j+1]][i] = trWord;
          }
        } else {
          print('오류 발생: ${response.statusCode}');
        }
      }
    }
  }

}

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
}

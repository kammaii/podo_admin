import 'package:podo_admin/screens/writing/writing_title.dart';

class LessonTitle {

  late String titleId;
  late String title_ko;
  late String title_en;
  late String titleGrammar;
  late List<WritingTitle> writingTitles;
  late bool isFree;
  late bool isReleased;
  String? tag;

  static const String TITLEID = 'titleId';
  static const String TITLEKO = 'title_ko';
  static const String TITLEEN = 'title_en';
  static const String TITLEGRAMMAR = 'titleGrammar';
  static const String WRITINGTITLES = 'writingTitles';
  static const String ISFREE = 'isFree';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';

  LessonTitle.fromJson(Map<String, dynamic> json) {
    titleId = json[TITLEID];
    title_ko = json[TITLEKO];
    title_en = json[TITLEEN];
    titleGrammar = json[TITLEGRAMMAR];
    writingTitles = json[WRITINGTITLES];
    isFree = json[ISFREE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      TITLEID: titleId,
      TITLEKO: title_ko,
      TITLEEN: title_en,
      TITLEGRAMMAR: titleGrammar,
      WRITINGTITLES: writingTitles,
      ISFREE: isFree,
      ISRELEASED: isReleased
    };
    map[TAG] = tag ?? null;
    return map;
  }


}
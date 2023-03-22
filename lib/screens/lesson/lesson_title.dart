import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/writing/writing_title.dart';
import 'package:uuid/uuid.dart';

class LessonTitle {

  late String id;
  late Map<String,dynamic> title;
  late String titleGrammar;
  late List<WritingTitle> writingTitles;
  late bool isFree;
  late bool isReleased;
  String? tag;
  DateTime? date;
  late List<dynamic> subjects;

  LessonTitle() {
    id = const Uuid().v4();
    title = {};
    titleGrammar = '';
    writingTitles = [WritingTitle()];
    isFree = true;
    isReleased = false;
    subjects = [];
  }

  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String TITLEGRAMMAR = 'titleGrammar';
  static const String WRITINGTITLES = 'writingTitles';
  static const String ISFREE = 'isFree';
  static const String ISRELEASED = 'isReleased';
  static const String TAG = 'tag';
  static const String DATE = 'date';
  static const String SUBJECTS = 'subjects';

  LessonTitle.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    title = json[TITLE];
    titleGrammar = json[TITLEGRAMMAR];
    writingTitles = [];
    for(dynamic wt in json[WRITINGTITLES]) {
      writingTitles.add(WritingTitle.fromJson(wt));
    }
    isFree = json[ISFREE];
    isReleased = json[ISRELEASED];
    tag = json[TAG] ?? null;
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    subjects = json[SUBJECTS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      TITLE: title,
      TITLEGRAMMAR: titleGrammar,
      ISFREE: isFree,
      ISRELEASED: isReleased,
      DATE: date,
      SUBJECTS: subjects
    };
    List<Map<String,dynamic>> writingTitleJson = [];
    for(WritingTitle title in writingTitles) {
      writingTitleJson.add(title.toJson());
    }
    map[WRITINGTITLES] = writingTitleJson;
    map[TAG] = tag ?? null;
    date == null ? map[DATE] = Timestamp.now() : null;
    return map;
  }


}
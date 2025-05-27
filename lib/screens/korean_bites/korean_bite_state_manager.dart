import 'package:get/get.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_example.dart';

class KoreanBiteStateManager extends GetxController {
  final tags = [
    'DailyUsed',
    'FunExpression',
    'CommonMistake',
    'Slang',
    'GrammarTip',
    'Emotion',
    'Shopping',
    'Travel',
  ];

  final noticeMsgs = [
    '🎉 A New Korean Bite is Here! / Learn "%" and be the first to check it out!',
    '❓ How do you say "%" in your language? / Find the answer in today’s new Korean Bite!',
    '💡 Don’t make this "%" mistake! / Check out this Korean Bite on common Korean slip-ups!',
    '⏳ Don’t miss this! "%" / A popular Korean Bite just dropped!',
    '🚀 If you don’t know "%", you’re a beginner! / Learn the secret tip now!',
    '🏆 This phrase makes you sound like a native! / Discover "%" in the Korean Bite!',
    '😲 Koreans use this phrase every day / Do you know "%"? Learn it now!',
    '🗣️ Want to speak Korean like a native? / Today’s Korean Bite "%" will help!',
    '🎬 "%" What does it really mean? / Learn from K-dramas in Korean Bite!', // 영상 첨부했을 때
    '✈️ Traveling to Korea? / This Korean Bite "%" is a must-learn!',
    '🎯 Learn "%" an easy Korean expression today! / Let’s go!',
    '🔥 Boost your Korean skills now! / Check out "%" in this Korean Bite!'
  ];
  late String selectedTag;
  late String selectedNoticeMsg;
  late Future<List<dynamic>> futureKoreanBite;
  late Future<List<dynamic>> futureExampleList;
  List<KoreanBite> koreanBites = [];
  bool isTranslating = false;
  Map<String, bool> isEditMode = {}; // 설명 카드 수정 모드
  List<KoreanBiteExample> examples = [];
  List<KoreanBiteExample> fetchedExamples = [];

  @override
  void onInit() {
    super.onInit();
    selectedTag = 'All';
    selectedNoticeMsg = noticeMsgs[0];
  }

  fetchExamples(List<dynamic> docs) {
    examples = [];
    fetchedExamples = [];
    for (dynamic doc in docs) {
      examples.add(KoreanBiteExample.fromJson(doc));
    }
    fetchedExamples = List.from(examples);
  }

  void changeTransState(bool b) {
    isTranslating = b;
    update();
  }

  void setEditMode({String? id}) {
    isEditMode.updateAll((key, value) => value = false);
    id != null ? isEditMode[id] = true : null;
  }

  void reorderExampleCardItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final KoreanBiteExample example = examples.removeAt(oldIndex);
    examples.insert(newIndex, example);
    setNewIndex();
  }

  void setNewIndex() {
    for (int i = 0; i < examples.length; i++) {
      examples[i].orderId = i;
    }
  }
}

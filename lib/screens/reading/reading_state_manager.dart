import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/reading/reading_title.dart';

class ReadingStateManager extends GetxController{
  final categories = ['Lesson', 'About Korea', 'Entertainment', 'Daily life', 'Story book', 'all'];
  late Future<List<dynamic>> futureList;
  List<ReadingTitle> readingTitles = [];
  final readingLevel = ['쉬움', '보통', '어려움'];
  late String selectedCategory;
  late int totalReadingTitleLength;
  bool isTranslating = false;

  @override
  void onInit() {
    super.onInit();
    selectedCategory = categories[0];
    getTotalLength();
  }

  void getTotalLength() async {
    totalReadingTitleLength = await Database().getCount(collection: 'ReadingTitles', field: 'category', notEqualTo: 'Lesson');
    print(totalReadingTitleLength);
  }

  void changeTransState(bool b) {
    isTranslating = b;
    update();
  }
}
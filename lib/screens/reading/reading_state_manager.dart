import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/reading/reading_title.dart';

class ReadingStateManager extends GetxController{
  final categories = ['About Korea', 'Entertainment', 'Daily life', 'Story book', 'all'];
  late Future<List<dynamic>> futureList;
  late List<ReadingTitle> readingTitles = [];
  final readingLevel = ['쉬움', '보통', '어려움'];
  late String selectedCategory;
  late int totalReadingTitleLength;


  @override
  void onInit() {
    super.onInit();
    selectedCategory = categories[0];
    getTotalLength();
  }

  void getTotalLength() async {
    totalReadingTitleLength = await Database().getCount(collection: 'ReadingTitles');
    print(totalReadingTitleLength);
  }
}
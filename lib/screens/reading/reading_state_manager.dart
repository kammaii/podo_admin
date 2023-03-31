import 'package:get/get.dart';
import 'package:podo_admin/screens/reading/reading.dart';

class ReadingStateManager extends GetxController{
  final categories = ['culture', 'food', 'travel', 'language', 'k-pop', 'k-drama', 'story book']; //todo: 더 많이 추가하기
  late Future<List<dynamic>> futureList;
  late List<Reading> readings = [];
  final readingLevel = ['쉬움', '보통', '어려움'];
  final languages = ['en','es','fr','de','pt','id','ru'];

}
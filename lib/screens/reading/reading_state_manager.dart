import 'package:flutter/material.dart';
import 'package:podo_admin/screens/reading/reading.dart';

class ReadingStateManager {
  List<String> categories = ['culture', 'food', 'travel', 'language', 'k-pop', 'k-drama']; //todo: 더 많이 추가하기
  late Future<List<dynamic>> futureList;
  late List<Reading> readings;
}
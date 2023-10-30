import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/writing/writing_question.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class UserStateManager extends GetxController {
  int totalCount = 0;
  int newCount = 0;
  int basicCount = 0;
  int trialCount = 0;
  int trialEndCount = 0;
  int premiumCount = 0;
  int newPercent = 0;
  int trialPercent = 0;
  int basicPercent = 0;
  int premiumPercent = 0;
  int totalActive = 0;
  List<FlSpot> trialActivePoints = [];
  List<FlSpot> basicActivePoints = [];
  List<FlSpot> totalActivePoints = [];
  int maxActiveCount = 0;
  late DateTime now;
  bool isRefreshBtnClicked = true;
  List<int> basicActiveList = [];
  List<int> trialActiveList = [];
  List<int> totalActiveList = [];
  int basicActiveCount = 0;
  int trialActiveCount = 0;
  int totalActiveCount = 0;

  @override
  void onInit() {
    super.onInit();
    runInit();
  }

  runInit() {
    now = DateTime.now();
    Future.wait([
      Database().getCount(collection: 'Users', field: 'status', equalTo: 0),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 3),
      FirebaseFirestore.instance
          .collection('Users')
          .where('status', isEqualTo: 3)
          .where('trialEnd', isLessThan: now)
          .count()
          .get()
          .then((value) => value.count),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 1),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 2),
      getActiveUsers(),
    ]).then((snapshot) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        newCount = snapshot[0];
        trialEndCount = snapshot[2];
        trialCount = snapshot[1];
        basicCount = snapshot[3];
        premiumCount = snapshot[4];
        totalCount = newCount + trialCount + basicCount + premiumCount;
        newPercent = (newCount / totalCount * 100).round();
        trialPercent = (trialCount / totalCount * 100).round();
        basicPercent = (basicCount / totalCount * 100).round();
        premiumPercent = (premiumCount / totalCount * 100).round();
        isRefreshBtnClicked = false;
        update();
      });
    });
  }

  Future<int> getActiveUsers() async {
    final collection = FirebaseFirestore.instance.collection('Users');
    basicActiveList = await getCount(collection.where('status', isEqualTo: 1));
    trialActiveList = await getCount(collection.where('status', isEqualTo: 3));
    totalActiveList = [
      basicActiveList[0] + trialActiveList[0],
      basicActiveList[1] + trialActiveList[1],
      basicActiveList[2] + trialActiveList[2],
      basicActiveList[3] + trialActiveList[3],
      basicActiveList[4] + trialActiveList[4],
      basicActiveList[5] + trialActiveList[5],
    ];
    trialActiveCount = trialActiveList.reduce((a, b) => a+b);
    basicActiveCount = basicActiveList.reduce((a, b) => a+b);
    basicActivePoints = getPoints(basicActiveList);
    trialActivePoints = getPoints(trialActiveList);
    totalActivePoints = getPoints(totalActiveList);

    maxActiveCount = totalActiveList[0];
    for (int count in totalActiveList) {
      if (count > maxActiveCount) {
        maxActiveCount = count;
      }
    }
    totalActive = totalActiveList.reduce((a, b) => a + b);
    return 0;
  }

  List<FlSpot> getPoints(List<int> counts) {
    return [
      FlSpot(0, counts[0].toDouble()),
      FlSpot(1, counts[1].toDouble()),
      FlSpot(2, counts[2].toDouble()),
      FlSpot(3, counts[3].toDouble()),
      FlSpot(4, counts[4].toDouble()),
      FlSpot(5, counts[5].toDouble()),
    ];
  }

  Future<List<int>> getCount(Query query) async {
    final today = DateTime(now.year, now.month, now.day);
    final d_1 = today.subtract(const Duration(days: 1));
    final d_2 = today.subtract(const Duration(days: 2));
    final d_3 = today.subtract(const Duration(days: 3));
    final d_4 = today.subtract(const Duration(days: 4));
    final d_5 = today.subtract(const Duration(days: 5));

    final todayCount = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: today)
        .where('dateSignIn', isLessThan: today.add(const Duration(days: 1)))
        .count()
        .get();

    final d_1Count = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: d_1)
        .where('dateSignIn', isLessThan: today)
        .count()
        .get();

    final d_2Count = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: d_2)
        .where('dateSignIn', isLessThan: d_1)
        .count()
        .get();

    final d_3Count = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: d_3)
        .where('dateSignIn', isLessThan: d_2)
        .count()
        .get();

    final d_4Count = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: d_4)
        .where('dateSignIn', isLessThan: d_3)
        .count()
        .get();

    final d_5Count = await query
        .where('dateSignIn', isGreaterThanOrEqualTo: d_5)
        .where('dateSignIn', isLessThan: d_4)
        .count()
        .get();

    return [d_5Count.count, d_4Count.count, d_3Count.count, d_2Count.count, d_1Count.count, todayCount.count];
  }



}

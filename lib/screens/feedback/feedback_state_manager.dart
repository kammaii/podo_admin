import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/feedback/feedback.dart' as fb;

class FeedbackStateManager extends GetxController {

  String searchRadio = '신규';
  String statusRadio = '';
  bool isChecked = true;
  late Future<List<dynamic>> futureFeedbacks;
  List<fb.Feedback> feedbacks = [];
  int feedbackIndex = 0;
  Map<int, String> statusMap = {0: '신규', 1: '검토중', 2: '검토완료'};
  Map<int, Color> statusColor = {
    0: Colors.green,
    1: Colors.yellow,
    2: Colors.purple,
  };


  @override
  void onInit() async {
    futureFeedbacks = Database().getDocs(collection: 'Feedbacks', field: 'status', equalTo: 0, orderBy: 'date');
  }

  void searchUserFeedback(String userEmail) {
    futureFeedbacks = Database().getDocs(collection: 'Feedbacks', field: 'userEmail', equalTo: userEmail, orderBy: 'date');
    update();
  }

  void changeFeedbackIndex({required isNext}) {
    isNext ? feedbackIndex++ : feedbackIndex--;
    if(feedbackIndex < 0) {
      feedbackIndex = feedbacks.length - 1;
    } else if(feedbackIndex >= feedbacks.length) {
      feedbackIndex = 0;
    }
    update();
  }

  void setFeedbackOptions() {
    fb.Feedback feedback = feedbacks[feedbackIndex];
    statusRadio = statusMap[feedback.status]!;
  }

  Function(String? value) changeSearchRadio() {
    return (String? value) {
      searchRadio = value!;
      if(value != '전체') {
        int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
        futureFeedbacks = Database().getDocs(collection: 'Feedbacks', field: 'status', equalTo: key, orderBy: 'date');
      } else {
        futureFeedbacks = Database().getDocs(collection: 'Feedbacks', orderBy: 'date');
      }
    };
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) async {
      int key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
      fb.Feedback feedback = feedbacks[feedbackIndex];
      feedback.status = key;
      statusRadio = value!;
      await Database().updateField(collection: 'Feedbacks', docId: feedback.id, map: {'status': key});
      update();
    };
  }
}





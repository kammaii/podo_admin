import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/feedback/trans_feedback.dart';

class FeedbackStateManager extends GetxController {
  String statusRadio = '신규';
  bool isChecked = false;
  List<TransFeedback> feedbacks = [];
  late Future<List<dynamic>> futureFeedbacks;


  @override
  void onInit() {
    futureFeedbacks = Database().getDocs(collection: 'TransFeedbacks', field: 'isChecked', equalTo: isChecked, orderBy: 'date');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('TransFeedbacks').snapshots().listen((event) {
      futureFeedbacks = Database().getDocs(collection: 'TransFeedbacks', field: 'isChecked', equalTo: isChecked, orderBy: 'date');
      update();
    });
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      statusRadio = value!;
      if(statusRadio == '신규') {
        isChecked = false;
      } else if(statusRadio == '확인') {
        isChecked = true;
      }
      futureFeedbacks = Database().getDocs(collection: 'TransFeedbacks', field: 'isChecked', equalTo: isChecked, orderBy: 'date');
      update();
    };
  }
}

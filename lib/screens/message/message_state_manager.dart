import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/message/message.dart';

class MessageStateManager extends GetxController {

  late String tagRadio;
  late String statusRadio;
  List<Message> messages = Message().getSampleMessages(); //todo: stream 으로 구현하기

  @override
  void onInit() {
    tagRadio = '전체';
    statusRadio = '신규';
  }
}


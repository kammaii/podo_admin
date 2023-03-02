import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {

  late String tagRadio;
  List<Writing> writings = Writing().getSampleWritings(); //todo: stream 으로 구현하기
  Map<int, String> statusMap = {0:'교정중', 1:'교정완료', 2:'요청취소', 3:'교정불가'};
  Map<int, Color> statusColor = {0:Colors.orange, 1:Colors.green, 2:Colors.grey, 3:Colors.red};


  @override
  void onInit() {
    tagRadio = '신규';
  }

  Function(String? value) changeTagRadio() {
    return (String? value) {
      tagRadio = value!;
      update();
    };
  }
}


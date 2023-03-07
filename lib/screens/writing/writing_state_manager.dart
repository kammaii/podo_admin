import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {

  RxString statusRadio = '신규'.obs;
  late int writingIndex;
  late List<Writing> writings;
  Map<int, String> statusMap = {0: '교정중', 1: '교정완료', 2: '요청취소', 3: '교정불가'};
  Map<int, Color> statusColor = {
    0: Colors.orange,
    1: Colors.green,
    2: Colors.grey,
    3: Colors.red
  };

  @override
  void onInit() {
    getWritingList();
    writingIndex = 0;
  }

  void getWritingList() {
    //todo: firebase에서 stream 으로 구독
    writings = Writing().getSampleWritings();
  }

  void getWriting({required isNext}) {
    isNext ? writingIndex++ : writingIndex--;
    if(writingIndex < 0) {
      writingIndex = writings.length - 1;
    } else if(writingIndex >= writings.length) {
      writingIndex = 0;
    }
    update();
  }

  void setCorrection({required String writingId, required String correction}) {
    //todo: writingId 로 검색하고 업데이트
    //Writing writing =
    //correction = correction;
    //replyDate = DateTime.now();
    //status = 1;
    update();
  }

  void setUncorrectable({required String writingId}) {
    //todo: writingId 로 검색하고 업데이트
    //Writing writing =
    //correction = 'I apologize, but I'm unable to make any corrections as I don't understand the meaning.';
    //replyDate = DateTime.now();
    //status = 3;
    update();
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      statusRadio.value = value!;
    };
  }
}




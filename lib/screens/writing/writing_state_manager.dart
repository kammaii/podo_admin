import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {

  late String tagRadio;
  late List<Writing> newWritings;
  late List<Writing> writingsOnTable;
  late Writing writing;
  Map<int, String> statusMap = {0: '교정중', 1: '교정완료', 2: '요청취소', 3: '교정불가'};
  Map<int, Color> statusColor = {
    0: Colors.orange,
    1: Colors.green,
    2: Colors.grey,
    3: Colors.red
  };

  @override
  void onInit() {
    tagRadio = '신규';
    getNewWritings();
    writingsOnTable = List.from(newWritings);
    writing = Writing();
  }

  void getNewWritings() {
    //todo: firebase에서 stream 으로 구독
    newWritings = Writing().getSampleWritings();
    update();
  }

  void changeWriting({required isNext}) {
    int index = newWritings.indexOf(writing);
    isNext ? index++ : index--;
    if(index < 0) {
      index = newWritings.length - 1;
    } else if(index >= newWritings.length) {
      index = 0;
    }
    writing = newWritings[index];
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

  Function(String? value) changeTagRadio() {
    return (String? value) {
      tagRadio = value!;
      update();
    };
  }
}




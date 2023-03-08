import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {
  RxString statusRadio = '신규'.obs;
  int key = 0;
  int writingIndex = 0;
  List<Writing> writings = [];
  late Future<List<dynamic>> futureWritings;
  Map<int, String> statusMap = {0: '신규', 1: '교정완료', 2: '요청취소', 3: '교정불가'};
  Map<int, Color> statusColor = {0: Colors.orange, 1: Colors.green, 2: Colors.grey, 3: Colors.red};

  @override
  void onInit() {
    futureWritings = Database().getDocumentsFromDb(status: key, reference: 'Writings', orderBy: 'writingDate');
  }

  void getWriting({bool? isNext}) {
    if(writings.isNotEmpty) {
      if (isNext != null) {
        isNext ? writingIndex++ : writingIndex--;
      }
      if (writingIndex < 0) {
        writingIndex = writings.length - 1;
      } else if (writingIndex >= writings.length) {
        writingIndex = 0;
      }
      update();
    } else {
      Get.back();
    }
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      statusRadio.value = value!;
      if (value != '전체') {
        key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
        futureWritings =
            Database().getDocumentsFromDb(status: key, reference: 'Writings', orderBy: 'writingDate');
      } else {
        futureWritings = Database().getDocumentsFromDb(reference: 'Writings', orderBy: 'writingDate');
      }
      print('hoi!');
    };
  }
}
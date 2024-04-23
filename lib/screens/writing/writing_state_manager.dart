import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {
  String statusRadio = '신규';
  int key = 0;
  int writingIndex = 0;
  List<Writing> writings = [];
  late Future<List<dynamic>> futureWritings;
  Map<int, String> statusMap = {0: '신규', 1: '교정완료', 2: '교정불필요', 3: '교정불가'};
  Map<int, Color> statusColor = {0: Colors.orange, 1: Colors.green, 2: Colors.yellow, 3: Colors.red, 4: Colors.grey};
  RxBool allCorrection = true.obs;

  @override
  void onInit() {
    futureWritings = Database().getDocs(collection: 'Writings', field: 'status', equalTo: key, orderBy: 'dateWriting');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('Writings').snapshots().listen((event) {
      futureWritings = Database().getDocs(collection: 'Writings', field: 'status', equalTo: key, orderBy: 'dateWriting');
      update();
    });
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
    } else {
      Get.back();
    }
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      statusRadio = value!;
      if (value != '전체') {
        key = statusMap.keys.firstWhere((key) => statusMap[key] == value);
        futureWritings =
            Database().getDocs(collection: 'Writings', field: 'status', equalTo: key, orderBy: 'dateWriting', limit: 10);
        if(key == 0) {
          allCorrection.value = true;
        } else {
          allCorrection.value = false;
        }
      } else {
        futureWritings = Database().getDocs(collection: 'Writings', orderBy: 'dateWriting');
        allCorrection.value = false;
      }
      update();
    };
  }

  void searchUserWriting(String userId) {
    futureWritings =
        Database().getDocs(collection: 'Writings', field: 'userId', equalTo: userId, orderBy: 'dateWriting');
    update();
  }
}

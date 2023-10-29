import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/user/user.dart';
import 'package:podo_admin/screens/user/user_main.dart';

class Research extends StatefulWidget {
  const Research({Key? key}) : super(key: key);

  @override
  State<Research> createState() => _ResearchState();
}

class _ResearchState extends State<Research> {

  late Future<dynamic> future;
  final statusList = ['New', 'Basic', 'Premium', 'Trial'];
  final LESSON_COUNT = 'lessonCount';
  final READING_COUNT = 'readingCount';
  final PODO_MSG_COUNT = 'podoMsgCount';
  final FLASHCARD_COUNT = 'flashcardCount';

  @override
  void initState() {
    super.initState();
    getList(LESSON_COUNT);
  }

  void getList(String count) {
    future = FirebaseFirestore.instance.collection('Users').where('status', isEqualTo: 0).where('fcmPermission', isEqualTo: true).get();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('조사')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == true) {
              List<User> users = [];
              for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.data.docs) {
                User user = User.fromJson(doc.data());
                users.add(user);
              }

              if(users.isEmpty) {
                return const Center(child: Text('검색된 유저가 없습니다.'));
              } else {
                return DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('이메일'), size: ColumnSize.L),
                    DataColumn2(label: Text('가입일'), size: ColumnSize.L),
                    DataColumn2(label: Text('최종로그인'), size: ColumnSize.L),
                    DataColumn2(label: Text('체험시작'), size: ColumnSize.S),
                    DataColumn2(label: Text('체험종료'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨'), size: ColumnSize.S),
                    DataColumn2(label: Text('토큰'), size: ColumnSize.S),
                    DataColumn2(label: Text('플랫폼'), size: ColumnSize.S),
                    DataColumn2(label: Text('상태'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(users.length, (index) {
                    User user = users[index];

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(user.email), onDoubleTap: (){
                        Get.to(UserMain(userEmail: user.email));
                      }, onTap: (){
                        Clipboard.setData(ClipboardData(text: user.email));
                        Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email, snackPosition: SnackPosition.BOTTOM);
                      }),
                      DataCell(Text(MyDateFormat().getDateFormat(user.dateSignUp))),
                      DataCell(Text(MyDateFormat().getDateFormat(user.dateSignIn))),
                      DataCell(Text(user.trialStart != null ? MyDateFormat().getDateFormat(user.trialStart!) : '')),
                      DataCell(Text(user.trialEnd != null ? MyDateFormat().getDateFormat(user.trialEnd!) : '')),
                      DataCell(Text(user.lessonCount.toString())),
                      DataCell(Text(user.fcmToken != null ? user.fcmToken!.substring(0, 8) : '')),
                      DataCell(Text(user.os)),
                      DataCell(Text(statusList[user.status])),
                    ]);
                  }),
                );
              }
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

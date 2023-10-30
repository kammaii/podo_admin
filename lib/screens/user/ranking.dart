import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/user/user.dart';
import 'package:podo_admin/screens/user/user_main.dart';

class Ranking extends StatefulWidget {
  const Ranking({Key? key}) : super(key: key);

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {

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
    future = FirebaseFirestore.instance.collection('Users').orderBy(count, descending: true).limit(10).get();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('랭킹')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<User> users = [];
              for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.data.docs) {
                users.add(User.fromJson(doc.data()));
              }

              if(users.isEmpty) {
                return const Center(child: Text('검색된 유저가 없습니다.'));
              } else {
                return DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('이메일'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨'), size: ColumnSize.S),
                    DataColumn2(label: Text('읽기'), size: ColumnSize.S),
                    DataColumn2(label: Text('포도메시지'), size: ColumnSize.S),
                    DataColumn2(label: Text('플래시카드'), size: ColumnSize.S),
                    DataColumn2(label: Text('상태'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(users.length, (index) {
                    User user = users[index];

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(user.email), onDoubleTap: (){
                        Get.to(UserMain(userEmail: user.email));
                      }),
                      DataCell(Text(user.lessonCount.toString()), onTap: () {
                        setState(() {
                          getList(LESSON_COUNT);
                        });
                      }),
                      DataCell(Text(user.readingCount.toString()), onTap: () {
                        setState(() {
                          getList(READING_COUNT);
                        });
                      }),
                      DataCell(Text(user.podoMsgCount.toString()), onTap: () {
                        setState(() {
                          getList(PODO_MSG_COUNT);
                        });
                      }),
                      DataCell(Text(user.flashcardCount.toString()), onTap: () {
                        setState(() {
                          getList(FLASHCARD_COUNT);
                        });
                      }),
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

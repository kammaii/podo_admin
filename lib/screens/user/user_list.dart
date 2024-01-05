import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/user/user.dart';
import 'package:podo_admin/screens/user/user_main.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String title = Get.arguments['title'];
  Query query = Get.arguments['query'];
  int? userCount = Get.arguments['userCount'];
  int userStatus = Get.arguments['userStatus'];

  final statusList = ['New', 'Basic', 'Premium', 'Trial'];
  late Future<dynamic> future;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void getUsers() {
    future = query.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<User> users = [];
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.data.docs) {
            users.add(User.fromJson(doc.data()));
          }
          String appbarTitle = '$title: $userCount 명';

          if (users.isEmpty) {
            return const Center(child: Text('검색된 유저가 없습니다.'));
          } else {
            return Scaffold(
              appBar: AppBar(title: Text(appbarTitle)),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: userStatus == 1 ? DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('이메일'), size: ColumnSize.M),
                    DataColumn2(label: Text('가입일'), size: ColumnSize.S),
                    DataColumn2(label: Text('최종로그인'), size: ColumnSize.S),
                    DataColumn2(label: Text('Trial종료일'), size: ColumnSize.S),
                    DataColumn2(label: Text('Premium종료'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨'), size: ColumnSize.S),
                    DataColumn2(label: Text('읽기'), size: ColumnSize.S),
                    DataColumn2(label: Text('플래시카드'), size: ColumnSize.S),
                    DataColumn2(label: Text('fcm승인'), size: ColumnSize.S),
                    DataColumn2(label: Text('OS'), size: ColumnSize.S),
                    DataColumn2(label: Text('언어'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(users.length, (index) {
                    User user = users[index];

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(user.email), onDoubleTap: () {
                        Get.to(UserMain(userEmail: user.email));
                      }, onTap: () {
                        Clipboard.setData(ClipboardData(text: user.email));
                        Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email, snackPosition: SnackPosition.BOTTOM);
                      }),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignUp))),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignIn))),
                      DataCell(
                          Text(user.trialEnd != null ? MyDateFormat().getDateOnlyFormat(user.trialEnd!) : '')),
                      DataCell(Text(user.premiumEnd ?? '')),
                      DataCell(Text(user.lessonCount.toString())),
                      DataCell(Text(user.readingCount.toString())),
                      DataCell(Text(user.flashcardCount.toString())),
                      DataCell(Icon(Icons.circle, color: user.fcmPermission ? Colors.green : Colors.red)),
                      DataCell(Text(user.os)),
                      DataCell(Text(user.language)),
                    ]);
                  }),
                ) : userStatus == 2 ? DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('이메일'), size: ColumnSize.M),
                    DataColumn2(label: Text('가입일'), size: ColumnSize.S),
                    DataColumn2(label: Text('최종로그인'), size: ColumnSize.S),
                    DataColumn2(label: Text('Trial종료일'), size: ColumnSize.S),
                    DataColumn2(label: Text('Premium시작'), size: ColumnSize.S),
                    DataColumn2(label: Text('Premium종료'), size: ColumnSize.S),
                    DataColumn2(label: Text('Premium갱신'), size: ColumnSize.S),
                    DataColumn2(label: Text('fcm승인'), size: ColumnSize.S),
                    DataColumn2(label: Text('OS'), size: ColumnSize.S),
                    DataColumn2(label: Text('언어'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(users.length, (index) {
                    User user = users[index];

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(user.email), onDoubleTap: () {
                        Get.to(UserMain(userEmail: user.email));
                      }, onTap: () {
                        Clipboard.setData(ClipboardData(text: user.email));
                        Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email, snackPosition: SnackPosition.BOTTOM);
                      }),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignUp))),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignIn))),
                      DataCell(
                          Text(user.trialEnd != null ? MyDateFormat().getDateOnlyFormat(user.trialEnd!) : '')),
                      DataCell(Text(user.premiumStart ?? '')),
                      DataCell(Text(user.premiumEnd ?? '')),
                      DataCell(user.premiumWillRenew != null
                          ? Icon(Icons.circle, color: user.premiumWillRenew! ? Colors.green : Colors.red)
                          : const Text('')),
                      DataCell(Icon(Icons.circle, color: user.fcmPermission ? Colors.green : Colors.red)),
                      DataCell(Text(user.os)),
                      DataCell(Text(user.language)),
                    ]);
                  }),
                ) : DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('이메일'), size: ColumnSize.M),
                    DataColumn2(label: Text('가입일'), size: ColumnSize.S),
                    DataColumn2(label: Text('최종로그인'), size: ColumnSize.S),
                    DataColumn2(label: Text('Trial종료일'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨'), size: ColumnSize.S),
                    DataColumn2(label: Text('읽기'), size: ColumnSize.S),
                    DataColumn2(label: Text('플래시카드'), size: ColumnSize.S),
                    DataColumn2(label: Text('fcm승인'), size: ColumnSize.S),
                    DataColumn2(label: Text('OS'), size: ColumnSize.S),
                    DataColumn2(label: Text('언어'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(users.length, (index) {
                    User user = users[index];

                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(user.email), onDoubleTap: () {
                        Get.to(UserMain(userEmail: user.email));
                      }, onTap: () {
                        Clipboard.setData(ClipboardData(text: user.email));
                        Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email, snackPosition: SnackPosition.BOTTOM);
                      }),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignUp))),
                      DataCell(Text(MyDateFormat().getDateOnlyFormat(user.dateSignIn))),
                      DataCell(
                          Text(user.trialEnd != null ? MyDateFormat().getDateOnlyFormat(user.trialEnd!) : '')),
                      DataCell(Text(user.lessonCount.toString())),
                      DataCell(Text(user.readingCount.toString())),
                      DataCell(Text(user.flashcardCount.toString())),
                      DataCell(Icon(Icons.circle, color: user.fcmPermission ? Colors.green : Colors.red)),
                      DataCell(Text(user.os)),
                      DataCell(Text(user.language)),
                    ]);
                  }),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

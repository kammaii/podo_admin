import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/user/user.dart' as user_info;
import 'package:podo_admin/screens/user/user_writing_record.dart';

class UserMain extends StatefulWidget {
  UserMain({Key? key}) : super(key: key);

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  final TextEditingController _searchController = TextEditingController();
  final double cardWidth = 500;
  late Future userFuture;
  bool isSearched = false;
  List<String> statusList = ['new', 'basic', 'premium'];
  int? lessonCount;
  int? readingCount;
  int? cloudCount;
  int? flashcardCount;
  String? userId = Get.arguments['userId'];
  String? userEmail = Get.arguments['userEmail'];

  @override
  Widget build(BuildContext context) {
    if (userId != null && !isSearched) {
      userFuture = Database().getDocs(collection: 'Users', field: 'id', equalTo: userId, orderBy: 'status');
      isSearched = true;
    }

    if (userEmail != null && !isSearched) {
      userFuture = Database().getDocs(collection: 'Users', field: 'email', equalTo: userEmail, orderBy: 'status');
      isSearched = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('유저'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: '유저이메일',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final userEmail = _searchController.text;
                    if (userEmail.isNotEmpty) {
                      setState(() {
                        userFuture = Database()
                            .getDocs(collection: 'Users', field: 'email', equalTo: userEmail, orderBy: 'id');
                        isSearched = true;
                      });
                    }
                  },
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            isSearched
                ? FutureBuilder(
                    future: userFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                        if (snapshot.data.length == 0) {
                          return const Center(child: Text('검색된 유저가 없습니다.'));
                        } else {
                          user_info.User user = user_info.User();
                          for (dynamic snapshot in snapshot.data) {
                            user = user_info.User.fromJson(snapshot);
                          }

                          Future.wait([
                            Database().getCount(
                                collection: 'Users/${user.id}/Histories', field: 'item', equalTo: 'lesson'),
                            Database().getCount(
                                collection: 'Users/${user.id}/Histories', field: 'item', equalTo: 'reading'),
                            Database().getCount(
                                collection: 'Users/${user.id}/Histories', field: 'item', equalTo: 'cloudMessage'),
                            Database().getCount(collection: 'Users/${user.id}/FlashCards'),
                          ]).then((snapshot) {
                            setState(() {
                              lessonCount = snapshot[0];
                              readingCount = snapshot[1];
                              cloudCount = snapshot[2];
                              flashcardCount = snapshot[3];
                            });
                          });
                          return Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: SizedBox(
                                          width: cardWidth,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(user.name, textScaleFactor: 2),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        color: Theme.of(context).colorScheme.primaryContainer),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                                      child: Text(
                                                        statusList[user.status],
                                                        style: TextStyle(
                                                            color:
                                                                Theme.of(context).colorScheme.onPrimaryContainer),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              getInfoRow('아이디', user.id),
                                              const SizedBox(height: 10),
                                              getInfoRow('이메일', user.email),
                                              const SizedBox(height: 10),
                                              getInfoRow('이름', user.name),
                                              const SizedBox(height: 10),
                                              getInfoRow('가입일', MyDateFormat().getDateOnlyFormat(user.dateSignUp)),
                                              const SizedBox(height: 10),
                                              getInfoRow(
                                                  '최종로그인', MyDateFormat().getDateOnlyFormat(user.dateSignIn)),
                                              const Divider(height: 50),
                                              getInfoRow('언어', user.language),
                                              const SizedBox(height: 10),
                                              getInfoRow('OS', user.os),
                                              const SizedBox(height: 10),
                                              getInfoRow('메시지수신', user.fcmState ?? 'null'),
                                              const Divider(height: 50),
                                              getInfoRow('레슨완료', '${lessonCount.toString()} 개'),
                                              const SizedBox(height: 10),
                                              getInfoRow('읽기완료', '${readingCount.toString()} 개'),
                                              const SizedBox(height: 10),
                                              getInfoRow('클라우드메시지', '${cloudCount.toString()} 개'),
                                              const SizedBox(height: 10),
                                              getInfoRow('플레시카드', '${flashcardCount.toString()} 개'),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Get.to(UserWritingRecord(), arguments: user.id);
                                            },
                                            child: const Text('교정내역 보기')),
                                        const SizedBox(width: 10),
                                        ElevatedButton(onPressed: () {}, child: const Text('구매정보 보기')),
                                      ],
                                    )
                                  ],
                                ),
                                const Expanded(child: Text('')),
                              ],
                            ),
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget getInfoRow(String title, String info) {
    return Row(
      children: [
        SizedBox(
            width: 150, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        const SizedBox(width: 20),
        Text(info, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/user/user.dart' as user_info;

class UserMain extends StatefulWidget {
  UserMain({Key? key}) : super(key: key);

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  final TextEditingController _searchController = TextEditingController();
  final double cardWidth = 400;
  late Future userFuture;
  bool isSearched = false;
  List<String> statusList = ['new', 'basic', 'premium'];

  @override
  Widget build(BuildContext context) {
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
                        userFuture = Database().getDocs(collection: 'Users', field: 'userEmail', equalTo: userEmail, orderBy: 'id');
                        isSearched = true;
                      });
                    }
                  },
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            isSearched ?
            FutureBuilder(
              future: userFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                  user_info.User user = user_info.User();
                  for (dynamic snapshot in snapshot.data) {
                    user = user_info.User.fromJson(snapshot);
                  }

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
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Theme.of(context).colorScheme.primaryContainer),
                                            child: Text(
                                              statusList[user.status],
                                              style:
                                              TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 50),
                                      getInfoRow('이메일', user.email),
                                      const SizedBox(height: 10),
                                      getInfoRow('가입일', '0000-00-00'),
                                      const SizedBox(height: 10),
                                      getInfoRow('최종로그인', '0000-00-00'),
                                      const Divider(height: 50),
                                      getInfoRow('구독시작일', '0000-00-00'),
                                      const SizedBox(height: 10),
                                      getInfoRow('구독종료일', '0000-00-00'),
                                      const Divider(height: 50),
                                      getInfoRow('언어', user.language),
                                      const SizedBox(height: 10),
                                      getInfoRow('완료레슨', '00개'),
                                      const SizedBox(height: 10),
                                      getInfoRow('즐겨찾기', '00개'),
                                      const SizedBox(height: 10),
                                      getInfoRow('메시지수신', '허용'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(onPressed: () {}, child: const Text('교정내역 보기')),
                                // todo: 교정으로 이동해서 유저이메일로 query
                                const SizedBox(width: 10),
                                ElevatedButton(onPressed: () {}, child: const Text('구매정보 보기')),
                                const SizedBox(width: 10),
                                ElevatedButton(onPressed: () {}, child: const Text('유저정보 수정하기')),
                                const SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                        const Expanded(child: Text('')),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ) : const SizedBox.shrink(),
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

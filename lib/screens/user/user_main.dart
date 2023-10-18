import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/user/user.dart' as user_info;
import 'package:podo_admin/screens/user/user_writing_record.dart';

class UserMain extends StatefulWidget {
  UserMain({Key? key, this.userId, this.userEmail}) : super(key: key);

  String? userId;
  String? userEmail;

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  final TextEditingController _searchController = TextEditingController();
  final double cardWidth = 500;
  late Future userFuture;
  bool isSearched = false;
  List<String> statusList = ['new', 'basic', 'premium', 'trial'];
  int? lessonCount;
  int? readingCount;
  int? cloudCount;
  int? flashcardCount;
  late List<dynamic> searchResult;
  user_info.User user = user_info.User();
  int totalUserCount = 0;
  int newUserCount = 0;
  int basicUserCount = 0;
  int trialUserCount = 0;
  int premiumUserCount = 0;
  int newUserPercent = 0;
  int trialUserPercent = 0;
  int basicUserPercent = 0;
  int premiumUserPercent = 0;

  @override
  void initState() {
    super.initState();
    Future.wait([
      Database().getCount(collection: 'Users', field: 'status', equalTo: 0),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 3),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 1),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 2),
    ]).then((snapshot) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          newUserCount = snapshot[0];
          trialUserCount = snapshot[1];
          basicUserCount = snapshot[2];
          premiumUserCount = snapshot[3];
          totalUserCount = newUserCount + trialUserCount + basicUserCount + premiumUserCount;
          newUserPercent = (newUserCount / totalUserCount * 100).round();
          trialUserPercent = (trialUserCount / totalUserCount * 100).round();
          basicUserPercent = (basicUserCount / totalUserCount * 100).round();
          premiumUserPercent = (premiumUserCount / totalUserCount * 100).round();
        });
      });
    });
  }

  Widget getCountUser(String title, int count, {int? percent}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(': ${count.toString()} ', style: const TextStyle(fontSize: 18)),
        percent != null ?
        Text('(${percent.toString()}%)', style: const TextStyle(fontSize: 15, color: Colors.grey)) : const Text('      ||'),
        const SizedBox(width: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId != null && !isSearched) {
      userFuture = Database().getDocs(collection: 'Users', field: 'id', equalTo: widget.userId, orderBy: 'status');
      isSearched = true;
    }

    if (widget.userEmail != null && !isSearched) {
      userFuture =
          Database().getDocs(collection: 'Users', field: 'email', equalTo: widget.userEmail, orderBy: 'status');
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
                      labelText: '이메일 또는 아이디',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isSearched = false;
                    });

                    final searchInput = _searchController.text;
                    if (searchInput.isNotEmpty) {
                      List<dynamic> emailQuery = await Database()
                          .getDocs(collection: 'Users', field: 'email', equalTo: searchInput, orderBy: 'id');
                      if (emailQuery.isNotEmpty) {
                        searchResult = emailQuery;
                      } else {
                        List<dynamic> idQuery = await Database()
                            .getDocs(collection: 'Users', field: 'id', equalTo: searchInput, orderBy: 'email');
                        if (idQuery.isNotEmpty) {
                          searchResult = idQuery;
                        } else {
                          searchResult = [];
                        }
                      }

                      if (searchResult.isNotEmpty) {
                        for (dynamic snapshot in searchResult) {
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
                      }
                      setState(() {
                        isSearched = true;
                      });
                    }
                  },
                  child: const Text('검색'),
                ),
                const SizedBox(width: 50),
                getCountUser('Total', totalUserCount),
                getCountUser('New', newUserCount, percent: newUserPercent),
                getCountUser('Trial', trialUserCount, percent: trialUserPercent),
                getCountUser('Basic', basicUserCount, percent: basicUserPercent),
                getCountUser('Premium', premiumUserCount, percent: premiumUserPercent),
              ],
            ),
            const SizedBox(height: 50),
            !isSearched
                ? const SizedBox.shrink()
                : searchResult.isEmpty
                    ? const Center(child: Text('검색된 유저가 없습니다.'))
                    : Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Row(
                          children: [
                            SingleChildScrollView(
                              child: Column(
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
                                                          color: Theme.of(context).colorScheme.onPrimaryContainer),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                user.status == 3
                                                    ? Text(
                                                        '${MyDateFormat().getDateOnlyFormat(user.trialEnd!)} 까지')
                                                    : const SizedBox.shrink()
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
                                            getInfoRow('최종로그인', MyDateFormat().getDateOnlyFormat(user.dateSignIn)),
                                            const Divider(height: 50),
                                            getInfoRow('언어', user.language),
                                            const SizedBox(height: 10),
                                            getInfoRow('OS', user.os),
                                            const SizedBox(height: 10),
                                            getInfoRow('메시지수신', user.fcmPermission.toString()),
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
                                  ElevatedButton(
                                      onPressed: () {
                                        Get.to(UserWritingRecord(), arguments: user.id);
                                      },
                                      child: const Text('교정내역 보기'))
                                ],
                              ),
                            ),
                            const Expanded(child: Text('')),
                          ],
                        ),
                      ),
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

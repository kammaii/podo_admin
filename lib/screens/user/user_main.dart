import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/ranking.dart';
import 'package:podo_admin/screens/user/user.dart' as user_info;
import 'package:podo_admin/screens/user/user_writing_record.dart';
import 'package:fl_chart/fl_chart.dart';

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
  int totalCount = 0;
  int newCount = 0;
  int basicCount = 0;
  int trialCount = 0;
  int premiumCount = 0;
  int newPercent = 0;
  int trialPercent = 0;
  int basicPercent = 0;
  int premiumPercent = 0;
  List<FlSpot> dataPoints = [];
  int maxActiveCount = 0;

  @override
  void initState() {
    super.initState();
    Future.wait([
      Database().getCount(collection: 'Users', field: 'status', equalTo: 0),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 3),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 1),
      Database().getCount(collection: 'Users', field: 'status', equalTo: 2),
    ]).then((snapshot) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        setState(() {
          newCount = snapshot[0];
          trialCount = snapshot[1];
          basicCount = snapshot[2];
          premiumCount = snapshot[3];
          totalCount = newCount + trialCount + basicCount + premiumCount;
          newPercent = (newCount / totalCount * 100).round();
          trialPercent = (trialCount / totalCount * 100).round();
          basicPercent = (basicCount / totalCount * 100).round();
          premiumPercent = (premiumCount / totalCount * 100).round();
        });
      });
    });
  }

  Widget getCountUser(String title, int count, {int? percent}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(': ${count.toString()} ', style: const TextStyle(fontSize: 18)),
        percent != null
            ? Text('(${percent.toString()}%)', style: const TextStyle(fontSize: 15, color: Colors.grey))
            : const Text('      :'),
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
                  onPressed: () {
                    final searchInput = _searchController.text;
                    if (searchInput.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                      if (emailRegex.hasMatch(searchInput)) {
                        userFuture = Database()
                            .getDocs(collection: 'Users', field: 'email', equalTo: searchInput, orderBy: 'id');
                      } else {
                        userFuture = Database()
                            .getDocs(collection: 'Users', field: 'id', equalTo: searchInput, orderBy: 'email');
                      }
                      setState(() {
                        isSearched = true;
                      });
                    }
                  },
                  child: const Text('검색'),
                ),
                const SizedBox(width: 50),
                Row(
                  children: [
                    getCountUser('Total', totalCount),
                    getCountUser('New', newCount, percent: newPercent),
                    getCountUser('Trial', trialCount, percent: trialPercent),
                    getCountUser('Basic', basicCount, percent: basicPercent),
                    getCountUser('Premium', premiumCount, percent: premiumPercent),
                    ElevatedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final d_1 = today.subtract(const Duration(days: 1));
                          final d_2 = today.subtract(const Duration(days: 2));
                          final d_3 = today.subtract(const Duration(days: 3));
                          final d_4 = today.subtract(const Duration(days: 4));
                          final d_5 = today.subtract(const Duration(days: 5));
                          final query =
                              FirebaseFirestore.instance.collection('Users').where('status', isEqualTo: 1);

                          final todayCount = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: today)
                              .where('dateSignIn', isLessThan: today.add(const Duration(days: 1)))
                              .count()
                              .get();

                          final d_1Count = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: d_1)
                              .where('dateSignIn', isLessThan: today)
                              .count()
                              .get();

                          final d_2Count = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: d_2)
                              .where('dateSignIn', isLessThan: d_1)
                              .count()
                              .get();

                          final d_3Count = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: d_3)
                              .where('dateSignIn', isLessThan: d_2)
                              .count()
                              .get();

                          final d_4Count = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: d_4)
                              .where('dateSignIn', isLessThan: d_3)
                              .count()
                              .get();

                          final d_5Count = await query
                              .where('dateSignIn', isGreaterThanOrEqualTo: d_5)
                              .where('dateSignIn', isLessThan: d_4)
                              .count()
                              .get();

                          dataPoints = [
                            FlSpot(0, d_5Count.count.toDouble()),
                            FlSpot(1, d_4Count.count.toDouble()),
                            FlSpot(2, d_3Count.count.toDouble()),
                            FlSpot(3, d_2Count.count.toDouble()),
                            FlSpot(4, d_1Count.count.toDouble()),
                            FlSpot(5, todayCount.count.toDouble()),
                          ];
                          List<int> activeCounts = [
                            todayCount.count,
                            d_1Count.count,
                            d_2Count.count,
                            d_3Count.count,
                            d_4Count.count,
                            d_5Count.count
                          ];
                          maxActiveCount = activeCounts[0];
                          for (int count in activeCounts) {
                            if (count > maxActiveCount) {
                              maxActiveCount = count;
                            }
                          }
                          final totalActive = activeCounts.reduce((a, b) => a+b);

                          Get.dialog(AlertDialog(
                            title: Text('최근 5일간 활성 Basic 유저 수:  총 $totalActive 명 (${(totalActive/basicCount*100).roundToDouble()}%)',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            content: SizedBox(
                              height: 300,
                              width: 400,
                              child: LineChart(LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(),
                                  leftTitles: const AxisTitles(),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, interval: 10, reservedSize: 50)),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (x, value) {
                                      if (x == 0) {
                                        return const Text('D-5');
                                      } else if (x == 1) {
                                        return const Text('D-4');
                                      } else if (x == 2) {
                                        return const Text('D-3');
                                      } else if (x == 3) {
                                        return const Text('D-2');
                                      } else if (x == 4) {
                                        return const Text('D-1');
                                      } else {
                                        return const Text('Today');
                                      }
                                    },
                                    interval: 1,
                                  )),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(width: 1),
                                ),
                                minX: 0,
                                maxX: 5,
                                minY: 0,
                                maxY: ((maxActiveCount / 10).ceil()) * 10 + 10,
                                lineTouchData: const LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(tooltipBgColor: Colors.white)),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: dataPoints,
                                    color: Colors.deepPurple,
                                    dotData: const FlDotData(),
                                  ),
                                ],
                              )),
                            ),
                          ));
                        },
                        child: const Text('활성Basic')),
                    const SizedBox(width: 20),
                    ElevatedButton(
                        onPressed: () {
                          Get.to(const Ranking());
                        },
                        child: const Text('랭킹'))
                  ],
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
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 15, vertical: 5),
                                                        child: Text(
                                                          statusList[user.status],
                                                          style: TextStyle(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer),
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
                                                GestureDetector(child: getInfoRow('아이디', user.id), onTap: (){
                                                  Clipboard.setData(ClipboardData(text: user.id));
                                                  Get.snackbar('아이디가 클립보드에 저장되었습니다.', user.id, snackPosition: SnackPosition.BOTTOM);
                                                }),
                                                const SizedBox(height: 10),
                                                GestureDetector(child: getInfoRow('이메일', user.email), onTap: (){
                                                  Clipboard.setData(ClipboardData(text: user.email));
                                                  Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email, snackPosition: SnackPosition.BOTTOM);
                                                }),
                                                const SizedBox(height: 10),
                                                getInfoRow('이름', user.name),
                                                const SizedBox(height: 10),
                                                getInfoRow(
                                                    '가입일', MyDateFormat().getDateOnlyFormat(user.dateSignUp)),
                                                const SizedBox(height: 10),
                                                getInfoRow(
                                                    '최종로그인', MyDateFormat().getDateOnlyFormat(user.dateSignIn)),
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

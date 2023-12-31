import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/user/ranking.dart';
import 'package:podo_admin/screens/user/user.dart' as user_info;
import 'package:podo_admin/screens/user/user_list.dart';
import 'package:podo_admin/screens/user/user_state_manager.dart';
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
  final controller = Get.find<UserStateManager>();

  Widget getCountUser(String title, int count, {int? percent, bool isTrial = false}) {
    double size = MediaQuery.of(context).size.width;
    if(size >= 1700) {
      return Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(': ${count.toString()} ', style: const TextStyle(fontSize: 18)),
          isTrial
              ? Text(
              '(${(controller.trialCount - controller.trialEndCount).toString()}/${controller.trialEndCount
                  .toString()}) ')
              : const SizedBox.shrink(),
          percent != null
              ? Text('(${percent.toString()}%)', style: const TextStyle(fontSize: 15, color: Colors.grey))
              : const Text('      :'),
          const SizedBox(width: 30),
        ],
      );
    } else {
      return Row(
        children: [
          Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(': ${count.toString()} ', style: const TextStyle(fontSize: 18)),
                  isTrial
                      ? Text(
                      '(${(controller.trialCount - controller.trialEndCount).toString()}/${controller.trialEndCount
                          .toString()}) ')
                      : const SizedBox.shrink(),
                  percent != null
                      ? Text('(${percent.toString()}%)', style: const TextStyle(fontSize: 15, color: Colors.grey))
                      : const Text('      :'),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      );
    }
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
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
                                      collection: 'Users/${user.id}/Histories',
                                      field: 'item',
                                      equalTo: 'cloudMessage'),
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
                                  child: SingleChildScrollView(
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
                                                  GestureDetector(
                                                      child: getInfoRow('아이디', user.id),
                                                      onTap: () {
                                                        Clipboard.setData(ClipboardData(text: user.id));
                                                        Get.snackbar('아이디가 클립보드에 저장되었습니다.', user.id,
                                                            snackPosition: SnackPosition.BOTTOM);
                                                      }),
                                                  const SizedBox(height: 10),
                                                  GestureDetector(
                                                      child: getInfoRow('이메일', user.email),
                                                      onTap: () {
                                                        Clipboard.setData(ClipboardData(text: user.email));
                                                        Get.snackbar('이메일이 클립보드에 저장되었습니다.', user.email,
                                                            snackPosition: SnackPosition.BOTTOM);
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
            const SizedBox(width: 30),
            Expanded(
              child: GetBuilder<UserStateManager>(
                builder: (_) {
                  return Column(
                    children: [
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          getCountUser('Total', controller.totalCount),
                          getCountUser('New', controller.newCount, percent: controller.newPercent),
                          GestureDetector(
                              child: getCountUser('Trial', controller.trialCount,
                                  percent: controller.trialPercent, isTrial: true),
                              onDoubleTap: () {
                                Get.to(const UserList(), arguments: {
                                  'title': 'Trial 진행 중인 유저 리스트',
                                  'query': FirebaseFirestore.instance
                                      .collection('Users')
                                      .where('status', isEqualTo: 3)
                                      .where('trialEnd',
                                          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
                                      .limit(20)
                                      .orderBy('trialEnd', descending: false),
                                  'userCount': controller.trialCount,
                                });
                              }),
                          GestureDetector(
                              child:
                                  getCountUser('Basic', controller.basicCount, percent: controller.basicPercent),
                              onDoubleTap: () {
                                Get.to(const UserList(), arguments: {
                                  'title': 'Basic 유저 리스트',
                                  'query': FirebaseFirestore.instance
                                      .collection('Users')
                                      .where('status', isEqualTo: 1)
                                      .limit(20)
                                      .orderBy('dateSignIn', descending: true),
                                  'userCount': controller.basicCount,
                                });
                              }),
                          GestureDetector(
                              child: getCountUser('Premium', controller.premiumCount,
                                  percent: controller.premiumPercent),
                              onDoubleTap: () {
                                Get.to(const UserList(), arguments: {
                                  'title': 'Premium 유저 리스트',
                                  'query': FirebaseFirestore.instance
                                      .collection('Users')
                                      .where('status', isEqualTo: 2)
                                      .orderBy('dateSignIn', descending: true),
                                  'userCount': controller.premiumCount,
                                });
                              }),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: () async {
                              controller.isRefreshBtnClicked = true;
                              controller.update();
                              controller.runInit();
                            },
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                              onPressed: () {
                                Get.to(const Ranking());
                              },
                              child: const Text('랭킹')),
                        ],
                      ),
                      controller.isRefreshBtnClicked
                          ? const Expanded(child: Center(child: CircularProgressIndicator()))
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        '최근 5일간 활성 유저 수: ${controller.totalActive}명 (${(controller.totalActive / (controller.basicCount + controller.trialCount) * 100).roundToDouble()}%)    Trial: ${controller.trialActiveCount}명 (${(controller.trialActiveCount / controller.trialCount * 100).roundToDouble()}%),  Basic: ${controller.basicActiveCount}명 (${(controller.basicActiveCount / controller.basicCount * 100).roundToDouble()}%)',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 500,
                                      width: 700,
                                      child: LineChart(LineChartData(
                                        gridData: const FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(),
                                          leftTitles: const AxisTitles(),
                                          rightTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: true, interval: 10, reservedSize: 50)),
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
                                        maxY: ((controller.maxActiveCount / 10).ceil()) * 10 + 10,
                                        lineTouchData: LineTouchData(
                                            touchTooltipData: LineTouchTooltipData(
                                                tooltipBgColor: Colors.white,
                                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                                  return touchedBarSpots.map((barSpot) {
                                                    String barTitle = 'Total';
                                                    Color color = Colors.deepPurple;
                                                    switch (barSpot.barIndex) {
                                                      case 0:
                                                        barTitle = 'Trial';
                                                        color = Colors.blueAccent;
                                                        break;
                                                      case 1:
                                                        barTitle = 'Basic';
                                                        color = Colors.green;
                                                        break;
                                                    }
                                                    return LineTooltipItem(
                                                        '$barTitle: ${barSpot.y}',
                                                        TextStyle(
                                                            color: color,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15));
                                                  }).toList();
                                                })),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: controller.trialActivePoints,
                                            color: Colors.blueAccent,
                                            dotData: const FlDotData(),
                                          ),
                                          LineChartBarData(
                                            spots: controller.basicActivePoints,
                                            color: Colors.green,
                                            dotData: const FlDotData(),
                                          ),
                                          LineChartBarData(
                                            spots: controller.totalActivePoints,
                                            color: Colors.deepPurple,
                                            dotData: const FlDotData(),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            )
                    ],
                  );
                },
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

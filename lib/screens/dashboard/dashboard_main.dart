import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/dashboard/user_count.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({super.key});

  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  late Future<List<dynamic>> futureUserCounts;
  int days = 10;
  final NEW = 'New';
  final BASIC = 'Basic';
  final PREMIUM = 'Premium';
  final TRIAL = 'Trial';
  final TOTAL = 'Total';

  @override
  void initState() {
    super.initState();
    futureUserCounts = Database().getDocs(collection: 'UserCounts', orderBy: 'date', limit: days);
  }

  List<FlSpot> getSpots(List<double> counts) {
    List<FlSpot> spots = [];
    for (int i = 0; i < days; i++) {
      spots.add(FlSpot(i.toDouble(), counts[i]));
    }
    return spots;
  }

  LineChartBarData getBar(List<double> userList, Color barColor) {
    return LineChartBarData(
      spots: getSpots(userList),
      color: barColor,
      dotData: const FlDotData(),
    );
  }

  double getUserStatusPercent(double value) {
    return double.parse((value * 100).toStringAsFixed(1));
  }

  Widget getGraph(
      {required String title,
      required List<LineChartBarData> bars,
      required int maxCount,
      double addMaxY = 10,
      List<String>? barTitles}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 500,
            width: 700,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (x, value) {
                    if (x == days - 1) {
                      return const Text('Today');
                    } else {
                      return Text('D-${days - x - 1}');
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
              maxX: days.toDouble() - 1,
              minY: 0,
              maxY: ((maxCount / 10).ceil()) * 10 + addMaxY,
              lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  int index = barSpot.barIndex;
                  return LineTooltipItem(barTitles == null ? '${barSpot.y}' : '${barTitles[index]}: ${barSpot.y}',
                      TextStyle(color: bars[index].color, fontWeight: FontWeight.bold, fontSize: 15));
                }).toList();
              })),
              lineBarsData: bars,
            )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: futureUserCounts,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                  List<UserCount> userCounts = [];
                  for (dynamic snapshot in snapshot.data) {
                    userCounts.add(UserCount.fromJson(snapshot));
                  }
                  if (userCounts.isEmpty) {
                    return const Center(child: Text('검색된 UserCount 가 없습니다.'));
                  } else {
                    int statusPremium = userCounts[0].statusPremium;
                    int goal = 1000;
                    List<double> ratioNewList = [];
                    List<double> ratioBasicList = [];
                    List<double> ratioPremiumList = [];
                    List<double> ratioTrialList = [];
                    List<double> totalUserList = [];
                    List<double> activeNewList = [];
                    List<double> activeBasicList = [];
                    List<double> activePremiumList = [];
                    List<double> activeTrialList = [];
                    List<double> activeTotalList = [];
                    List<double> signUpUserList = [];
                    List<double> deletedUserList = [];

                    // Date의 역순으로 각 field의 List 생성
                    for (UserCount userCount in userCounts) {
                      int total = userCount.totalUsers;
                      ratioNewList.insert(0, getUserStatusPercent(userCount.statusNew / total));
                      ratioBasicList.insert(0, getUserStatusPercent(userCount.statusBasic / total));
                      ratioPremiumList.insert(0, getUserStatusPercent(userCount.statusPremium / total));
                      ratioTrialList.insert(0, getUserStatusPercent(userCount.statusTrial / total));
                      totalUserList.insert(0, userCount.totalUsers.toDouble());
                      activeNewList.insert(0, userCount.activeNew.toDouble());
                      activeBasicList.insert(0, userCount.activeBasic.toDouble());
                      activePremiumList.insert(0, userCount.activePremium.toDouble());
                      activeTrialList.insert(0, userCount.activeTrial.toDouble());
                      activeTotalList.insert(0, userCount.activeTotal.toDouble());
                      signUpUserList.insert(0, userCount.signUpUsers.toDouble());
                      deletedUserList.insert(0, userCount.deletedUsers.toDouble());
                    }

                    List<LineChartBarData> totalUserBars = [getBar(totalUserList, Colors.red)];
                    int totalUserMax = totalUserList.reduce((a, b) => a > b ? a : b).round();

                    List<LineChartBarData> userChangeBars = [
                      getBar(signUpUserList, Colors.blueAccent),
                      getBar(deletedUserList, Colors.red),
                    ];

                    int userChangeMax = signUpUserList.reduce((a, b) => a > b ? a : b).round();
                    userChangeMax = deletedUserList.reduce((a, b) => a > b ? a : b).round();

                    List<LineChartBarData> activeUserBars = [
                      getBar(activeNewList, Colors.yellow),
                      getBar(activeBasicList, Colors.blueAccent),
                      getBar(activePremiumList, Colors.purple),
                      getBar(activeTrialList, Colors.green),
                      getBar(activeTotalList, Colors.red),
                    ];
                    int activeMax = activeTotalList.reduce((a, b) => a > b ? a : b).round();

                    List<LineChartBarData> statusRatioBars = [
                      getBar(ratioNewList, Colors.yellow),
                      getBar(ratioBasicList, Colors.blueAccent),
                      getBar(ratioPremiumList, Colors.purple),
                      getBar(ratioTrialList, Colors.green),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('목표 달성률: ${(statusPremium / goal * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: statusPremium / goal,
                        ),
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment.topRight,
                            child: Text('($statusPremium / $goal)',
                                style: const TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 20),
                        ResponsiveBreakpoints.of(context).largerThan(TABLET)
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      getGraph(
                                          title: 'Total Users',
                                          bars: totalUserBars,
                                          maxCount: totalUserMax,
                                          addMaxY: 2900),
                                      const SizedBox(width: 30),
                                      getGraph(
                                          title: 'Status Ratio',
                                          bars: statusRatioBars,
                                          maxCount: 90,
                                          barTitles: [NEW, BASIC, PREMIUM, TRIAL]),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      getGraph(
                                        title: 'User Change',
                                        bars: userChangeBars,
                                        maxCount: userChangeMax,
                                        barTitles: ['SignUp', 'Deleted'],
                                      ),
                                      const SizedBox(width: 30),
                                      getGraph(
                                          title: 'Active Users',
                                          bars: activeUserBars,
                                          maxCount: activeMax,
                                          barTitles: [NEW, BASIC, PREMIUM, TRIAL, TOTAL]),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  getGraph(
                                      title: 'Total Users',
                                      bars: totalUserBars,
                                      maxCount: totalUserMax,
                                      addMaxY: 3000),
                                  const SizedBox(width: 30),
                                  getGraph(
                                      title: 'Status Ratio',
                                      bars: statusRatioBars,
                                      maxCount: 100,
                                      barTitles: [NEW, BASIC, PREMIUM]),
                                  const SizedBox(width: 30),
                                  getGraph(
                                    title: 'SignUp Users',
                                    bars: userChangeBars,
                                    maxCount: userChangeMax,
                                    barTitles: ['SignUp', 'Deleted'],
                                  ),
                                  const SizedBox(width: 30),
                                  getGraph(
                                      title: 'Active Users',
                                      bars: activeUserBars,
                                      maxCount: activeMax,
                                      barTitles: [NEW, BASIC, PREMIUM, TRIAL, TOTAL]),
                                ],
                              )
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text('에러: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }
}

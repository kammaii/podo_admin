import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/reading/reading.dart';
import 'package:podo_admin/screens/reading/reading_detail.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';

class ReadingMain extends StatefulWidget {
  ReadingMain({Key? key}) : super(key: key);

  @override
  State<ReadingMain> createState() => _ReadingMainState();
}

class _ReadingMainState extends State<ReadingMain> {
  late ReadingStateManager controller;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReadingStateManager());
    selectedCategory = controller.categories[0];
    getDataFromDb();
  }

  getDataFromDb() {
    controller.futureList = Database().getDocumentsFromDb(
        collection: 'Readings',
        field: 'category',
        equalTo: selectedCategory,
        orderBy: 'orderId',
        descending: false);
  }

  updateDB({required String collection, required String docId, required Map<String, dynamic> value}) {
    Database().updateField(collection: collection, docId: docId, map: value);
    updateState();
    Get.back();
  }

  updateState() {
    setState(() {
      getDataFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getCategoryRadioBtn(String value) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: selectedCategory,
        f: (String? value) {
          selectedCategory = value!;
          updateState();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('읽기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    getCategoryRadioBtn(controller.categories[0]),
                    getCategoryRadioBtn(controller.categories[1]),
                    getCategoryRadioBtn(controller.categories[2]),
                    getCategoryRadioBtn(controller.categories[3]),
                    getCategoryRadioBtn(controller.categories[4]),
                    getCategoryRadioBtn(controller.categories[5]),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(const ReadingDetail());
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      '추가하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: readingTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget readingTable() {
    return FutureBuilder(
      future: controller.futureList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.readings = [];
          for (dynamic snapshot in snapshot.data) {
            controller.readings.add(Reading.fromJson(snapshot));
          }
          List<Reading> readings = controller.readings;
          if (readings.isEmpty) {
            return const Center(child: Text('검색된 읽기가 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('순서'), size: ColumnSize.S),
                DataColumn2(label: Text('아이디'), size: ColumnSize.L),
                DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                DataColumn2(label: Text('레벨'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('좋아요'), size: ColumnSize.S),
                DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(readings.length, (index) {
                Reading reading = readings[index];
                return DataRow(cells: [
                  DataCell(Text(reading.orderId.toString())),
                  DataCell(Text(reading.id.toString())),
                  DataCell(Text(reading.title['ko']!), onTap: () {
                    Get.to(const ReadingDetail(), arguments: reading);
                  }),
                  DataCell(Text(reading.level.toString())),
                  DataCell(Text(reading.tag != null ? reading.tag.toString() : ''), onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('태그를 입력하세요'),
                        content: MyTextField().getTextField(fn: (String? value) {
                          reading.tag = value!;
                        }),
                        actions: [
                          TextButton(
                              onPressed: () {
                                updateDB(
                                    collection: 'Readings',
                                    docId: reading.id,
                                    value: {'tag': reading.tag});
                              },
                              child: const Text('저장'))
                        ],
                      ),
                    );
                  }),
                  DataCell(Text(reading.likeCount.toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              if (index != 0) {
                                setState(() {
                                  int newIndex = index - 1;
                                  Reading thatReading = readings[newIndex];
                                  Database().switchOrderTransaction(collection: 'Readings', docId1: reading.id, docId2: thatReading.id);
                                  getDataFromDb();
                                  Get.back();
                                });
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('첫번째 읽기입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_up_outlined)),
                        IconButton(
                            onPressed: () {
                              if (index != readings.length - 1) {
                                setState(() {
                                  int newIndex = index + 1;
                                  Reading thatReading = readings[newIndex];
                                  Database().switchOrderTransaction(collection: 'Readings', docId1: reading.id, docId2: thatReading.id);
                                  getDataFromDb();
                                  Get.back();
                                });
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('마지막 레슨입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_down_outlined)),
                      ],
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: const Text('정말 삭제하겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    Database()
                                        .deleteLessonFromDb(collection: 'Readings', lesson: reading);
                                    getDataFromDb();
                                    Get.back();
                                  });
                                },
                                child: const Text(
                                  '네',
                                  style: TextStyle(color: Colors.red),
                                )),
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('아니오')),
                          ],
                        ));
                      },
                    ),
                  )
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
    );
  }
}

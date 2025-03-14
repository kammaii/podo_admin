import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:podo_admin/screens/user/user.dart';
import 'package:podo_admin/screens/user/user_main.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_detail.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';
import 'package:responsive_framework/responsive_framework.dart';

class WritingMain extends StatelessWidget {
  WritingMain({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WritingStateManager controller = Get.put(WritingStateManager());

    Widget getRadioBtn(String title) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: title,
        groupValue: controller.statusRadio,
        f: controller.changeStatusRadio(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('교정'),
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<WritingStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  getRadioBtn('신규'),
                  getRadioBtn('교정완료'),
                  getRadioBtn('교정불필요'),
                  getRadioBtn('교정불가'),
                  //getRadioBtn('전체'),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: controller.futureWritings,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == true) {
                      List<Writing> writings = [];
                      for (dynamic snapshot in snapshot.data) {
                        writings.add(Writing.fromJson(snapshot));
                      }
                      controller.writings = writings;
                      if (writings.isEmpty) {
                        return const Center(child: Text('검색된 교정이 없습니다.'));
                      } else {
                        if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
                          return DataTable2(
                            columns: const [
                              DataColumn2(label: Text('날짜'), size: ColumnSize.S),
                              DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                              DataColumn2(label: Text('타이틀'), size: ColumnSize.S),
                              DataColumn2(label: Text('내용'), size: ColumnSize.L),
                              DataColumn2(label: Text('유저'), size: ColumnSize.S),
                              DataColumn2(label: Text('이름'), size: ColumnSize.S),
                              DataColumn2(label: Text('프리미엄'), size: ColumnSize.S),
                            ],
                            rows: List<DataRow>.generate(controller.writings.length, (index) {
                              Writing writing = controller.writings[index];

                              return DataRow(cells: [
                                DataCell(Text(MyDateFormat().getDateFormat(writing.dateWriting))),
                                DataCell(Text(writing.id.substring(0, 8))),
                                DataCell(Text(writing.questionTitle), onTap: () {
                                  controller.writingIndex = index;
                                  Get.to(WritingDetail());
                                }),
                                DataCell(Text(writing.userWriting), onTap: () {
                                  controller.writingIndex = index;
                                  Get.to(WritingDetail());
                                }),
                                DataCell(Text(writing.userId.substring(0, 8)), onTap: () {
                                  controller.searchUserWriting(writing.userId);
                                }, onDoubleTap: () {
                                  Get.to(UserMain(userId: writing.userId));
                                }),
                                DataCell(Text(writing.userName)),
                                DataCell(FutureBuilder(
                                        future: Database().getDoc(collection: 'Users', doc: writing.userId),
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text('');
                                          }
                                          Map<String, dynamic> data =
                                              snapshot.data!.data() as Map<String, dynamic>;
                                          User user = User.fromJson(data);
                                          if (user.status == 2) {
                                            writing.isPremiumUser = true;
                                            return const Icon(
                                              Icons.workspace_premium,
                                              color: Colors.deepPurple,
                                            );
                                          } else {
                                            return const Text('');
                                          }
                                        },
                                      )),
                              ]);
                            }),
                          );
                        } else {
                          return DataTable2(
                            columns: const [
                              DataColumn2(label: Text('날짜'), size: ColumnSize.L),
                              DataColumn2(label: Text('내용'), size: ColumnSize.L),
                              DataColumn2(label: Text('유저'), size: ColumnSize.L),
                              DataColumn2(label: Text('프리미엄'), size: ColumnSize.S),
                            ],
                            rows: List<DataRow>.generate(controller.writings.length, (index) {
                              Writing writing = controller.writings[index];

                              return DataRow(cells: [
                                DataCell(Text(MyDateFormat().getDateOnlyFormat(writing.dateWriting))),
                                DataCell(Text(writing.userWriting), onTap: () {
                                  controller.writingIndex = index;
                                  Get.to(WritingDetail());
                                }),
                                DataCell(Text(writing.userId.substring(0, 8)), onTap: () {
                                  controller.searchUserWriting(writing.userId);
                                }, onDoubleTap: () {
                                  Get.to(UserMain(userId: writing.userId));
                                }),
                                DataCell(FutureBuilder(
                                  future: Database().getDoc(collection: 'Users', doc: writing.userId),
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('');
                                    }
                                    Map<String, dynamic> data =
                                    snapshot.data!.data() as Map<String, dynamic>;
                                    User user = User.fromJson(data);
                                    if (user.status == 2) {
                                      writing.isPremiumUser = true;
                                      return const Icon(
                                        Icons.workspace_premium,
                                        color: Colors.deepPurple,
                                      );
                                    } else {
                                      return const Text('');
                                    }
                                  },
                                )),
                              ]);
                            }),
                          );
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

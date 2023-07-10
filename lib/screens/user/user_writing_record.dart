import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class UserWritingRecord extends StatelessWidget {
  UserWritingRecord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = Get.arguments;
    Map<int, String> statusMap = {0: '신규', 1: '교정완료', 2: '교정불필요', 3: '교정불가'};


    return Scaffold(
      appBar: AppBar(
        title: const Text('쓰기 기록'),
      ),
      body: FutureBuilder(
        future: Database().getDocs(collection: 'Writings', orderBy: 'dateWriting', field: 'userId', equalTo: userId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == true) {
            List<Writing> writings = [];
            for (dynamic snapshot in snapshot.data) {
              writings.add(Writing.fromJson(snapshot));
            }
            if(writings.isEmpty) {
              return const Center(child: Text('검색된 교정이 없습니다.'));
            } else {
              return DataTable2(
                columns: const [
                  DataColumn2(label: Text('날짜'), size: ColumnSize.S),
                  DataColumn2(label: Text('타이틀'), size: ColumnSize.S),
                  DataColumn2(label: Text('내용'), size: ColumnSize.L),
                  DataColumn2(label: Text('상태'), size: ColumnSize.S),
                ],
                rows: List<DataRow>.generate(writings.length, (index) {
                  Writing writing = writings[index];
                  String? status = statusMap[writing.status];

                  return DataRow(cells: [
                    DataCell(Text(MyDateFormat().getDateFormat(writing.dateWriting))),
                    DataCell(Text(writing.questionTitle)),
                    DataCell(Text(writing.userWriting)),
                    DataCell(Text(status!)),
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
    );
  }
}

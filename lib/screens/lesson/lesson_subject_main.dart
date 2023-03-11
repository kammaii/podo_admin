import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_card_main.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';

class LessonSubjectMain {
  late final Future<List<dynamic>> _future;
  late final bool _isBeginnerMode;
  bool _isTagClicked = false;

  LessonSubjectMain(this._future, this._isBeginnerMode);

  Widget get subjectTable {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == true) {
          List<LessonSubject> subjects = [];
          for (dynamic snapshot in snapshot.data) {
            subjects.add(LessonSubject.fromJson(snapshot));
          }
          if (subjects.isEmpty) {
            return const Center(child: Text('검색된 주제가 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('순서'), size: ColumnSize.S),
                DataColumn2(label: Text('주제'), size: ColumnSize.L),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('레슨'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(subjects.length, (index) {
                LessonSubject subject = subjects[index];
                return DataRow(cells: [
                  DataCell(Text(subject.orderId.toString())),
                  DataCell(Text(_isBeginnerMode ? subject.subject_ko! : subject.subject_en!), onTap: () {
                    Get.to(LessonCardMain());
                  }),
                  DataCell(Text(subject.isReleased ? '게시중' : '입력중')),
                  DataCell(Text(subject.lessons.length.toString())),
                  DataCell(
                    _isTagClicked
                        ? Row(
                      children: [
                        MyTextField().getTextField(),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              '저장',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Text(subject.tag ?? ''),
                    onTap: () {
                      _isTagClicked = !_isTagClicked;
                      //todo: setState or GetX
                    },
                  ),
                  DataCell(Row(
                    children: [
                      IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_drop_up_outlined)),
                      IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_drop_down_outlined)),
                    ],
                  ))
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

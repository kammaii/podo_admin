import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';

class LessonTitleMain {
  bool _isTagClicked = false;
  LessonStateManager controller = Get.find<LessonStateManager>();
  LessonTitleMain();

  Widget get titleTable {
    return FutureBuilder(
      future: controller.futureList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print('TITLE:: ${snapshot.connectionState}');
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.lessonTitles = [];
          for (dynamic snapshot in snapshot.data) {
            controller.lessonTitles.add(LessonTitle.fromJson(snapshot));
          }
          List<LessonTitle> titles = controller.lessonTitles;
          if (titles.isEmpty) {
            return const Center(child: Text('검색된 타이틀이 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('아이디'), size: ColumnSize.L),
                DataColumn2(label: Text('제목'), size: ColumnSize.L),
                DataColumn2(label: Text('문법'), size: ColumnSize.L),
                DataColumn2(label: Text('쓰기'), size: ColumnSize.S),
                DataColumn2(label: Text('무료'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(titles.length, (index) {
                LessonTitle title = titles[index];
                return DataRow(cells: [
                  DataCell(Text(title.id)),
                  DataCell(Text(title.title['ko']!), onTap: () {
                    //todo: dialog 열기;
                  }),
                  DataCell(Text(title.titleGrammar)),
                  DataCell(Text(title.writingTitles.length.toString())),
                  DataCell(Text(title.isFree ? 'O' : 'X')),
                  DataCell(Text(title.isReleased ? '게시중' : '입력중')),
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
                        : Text(title.tag ?? ''),
                    onTap: () {
                      _isTagClicked = !_isTagClicked;
                      //todo: setState or GetX
                    },
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        //todo:delete title
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

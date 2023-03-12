import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';

class LessonTitleMain {
  late final Future<List<dynamic>> _future;
  bool _isTagClicked = false;

  LessonTitleMain(this._future);

  Widget get titleTable {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == true) {
          List<LessonTitle> titles = [];
          for (dynamic snapshot in snapshot.data) {
            titles.add(LessonTitle.fromJson(snapshot));
          }
          if (titles.isEmpty) {
            return const Center(child: Text('검색된 타이틀이 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('아이디'), size: ColumnSize.S),
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
                  DataCell(Text(title.titleId)),
                  DataCell(Text(title.title_ko), onTap: () {
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

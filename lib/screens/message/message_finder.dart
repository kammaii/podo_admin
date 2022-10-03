import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class MessageFinder extends StatelessWidget {
  MessageFinder({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('답변 찾기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 500,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: '메시지 or 답변',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // todo : 검색실행
                  },
                  child: const Text('검색'),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Expanded(
            //   child: DataTable2(
            //     columns: const [
            //       DataColumn2(label: Text(''), size: ColumnSize.S),
            //       DataColumn2(label: Text('질문'), size: ColumnSize.L),
            //       DataColumn2(label: Text('답변'), size: ColumnSize.L),
            //       DataColumn2(label: Text(''), size: ColumnSize.S),
            //     ],
            //     rows: List<DataRow>.generate(_controller.messages.length, (index) {
            //       //todo: DB에서 검색된 메시지를 '즐겨찾기 우선', '날짜순' 으로 정렬해서 10개씩 끊어서 표시
            //
            //       return DataRow(cells: [
            //         DataCell(Text()),
            //         DataCell(Text()),
            //         DataCell(Text(), onTap: () {
            //         }),
            //         DataCell(ElevatedButton(
            //           onPressed: (){},
            //           child: const Text('선택'),
            //         )),
            //       ]);
            //     }),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

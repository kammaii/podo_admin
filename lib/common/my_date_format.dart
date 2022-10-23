import 'package:intl/intl.dart';

class MyDateFormat {
  String getDateFormat(DateTime time) {
    return DateFormat('yyyy.MM.dd_HH:mm:ss').format(time);
  }

  String getDateOnlyFormat(DateTime time) {
    return DateFormat('yyyy.MM.dd').format(time);
  }
}
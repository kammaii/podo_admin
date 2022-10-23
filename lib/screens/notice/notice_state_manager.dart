import 'package:get/get.dart';
import 'package:podo_admin/screens/notice/notice.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class NoticeStateManager extends GetxController{
  late List<Notice> notices;
  late String noticeTag;
  late bool hasDeadLine;

  @override
  void onInit() {
    notices = List.from(Notice.getSampleNotices()); // todo: DB에서 가져오기
    noticeTag = MyStrings.tagInfo;
    hasDeadLine = false;
  }

  void setNoticeActive(int index, bool isActive) {
    notices[index].isActive = isActive;
    dbUpdate();
  }

  void deleteNotice(int index) {
    notices.removeAt(index);
    dbUpdate();
  }

  void addNewNotice(Notice notice) {
    notices.add(notice);
    dbUpdate();
  }

  void dbUpdate() {
    //todo: DB에 업데이트
    update();
  }

  Function(String? value) changeTagRadio() {
    return (String? value) {
      noticeTag = value!;
      update();
    };
  }
}
import 'package:get/get.dart';
import 'package:podo_admin/screens/message/message.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class MessageStateManager extends GetxController{
  late List<Message> notices;
  late String noticeTag;
  late bool hasDeadLine;

  @override
  void onInit() {
    notices = List.from(Message.getSampleNotices()); // todo: DB에서 가져오기
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

  void addNewNotice(Message notice) {
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
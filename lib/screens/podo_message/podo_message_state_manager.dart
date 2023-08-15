import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/podo_message/podo_message.dart';
import 'package:podo_admin/screens/podo_message/podo_message_reply.dart';

class PodoMessageStateManager extends GetxController {
  late List<PodoMessage> messages;
  late List<PodoMessageReply> replies;
  late bool hasDeadLine;
  late bool isContentChecked;
  late List<int> replyStatusCount; //[0]:선정, [1]:미선정
  RxString statusRadio = '미선정'.obs;
  late String selectedMessageId;
  static String PODO_MESSAGES = 'PodoMessages';

  @override
  void onInit() {
    messages = [];
    replies = [];
    isContentChecked = false;
    replyStatusCount = List<int>.filled(2, 0);
  }

  initRadio() {
    statusRadio.value = '미선정';
  }

  Function(String? value) changeStatusRadio() {
    return (String? value) {
      statusRadio.value = value!;
      bool isSelected;
      value == '선정' ? isSelected = true : isSelected = false;
      getReplies(isSelected: isSelected);
    };
  }

  Future<void> setReplySelection({required String replyId, required bool selection}) async {
    await Database().updateField(
        collection: '$PODO_MESSAGES/$selectedMessageId/Replies', docId: replyId, map: {'isSelected': selection});
  }

  Future<void> getReplies({required bool isSelected}) async {
    replies = [];
    List<dynamic> snapshots = await Database().getDocs(
        collection: '$PODO_MESSAGES/$selectedMessageId/Replies',
        field: 'isSelected',
        equalTo: isSelected,
        orderBy: 'date');
    if (snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        PodoMessageReply reply = PodoMessageReply.fromJson(snapshot);
        replies.add(reply);
      }
    }
    update();
  }

  Future<void> getMessages() async {
    List<dynamic> snapshots = await Database().getDocs(collection: PODO_MESSAGES, orderBy: 'dateSaved');
    if (snapshots.isNotEmpty) {
      messages = [];
      for (dynamic snapshot in snapshots) {
        PodoMessage message = PodoMessage.fromJson(snapshot);
        messages.add(message);
      }
    }
    update();
  }

  void setBestReply() async{
    await Database().updateField(collection: PODO_MESSAGES, docId: selectedMessageId, map: {'hasBestReply': true});
    messages.firstWhere((message) => message.id == selectedMessageId).hasBestReply = true;
    update();
  }

  void setMessageActive(int index, bool isActive) async {
    await Database()
        .updateField(collection: PODO_MESSAGES, docId: messages[index].id, map: {'isActive': isActive});
    messages[index].isActive = isActive;
    update();
  }

  void deleteMessage(int index) async {
    await Database().deleteDoc(collection: PODO_MESSAGES, doc: messages[index]);
    messages.removeAt(index);
    update();
  }

  void saveMessage(PodoMessage message) async {
    message.dateSaved = DateTime.now();
    await Database().setDoc(collection: PODO_MESSAGES, doc: message);
    getMessages();
  }
}

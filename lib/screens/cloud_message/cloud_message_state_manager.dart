import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/cloud_message/cloud_message.dart';
import 'package:podo_admin/screens/cloud_message/cloud_reply.dart';

class CloudMessageStateManager extends GetxController{
  late List<CloudMessage> messages;
  late List<CloudReply> replies;
  late bool hasDeadLine;
  late bool isContentChecked;
  late String messageIdForReplyCount;
  late List<int> replyStatusCount; //[0]:선정, [1]:미선정
  RxString statusRadio = '미선정'.obs;
  late String selectedMessageId;


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
      print('ISSELECTED: $isSelected');
      getReplies(isSelected: isSelected);
    };
  }

  Future<void> setReplySelection({required String replyId, required bool selection}) async {
    await Database().updateField(collection: 'CloudMessages/$selectedMessageId/Replies', docId: replyId, map: {'isSelected': selection});
  }

  Future<void> getReplies({required bool isSelected}) async {
    replies = [];
    List<dynamic> snapshots = await Database().getDocs(collection: 'CloudMessages/$selectedMessageId/Replies', field: 'isSelected', equalTo: isSelected, orderBy: 'date');
    if(snapshots.isNotEmpty) {
      for (dynamic snapshot in snapshots) {
        CloudReply reply = CloudReply.fromJson(snapshot);
        replies.add(reply);
      }
    }
    update();
  }

  Future<void> getMessages() async {
    List<dynamic> snapshots = await Database().getDocs(collection: 'CloudMessages', orderBy: 'dateSaved');
    if(snapshots.isNotEmpty) {
      messages = [];
      for (dynamic snapshot in snapshots) {
        CloudMessage message = CloudMessage.fromJson(snapshot);
        messages.add(message);
        if(message.isActive) {
          messageIdForReplyCount = message.id;
        }
      }
    }
    await getReplyCount();
  }

  Future<void> getReplyCount({String? messageId}) async {
    replyStatusCount = [0,0];
    messageId != null ? messageIdForReplyCount = messageId : null;
    String collection = 'CloudMessages/$messageIdForReplyCount/Replies';
    replyStatusCount[0] = await Database().getCount(collection: collection, field: 'isSelected', equalTo: true);
    replyStatusCount[1] = await Database().getCount(collection: collection, field: 'isSelected', equalTo: false);
    update();
  }

  void setMessageActive(int index, bool isActive) async {
    await Database().updateField(collection: 'CloudMessages', docId: messages[index].id, map: {'isActive' : isActive});
    messages[index].isActive = isActive;
    update();
  }

  void deleteMessage(int index) async {
    await Database().deleteDoc(collection: 'CloudMessages', doc: messages[index]);
    messages.removeAt(index);
    update();
  }

  void saveMessage(CloudMessage message) async {
    message.dateSaved = DateTime.now();
    await Database().setDoc(collection: 'CloudMessages', doc: message);
    getMessages();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class Message {
  late String messageId;
  late String tag;
  late String userEmail;
  late String message;
  late String? reply;
  late DateTime sendTime;
  late DateTime? replyTime;
  late String status;
  late bool isFavorite;

  Message();

  void setReply(String reply) {
    reply = reply;
    replyTime = DateTime.now();
    status = MyStrings.complete;
  }

  List<Message> getSampleMessages() {
    Map<String, dynamic> sampleJson1 = {
      MESSAGEID: '0000-0000-0000',
      TAG: 'correction',
      USEREMAIL: 'sample1@gmail.com',
      MESSAGE: '안냥하세여',
      SENDTIME: Timestamp.now(),
      STATUS: 'new',
      ISFAVORITE: false,
    };

    Map<String, dynamic> sampleJson2 = {
      MESSAGEID: '1111-1111-1111',
      TAG: 'question',
      USEREMAIL: 'sample2@gmail.com',
      MESSAGE: '질문~~~~',
      SENDTIME: Timestamp.now(),
      STATUS: 'new',
      ISFAVORITE: true,
    };
    return [Message.fromJson(sampleJson1), Message.fromJson(sampleJson2)];
  }

  static const String MESSAGEID = 'messageId';
  static const String TAG = 'tag';
  static const String USEREMAIL = 'userEmail';
  static const String MESSAGE = 'message';
  static const String REPLY = 'reply';
  static const String SENDTIME = 'sendTime';
  static const String REPLYTIME = 'replyTime';
  static const String STATUS = 'status';
  static const String ISFAVORITE = 'isFavorite';

  Message.fromJson(Map<String, dynamic> json) {
    messageId = json[MESSAGEID];
    tag = json[TAG];
    userEmail = json[USEREMAIL];
    message = json[MESSAGE];
    reply = json[REPLY];
    Timestamp sendStamp = json[SENDTIME];
    Timestamp replyStamp = json[REPLYTIME];
    sendTime = sendStamp.toDate();
    replyTime = replyStamp?.toDate();
    status = json[STATUS];
    isFavorite = json[ISFAVORITE];
  }

  Map<String, dynamic> toJson() => {
        MESSAGEID: messageId,
        TAG: tag,
        USEREMAIL: userEmail,
        MESSAGE: message,
        REPLY: reply!,
        SENDTIME: Timestamp.fromDate(sendTime),
        REPLYTIME: Timestamp.fromDate(replyTime!),
        ISFAVORITE: isFavorite,
      };
}

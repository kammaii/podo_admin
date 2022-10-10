// import 'dart:core';
// import 'dart:core';
// import 'package:podo_admin/items/lesson_title.dart';
// import 'package:podo_admin/screens/user/podo_coin_usage.dart';
// import 'package:podo_admin/screens/user/premium.dart';
//
// class User {
//   late String email;
//   late String name;
//   late String photo;
//   late String country;
//   late double dateSignUp;
//   late double dateLastSignIn;
//   late bool isPremium;
//   double? datePremiumStart;
//   double? datePremiumEnd;
//   List<Premium>? premiumRecord;
//   int? podoCoin;
//   int? podoCoinMax;
//   List<PodoCoinUsage>? podoCoinRecord;
//   late List<LessonTitle> completeLessons;
//   late List<String> favorites;
//
//   static const String EMAIL = 'isFavorite';
//
//   Message.fromJson(Map<String, dynamic> json) {
//     messageId = json[MESSAGEID];
//     tag = json[TAG];
//     userEmail = json[USEREMAIL];
//     message = json[MESSAGE];
//     reply = json[REPLY];
//     Timestamp sendStamp = json[SENDTIME];
//     Timestamp replyStamp = json[REPLYTIME];
//     sendTime = sendStamp.toDate();
//     replyTime = replyStamp?.toDate();
//     status = json[STATUS];
//     isFavorite = json[ISFAVORITE];
//   }
//
//   Map<String, dynamic> toJson() => {
//     MESSAGEID: messageId,
//     TAG: tag,
//     USEREMAIL: userEmail,
//     MESSAGE: message,
//     REPLY: reply!,
//     SENDTIME: Timestamp.fromDate(sendTime),
//     REPLYTIME: Timestamp.fromDate(replyTime!),
//     ISFAVORITE: isFavorite,
//   };
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserCount {
  late String id;
  late DateTime date;
  late int newUsers;
  late int trial;
  late int trialEndActive;
  late int trialEndInActive;
  late int basicActive;
  late int basicInActive;
  late int premium;

  static const String ID = 'id';
  static const String DATE = 'date';
  static const String NEW_USERS = 'newUsers';
  static const String TRIAL = 'trial';
  static const String TRIAL_END_ACTIVE = 'trialEndActive';
  static const String TRIAL_END_INACTIVE = 'trialEndInActive';
  static const String BASIC_ACTIVE = 'basicActive';
  static const String BASIC_INACTIVE = 'basicInActive';
  static const String PREMIUM = 'premium';

  UserCount.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    newUsers = json[NEW_USERS];
    trial = json[TRIAL];
    trialEndActive = json[TRIAL_END_ACTIVE];
    trialEndInActive = json[TRIAL_END_INACTIVE];
    basicActive = json[BASIC_ACTIVE];
    basicInActive = json[BASIC_INACTIVE];
    premium = json[PREMIUM];
  }
}
import 'package:get/get.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonStateManager extends GetxController {

  late String radioValue;
  late bool isVideoChecked;

  @override
  void onInit() {
    radioValue = MyStrings.hangul;
    isVideoChecked = false;
  }

  void setVideoChecked(bool b) {
    isVideoChecked = b;
    update();
  }

}
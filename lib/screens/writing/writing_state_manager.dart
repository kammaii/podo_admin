import 'package:get/get.dart';
import 'package:podo_admin/screens/writing/writing.dart';

class WritingStateManager extends GetxController {

  late String tagRadio;
  List<Writing> writings = Writing().getSampleWritings(); //todo: stream 으로 구현하기

  @override
  void onInit() {
    tagRadio = '신규';
  }

  Function(String? value) changeTagRadio() {
    return (String? value) {
      tagRadio = value!;
      update();
    };
  }
}


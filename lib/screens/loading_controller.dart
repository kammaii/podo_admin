import 'package:get/get.dart';

class LoadingController extends GetxController {
  static LoadingController get to => Get.find();

  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;
  void setIsLoading(bool value) => _isLoading.value = value;
}
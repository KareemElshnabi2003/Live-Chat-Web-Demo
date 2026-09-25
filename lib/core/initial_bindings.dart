import 'package:get/get.dart';
import 'package:live_chat/core/Class/api.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Api(), permanent: true);
  }
}
import 'package:get/get.dart';
import 'package:split/controller/network_controller.dart';

class NetworkDependency {

  static void init() {
    Get.put<NetworkController>(NetworkController(),permanent:true);
  }
}
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
          snackPosition: SnackPosition.TOP,
          messageText: Text('Please Connect To The Internet',
              style: Theme.of(Get.context!).textTheme.titleMedium!.copyWith(
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontMedium,
                  fontSize: 14)),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: AppColors.white,
          borderRadius: 50,
          boxShadows: [
            BoxShadow(
                blurRadius: 2,
                spreadRadius: 2,
                offset: Offset(1, 2),
                color: AppColors.lineGrey.withOpacity(0.5))
          ],
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              Icons.wifi_off,
              color: AppColors.darkPrimaryColor,
              size: 25,
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          snackStyle: SnackStyle.GROUNDED);
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}

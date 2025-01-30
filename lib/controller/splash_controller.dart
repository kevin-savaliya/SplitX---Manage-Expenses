import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/screen/country_pick_screen.dart';
import 'package:split/screen/homescreen.dart';
import 'package:split/screen/intro_screen.dart';
import 'package:split/screen/phone_login_screen.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/utils/app_storage.dart';

class SplashController extends GetxController {
  RxBool isUpdatingData = false.obs;
  RxBool timerCompleted = false.obs;

  final AppStorage appStorage = AppStorage();


  UserController userController = Get.put(UserController());


  @override
  void onInit() {
    super.onInit();
    notificationInit();
    updateUserTokenToFirebase().then((value) {
      isUpdatingData.value = true;

      _checkNavigation();
    });

    Timer(const Duration(milliseconds: 1500), () {
      timerCompleted.value = true;
      _checkNavigation();
    });
  }
  NotificationService? notificationService ;
  notificationInit() async {
    String token = await NotificationService.getToken()!;
    log(":::::::TOKEN:::::: $token");
    notificationService?.initInfo().then((value) async {
    });
  }

  Future<void> updateUserTokenToFirebase() async {
    // if user is logged in then update token to firebase
    if (userController.firebaseUser != null) {
      print("Token Updated");
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Get.find<UserController>().loggedInUser.value!.id)
              .update({'fcmToken': token});
        } catch (e) {
          print(e);
        }
      }
      return;
    }
    return;
  }

  void _checkNavigation() {
    if (isUpdatingData.value && timerCompleted.value) {
      _redirectToNextScreen();
    }
  }

  Future<void> _redirectToNextScreen() async {
    if (appStorage.checkLoginAndUserData()) {
      await Get.offAll(() => HomeScreen());
    } else {
      if (appStorage.isBoardWatched()) {
        await Get.offAll(() => const CountryPickScreen());
      } else {
        await Get.offAll(() => const IntroScreen());
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/model/intro_model.dart';
import 'package:split/screen/country_pick_screen.dart';
import 'package:split/screen/phone_login_screen.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/assets.dart';

class IntroController extends GetxController {
  var selectedPageIndex = 0.obs;

  var pageController = PageController().obs;

  final AppStorage appStorage = AppStorage();

  List<IntroModel> introList = [
    IntroModel(
        AppImages.intro1,
        'Welcome to Hassle-Free \nGroup Expense Tracking',
        'Effortlessly manage and split group \nexpenses with friends, family, or \nroommates.'),
    IntroModel(AppImages.intro2, 'Track of Group Expenses in \nOne Place',
        'Keep a clear record of who owes \nwhat with real-time updates and \ntransparent tracking.'),
    IntroModel(
        AppImages.intro3,
        'Settle Debts with Friends \nQuickly and Easily',
        'Quick, hassle-free payments with just \na few taps.'),
  ];

  Future<void> redirectToLogin() async {
    appStorage.write(StorageKey.kIsBoardWatched, true);
    Get.offAll(() => CountryPickScreen());
  }
}

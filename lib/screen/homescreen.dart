// ignore_for_file: must_be_immutable, non_constant_identifier_names, deprecated_member_use

import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/home_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/screen/add_expense_screen.dart';
import 'package:split/screen/dashboard.dart';
import 'package:split/screen/group_screen.dart';
import 'package:split/screen/history_screen.dart';
import 'package:split/screen/profile_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  ExpenseController expenseController = Get.put(ExpenseController());
  GroupController groupController = Get.put(GroupController());

  final UserController userController = Get.find<UserController>();

  List<ContactModel> storedContacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((value) {
      fetchContactList();
    });
  }

  Future<void> fetchContactList() async {
    bool isRegistered = Get.isRegistered<AppContactServices>();
    if (isRegistered) {
      await Get.find<AppContactServices>().fetchAndStoreContacts();
    } else {
      await Get.put(AppContactServices()).fetchAndStoreContacts();
    }
    AppContactServices appContactServices = Get.find<AppContactServices>();
    if (appContactServices.appContacts.isNotEmpty) {
      storedContacts.clear();
      storedContacts.addAll(appContactServices.appContacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Home Load");
    return GetBuilder(
      id: 'PageUpdate',
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: IndexedStack(
              index: controller.pageIndex.value,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                Dashboard(),
                GroupScreen(),
                HistoryScreen(),
                ProfileScreen(),
              ]),
          resizeToAvoidBottomInset: false,
          floatingActionButton: floatingButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: bottomNavigationBar(context),
        );
      },
    );
  }

  Widget floatingButton() {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
      elevation: 0,
      onPressed: () {
        Get.to(() => AddExpenseScreen(
              isExpense: true,
            ));
      },
      backgroundColor: AppColors.primaryColor,
      child: Icon(
        Icons.add,
        size: 35,
        color: AppColors.darkPrimaryColor,
      ),
    );
  }

  Widget bottomNavigationBar(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'pageUpdate',
      init: HomeController(),
      builder: (controller) {
        return AnimatedBottomNavigationBar.builder(
          elevation: 0,
          itemCount: controller.bottomActiveIconList.length,
          borderColor: AppColors.decsGrey,
          tabBuilder: (int index, bool isActive) {
            final color =
                isActive ? AppColors.darkPrimaryColor : AppColors.inActive;

            final activeIcon = controller.bottomActiveIconList[index];
            final inactiveIcon = controller.bottomInActiveIconList[index];

            final icon = isActive ? activeIcon : inactiveIcon;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  icon,
                  color: color,
                  height: 20,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    controller.bottomLabelList[index],
                    maxLines: 1,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontFamily: AppFont.fontMedium, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
          height: 80,
          activeIndex: controller.pageIndex.value,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.sharpEdge,
          onTap: (index) {
            if (controller.pageIndex.value != index) {
              controller.pageUpdateOnHomeScreen(index);
            }
          },
          leftCornerRadius: 5,
          rightCornerRadius: 5,
        );
      },
    );
  }
}

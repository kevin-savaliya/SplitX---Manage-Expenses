// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class MyNameTextWidget extends StatelessWidget {
  final TextStyle? textStyle;

  final UserController userController = Get.find<UserController>();

  MyNameTextWidget({super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NameWidgetShimmer();
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          return Text(
            getName(user),
            textScaler: const TextScaler.linear(1),
            style: textStyle ??
                Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontBold),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  String getName(UserModel user) {
    return user.name ?? "Split User";
    // return user.name ?? "Split User";
  }
}

class MyGroupNameTextWidget extends StatelessWidget {
  final TextStyle? textStyle;

  final UserController userController = Get.find<UserController>();

  MyGroupNameTextWidget({super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          return Text(
            getName(user),
            style: textStyle ??
                Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 14,
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  String getName(UserModel user) {
    return userController.getNameByPhoneNumber(user.mobileNo!) ??
        user.name ??
        "Split User";
    // return user.name ?? "Split User";
  }
}

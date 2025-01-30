import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class MyNumberTextWidget extends StatelessWidget {
  final TextStyle? textStyle;

  final UserController userController = Get.find<UserController>();

  MyNumberTextWidget({super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NumberWidgetShimmer();
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          return Text(
            getMobileNo(user),
            textScaler: const TextScaler.linear(1),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                // decoration: TextDecoration.underline,
                fontSize: 14,
                letterSpacing: 0.5,
                color: AppColors.darkPrimaryColor,
                fontFamily: AppFont.fontRegular),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  String getMobileNo(UserModel user) {
    if (user.mobileNo == null) {
      return '';
    }
    String? mobileNo = user.mobileNo ?? '';
    return '+$mobileNo';
  }
}

class MyGroupNumberTextWidget extends StatelessWidget {
  final TextStyle? textStyle;

  final UserController userController = Get.find<UserController>();

  MyGroupNumberTextWidget({super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "000000",
            textScaler: const TextScaler.linear(1),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontSize: 13,
                color: AppColors.darkPrimaryColor,
                fontFamily: AppFont.fontRegular),
          );
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          return Text(
            "getMobileNo(user)",
            textScaler: const TextScaler.linear(1),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontSize: 13,
                color: AppColors.darkPrimaryColor,
                fontFamily: AppFont.fontRegular),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  String getMobileNo(UserModel user) {
    if (user.mobileNo == null) {
      return '';
    }

    int? countryCode = user.countryCode;
    // int? countryCode = controller.loggedInUser.value?.countryCode;
    String? mobileNo = user.mobileNo ?? '';
    // String? mobileNo = controller.loggedInUser.value?.mobileNo ?? '';
    return '+${countryCode ?? ''} $mobileNo';
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/assets.dart';

class MyProfileWidget extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  MyProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (snapshot.hasData &&
            snapshot.data!.profilePicture != null &&
            snapshot.data!.profilePicture != "") {
          UserModel user = snapshot.data!;
          return CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                imageUrl: user.profilePicture!,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  height: 55,
                  width: 55,
                  child: Center(
                      child: LoadingIndicator(
                    colors: [AppColors.primaryColor],
                    indicatorType: Indicator.ballScale,
                    strokeWidth: 1,
                  )),
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: CircleAvatar(
              backgroundColor: AppColors.darkPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: SvgPicture.asset(AppImages.split_logo),
              ),
            ),
          );
        }
      },
    );
  }
}

class MyGroupProfileWidget extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  MyGroupProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
          );
        } else if (snapshot.hasData &&
            snapshot.data!.profilePicture != null &&
            snapshot.data!.profilePicture != "") {
          UserModel user = snapshot.data!;
          return CircleAvatar(
            backgroundColor: AppColors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                height: 40,
                width: 40,
                imageUrl: user.profilePicture!,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                      child: LoadingIndicator(
                    colors: [AppColors.primaryColor],
                    indicatorType: Indicator.ballScale,
                    strokeWidth: 1,
                  )),
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return CircleAvatar(
            backgroundColor: AppColors.darkPrimaryColor,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SvgPicture.asset(AppImages.split_logo),
            ),
          );
        }
      },
    );
  }
}

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

class OtherProfileWidget extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  final String otherUserId;

  OtherProfileWidget({super.key, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamOtherUser(otherUserId),
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
          return CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ClipOval(
                child: CircleAvatar(
                  backgroundColor: AppColors.darkPrimaryColor,
                  child: Container(
                    height: 55,
                    width: 55,
                    child: SvgPicture.asset(AppImages.split_logo),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

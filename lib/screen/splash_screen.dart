import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/splash_controller.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.darkPrimaryColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AppImages.split_logo, height: 60),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  ConstString.SplitX,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryColor,
                      fontSize: 17,
                      fontFamily: AppFont.fontSemiBold),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

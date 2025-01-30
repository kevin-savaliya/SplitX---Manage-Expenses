// ignore_for_file: must_be_immutable

// import 'package:country_calling_code_picker/picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/custom_loading_widget.dart';

class PhoneLoginScreen extends StatelessWidget {
  String? countryCode;
  String? countryFlag;

  PhoneLoginScreen({super.key, this.countryCode, this.countryFlag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) {
        controller.openCountryPickerDialog(countryCode!);
        return WillPopScope(
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  controller.phoneNumberController.clear();
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SvgPicture.asset(
                    AppIcons.back_icon,
                  ),
                ),
              ),
              elevation: 0,
              backgroundColor: AppColors.white,
            ),
            body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Center(
                      //     child: Container(
                      //         color: Colors.black12,
                      //         child: Lottie.asset("asset/login_animation.json",
                      //             height: 200, fit: BoxFit.cover))),
                      Text(ConstString.welcomeBack,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              fontSize: 18, fontFamily: AppFont.fontSemiBold)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(ConstString.loginSentance,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(color: AppColors.dark, height: 1.3)),
                      const SizedBox(height: 30),
                      Text(ConstString.mobileNumber,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              color: AppColors.darkPrimaryColor, fontSize: 14)),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.decsGrey),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "$countryFlag",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                        fontFamily: AppFont.fontRegular,
                                        fontSize: 18,
                                        color: AppColors.darkPrimaryColor),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 1.5,
                                    color: AppColors.txtGrey.withOpacity(0.4),
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  Text(
                                    "+$countryCode",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                        fontFamily: AppFont.fontRegular,
                                        fontSize: 15,
                                        color: AppColors.txtGrey),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 12,
                                child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                        textScaler: const TextScaler.linear(1)),
                                    child: TextField(
                                        cursorColor: AppColors.dark,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                            letterSpacing: 1,
                                            fontFamily: AppFont.fontRegular,
                                            fontSize: 16,
                                            color: AppColors.darkPrimaryColor),
                                        keyboardType: TextInputType.phone,
                                        controller:
                                        controller.phoneNumberController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                          const EdgeInsets.only(bottom: 5),
                                          hintText: ConstString.enterMobile,
                                          hintStyle: TextStyle(
                                              fontFamily: AppFont.fontRegular,
                                              color: AppColors.txtGrey,
                                              letterSpacing: 0,
                                              fontSize: 14),
                                          border: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder:
                                          const UnderlineInputBorder(),
                                        )))),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      sendOtpButton(context)
                    ],
                  ),
                )),
          ),
          onWillPop: () async {
            controller.phoneNumberController.clear();
            Get.back();
            return true;
          },
        );
      },
    );
  }

  GetBuilder<AuthController> sendOtpButton(BuildContext context) {
    return GetBuilder<AuthController>(
      id: AuthController.continueButtonId,
      builder: (controller) {
        if (controller.isOtpSent.value) {
          return Center(
            child: Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: const CustomLoadingWidget()),
          );
        }
        return Align(
          alignment: Alignment.center,
          child: ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                await controller.actionVerifyPhone(context,
                    isLogin: true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  fixedSize: const Size(200, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                ConstString.sendOtp,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
              )),
        );
      },
    );
  }
}

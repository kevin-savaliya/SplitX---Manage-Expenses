import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/controller/otp_verify_controller.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/custom_loading_widget.dart';

class OtpVerifyScreen extends GetWidget<OPTVerifyController> {
  final String phoneNumber;
  final String verificationId;

  OtpVerifyScreen(
      {super.key, required this.phoneNumber, required this.verificationId});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OPTVerifyController>(
        init: OPTVerifyController(
            phoneNumber: phoneNumber, verificationId: verificationId),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SvgPicture.asset(
                    AppIcons.back_icon,
                  ),
                ),
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ConstString.enterOTP,
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 18, fontFamily: AppFont.fontSemiBold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(ConstString.otpSentance,
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(color: AppColors.dark, height: 1.3)),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1)),
                        child: PinCodeTextField(
                          controller: controller.otpController,
                          onCompleted: (value) async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (controller.otpAttempts.value == 0) {
                              await controller.verifyOtp(context, value);
                            }
                            controller.otpAttempts.value++;
                          },
                          appContext: context,
                          length: 6,
                          animationType: AnimationType.none,
                          blinkWhenObscuring: true,
                          hintCharacter: "-",
                          hintStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontFamily: AppFont.fontRegular,
                                  color: AppColors.darkPrimaryColor
                                      .withOpacity(0.3)),
                          cursorColor: AppColors.txtGrey.withOpacity(0.5),
                          keyboardType: TextInputType.number,
                          textStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontFamily: AppFont.fontRegular,
                                  color: AppColors.darkPrimaryColor),
                          pastedTextStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontFamily: AppFont.fontRegular,
                                  color: AppColors.darkPrimaryColor),
                          pinTheme: PinTheme(
                              fieldWidth: 45,
                              borderRadius: BorderRadius.circular(30),
                              selectedColor: AppColors.txtGrey.withOpacity(0.5),
                              activeColor: AppColors.decsGrey,
                              inactiveColor: AppColors.txtGrey.withOpacity(0.2),
                              activeFillColor: AppColors.decsGrey,
                              shape: PinCodeFieldShape.box),
                        )),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppIcons.timer_icon),
                      const SizedBox(
                        width: 5,
                      ),
                      GetBuilder<AuthController>(
                          id: 'timer',
                          builder: (ctrl) {
                            return Visibility(
                                visible: ctrl.start.value != 0,
                                child: Center(
                                    child: Obx(() => Text(
                                        "${ctrl.start.value}${ctrl.start.value == 1 ? '' : ' Sec'}",
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontFamily: AppFont.fontMedium,
                                                fontSize: 14)))));
                          }),
                      TextButton(
                          onPressed: () async {
                            await controller.verifyPhoneNumber(context);
                          },
                          child: Text(
                            ConstString.resentIt,
                            textScaler: const TextScaler.linear(1),
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFont.fontMedium,
                                textBaseline: TextBaseline.alphabetic,
                                decoration: TextDecoration.underline,
                                color: AppColors.red2),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() => controller.isOtpLoading.value
                      ? Center(
                          child: Container(
                              height: 50,
                              width: 50,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: const CustomLoadingWidget()),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () async {
                                if (controller.otpController.text.isEmpty) {
                                  showInSnackBar(
                                    context,
                                    ConstString.enterOtp,
                                    title: ConstString.enterOtpMessage,
                                  );
                                  return;
                                }
                                controller.isOtpLoading.value = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                                await controller.verifyOtp(context,
                                    controller.otpController.text.trim());
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  fixedSize: const Size(200, 50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: Text(
                                ConstString.btnContinue,
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                        color: AppColors.darkPrimaryColor,
                                        fontFamily: AppFont.fontMedium),
                              )),
                        ))
                ],
              ),
            )),
          );
        });
  }
}

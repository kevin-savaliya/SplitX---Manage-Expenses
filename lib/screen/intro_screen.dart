import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/intro_controller.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroController>(
      init: IntroController(),
      builder: (controller) {
        return Obx(() => Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Container(
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: controller.selectedPageIndex.value == 0
                      ? AppColors.intro1
                      : controller.selectedPageIndex.value == 1
                          ? AppColors.intro2
                          : controller.selectedPageIndex.value == 2
                              ? AppColors.intro3
                              : AppColors.intro1,
                ),
                Positioned(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: PageView.builder(
                          allowImplicitScrolling: true,
                          controller: controller.pageController.value,
                          onPageChanged: (value) =>
                              onPageChanged(controller, value),
                          itemCount: controller.introList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.introList[index].title!,
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                                fontFamily:
                                                    AppFont.fontSemiBold,
                                                height: 1.3,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        controller
                                            .introList[index].description!,
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                                height: 1.4,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 80,
                                      ),
                                      SizedBox(
                                        height: 180,
                                        child: Image.asset(
                                            controller.introList[index].image!),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0;
                                  i < controller.introList.length;
                                  i++)
                                controller.selectedPageIndex.value == i
                                    ? Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: 6,
                                          width: 25,
                                          decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: ClipOval(
                                          child: Container(
                                            height: 6,
                                            width: 6,
                                            color: AppColors.whiteTransparent,
                                          ),
                                        ),
                                      )
                            ],
                          )),
                      const SizedBox(height: 40),
                      ElevatedButton(
                          onPressed: () async {
                            if (controller.selectedPageIndex.value == 0) {
                              controller.pageController.value.animateToPage(1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            } else if (controller.selectedPageIndex.value ==
                                1) {
                              controller.pageController.value.animateToPage(2,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            } else {
                              await controller.redirectToLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.selectedPageIndex.value == 2
                                      ? AppColors.primaryColor
                                      : AppColors.darkPrimaryColor,
                              fixedSize: const Size(200, 50),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Text(
                            controller.selectedPageIndex.value == 2
                                ? ConstString.login
                                : ConstString.next,
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    color:
                                        controller.selectedPageIndex.value == 2
                                            ? AppColors.darkPrimaryColor
                                            : AppColors.primaryColor,
                                    fontFamily: AppFont.fontMedium),
                          )),
                      Obx(() => Opacity(
                            opacity:
                                controller.selectedPageIndex.value == 2 ? 0 : 1,
                            child: TextButton(
                                onPressed: () async {
                                  await controller.redirectToLogin();
                                },
                                child: Text(
                                  "Skip",
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                          fontSize: 14,
                                          color: AppColors.darkPrimaryColor),
                                )),
                          )),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                Positioned(
                    height: 50,
                    top: Get.mediaQuery.padding.top,
                    child: Obx(() => Visibility(
                        visible: controller.selectedPageIndex.value != 0,
                        child: IconButton(
                          onPressed: () {
                            if (controller.selectedPageIndex.value == 1) {
                              controller.pageController.value.animateToPage(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            } else if (controller.selectedPageIndex.value ==
                                2) {
                              controller.pageController.value.animateToPage(1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            } else if (controller.selectedPageIndex.value ==
                                3) {
                              controller.pageController.value.animateToPage(2,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            }
                          },
                          icon: SvgPicture.asset(
                            AppIcons.back_icon_ios,
                          ),
                        )))),
              ],
            )));
      },
    );
  }

  void onPageChanged(IntroController controller, int? value) {
    controller.selectedPageIndex.value = value ?? 0;
  }
}

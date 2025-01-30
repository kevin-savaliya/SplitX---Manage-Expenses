import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/controller/pick_image_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';

Future editGroupDialogue(BuildContext context, GroupDataModel groupDataModel) {
  PickImageController pickController = Get.put(PickImageController());

  GroupDataModel? groupData;

  groupData = groupDataModel;

  pickController.groupNameController.text = groupData.name ?? '';

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return SimpleDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ConstString.editGroup,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(Get.context!)
                        .textTheme
                        .titleLarge!
                        .copyWith(
                            fontFamily: AppFont.fontSemiBold, fontSize: 15),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.darkPrimaryColor,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: Obx(() => Stack(
                  children: [
                    pickController.selectedGroupProfileImage.isEmpty
                        ? ClipOval(
                            child: Container(
                                height: 70,
                                width: 70,
                                color: AppColors.darkPrimaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SvgPicture.asset(
                                    AppImages.split_logo,
                                  ),
                                )))
                        : SizedBox(
                            height: 70,
                            width: 70,
                            child: ClipOval(
                              child: Image.file(
                                File(pickController.selectedGroupProfileImage),
                                fit: BoxFit.cover,
                              ),
                            )),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                            onTap: () {
                              pickController.pickGroupImage(context);
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  border: Border.all(
                                      color: AppColors.white, width: 1),
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SvgPicture.asset(
                                  AppIcons.editPenIcon,
                                  height: 10,
                                ),
                              ),
                            )))
                  ],
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.groupName,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: pickController.groupNameController,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.darkPrimaryColor, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        hintText: "Enter Group Name",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        prefixIcon: SizedBox(
                            height: 10,
                            width: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                AppIcons.groupIcon,
                                color: AppColors.darkPrimaryColor,
                              ),
                            )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20)),
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: ElevatedButton(
                  onPressed: () async {
                    String name =
                        pickController.groupNameController.text.trim();
                    String groupId = groupData!.id!;

                    Map<String, dynamic> updateData = {};

                    if (name.isNotEmpty && name != groupData.name) {
                      updateData['name'] = name;
                    }

                    if (pickController.selectedGroupProfileImage.isNotEmpty) {
                      showProgressDialogue(context);
                      final ref = FirebaseStorage.instance
                          .ref('group_profiles/$groupId');
                      final picFile =
                          File(pickController.selectedGroupProfileImage);

                      if (await picFile.exists()) {
                        UploadTask uploadTask = ref.putFile(picFile);
                        await Future.value(uploadTask).then((value) async {
                          var newUrl = await ref.getDownloadURL();
                          updateData['groupProfile'] = newUrl.toString();
                        }).onError((error, stackTrace) {
                          showInSnackBar(context, "$error", isSuccess: false);
                        });
                      }
                    }

                    if (updateData.isNotEmpty) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('groups')
                            .doc(groupId)
                            .update(updateData)
                            .then((value) {
                          Get.find<UserController>();
                          Get.back();
                          Get.back();
                          showInSnackBar(
                              context, "Group data edited successfully",
                              isSuccess: true, title: "Split");
                          pickController.userNameController.clear();
                          pickController.selectedUserProfileImage = "";
                        }).onError((error, stackTrace) {
                          showInSnackBar(context, "$error", isSuccess: false);
                        });
                      } catch (e) {
                        debugPrint("Exception Thrown : $e");
                      }
                    } else {
                      showInSnackBar(context, "No changes to update!",
                          isSuccess: false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      fixedSize: const Size(50, 45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Text(
                    ConstString.save,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(Get.context!)
                        .textTheme
                        .displayMedium!
                        .copyWith(
                          color: AppColors.darkPrimaryColor,
                        ),
                  )),
            ),
          )
        ],
      );
    },
  );
}

Future showProgressDialogue(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                height: 70,
                width: 70,
                child: LoadingIndicator(
                  colors: [AppColors.primaryColor],
                  indicatorType: Indicator.ballScale,
                  strokeWidth: 1,
                ),
              )),
              // const SizedBox(
              //   height: 20,
              // ),
              // Text(
              //   "Loading...",
              //   style: Theme.of(context)
              //       .textTheme
              //       .titleMedium!
              //       .copyWith(fontFamily: AppFont.fontMedium,fontSize: 16),
              // )
            ],
          )),
        ],
      );
    },
  );
}

Future logoutDialogue(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: AppColors.white,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        title: Column(
          children: [
            Text(
              ConstString.logoutDialogue,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontBold,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Are you sure you want to logout?",
                textScaler: const TextScaler.linear(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 14, color: AppColors.txtGrey, letterSpacing: 0),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.indGrey.withOpacity(0.5),
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.cancle,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: AppColors.txtGrey, fontSize: 14),
                      )),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        showProgressDialogue(context);
                        await AuthController.signOut();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimaryColor,
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.logoutDialogue,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: AppColors.white, fontSize: 14),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Future deleteExpenseDialogue(BuildContext context, VoidCallback onTap) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: AppColors.white,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        title: Column(
          children: [
            Text(
              ConstString.deleteExpense,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontSemiBold,
                  ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Are you sure you want to delete \nthis expense data?",
                textScaler: const TextScaler.linear(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    height: 1.4,
                    fontSize: 14,
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        showProgressDialogue(context);
                        onTap();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.debit,
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.YesDialogue,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.white,
                            fontSize: 14,
                            fontFamily: AppFont.fontMedium),
                      )),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.borderGrey,
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.NoDialogue,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontMedium),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Future leaveGroupDialogue(BuildContext context, VoidCallback onTap,
    {double payableAmount = 0}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: EdgeInsets.zero,
        backgroundColor: AppColors.white,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ConstString.leaveGroup,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(Get.context!)
                        .textTheme
                        .titleLarge!
                        .copyWith(
                            fontFamily: AppFont.fontSemiBold, fontSize: 15),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.darkPrimaryColor,
                    size: 20,
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Clear All Debts Before Leaving the \nGroup",
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  height: 1.4,
                  fontSize: 15,
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontSemiBold),
            ),
            const SizedBox(height: 10),
            Text(
              "Please settle any outstanding debts in this group before leaving. This ensures fairness for all members. Thank you for your prompt action and understanding.",
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  height: 1.4,
                  fontSize: 13,
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontRegular),
            ),
            const SizedBox(height: 20),
            payableAmount != 0
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                fixedSize: const Size(200, 45),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: Text(
                              "Ok",
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontSize: 14,
                                      fontFamily: AppFont.fontMedium),
                            )),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () async {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.decsGrey,
                                fixedSize: const Size(200, 45),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: Text(
                              ConstString.NoDialogue,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontSize: 14,
                                      fontFamily: AppFont.fontMedium),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              showProgressDialogue(context);
                              onTap();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                fixedSize: const Size(200, 45),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: Text(
                              ConstString.YesDialogue,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontSize: 14,
                                      fontFamily: AppFont.fontMedium),
                            )),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Future deleteGroupDialogue(BuildContext context, VoidCallback onTap) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        contentPadding: EdgeInsets.zero,
        backgroundColor: AppColors.white,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ConstString.deleteAccount,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(Get.context!)
                        .textTheme
                        .titleLarge!
                        .copyWith(
                            fontFamily: AppFont.fontSemiBold, fontSize: 15),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.darkPrimaryColor,
                    size: 20,
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Are you absolutely sure you want to \nclose your SplitX account?",
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  height: 1.4,
                  fontSize: 15,
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontSemiBold),
            ),
            const SizedBox(height: 10),
            Text(
              "You will no longer be able to access your \naccount history or data from the SplitX \napp.",
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  height: 1.4,
                  fontSize: 13,
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontRegular),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.decsGrey,
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.cancle,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontMedium),
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        showProgressDialogue(context);
                        onTap();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          fixedSize: const Size(200, 45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.ConfirmDialogue,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontMedium),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

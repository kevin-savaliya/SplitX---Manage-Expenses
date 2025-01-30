// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/controller/pick_image_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/controller/user_repository.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/contact_us.dart';
import 'package:split/screen/privacy_policy.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/app_dialogue.dart';
import 'package:split/widgets/user/my_name_text_widget.dart';
import 'package:split/widgets/user/my_number_text_widget.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController controller = Get.put(AuthController());

  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ConstString.myProfile,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 22,
                  fontFamily: AppFont.fontSemiBold,
                  color: AppColors.darkPrimaryColor),
            ),
            Text(
              ConstString.profileTitle,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontFamily: AppFont.fontRegular,
                  fontSize: 12,
                  color: AppColors.darkPrimaryColor),
            ),
          ],
        ),
      ),
      body: profileWidget(context),
    );
  }

  Widget profileWidget(BuildContext context) {
    return StreamBuilder(
      stream: userController.streamUser(userController.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CupertinoActivityIndicator(
            color: AppColors.darkPrimaryColor,
            radius: 12,
          ));
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        UserProfileWidget(
                            size: const Size(110, 110),
                            userData: user,
                            name: user.name),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                                onTap: () async {
                                  await editUserProfileDialogue(context, user,
                                      () {
                                    userController.update();
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    border: Border.all(
                                        color: AppColors.white, width: 3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AppIcons.penFillIcon,
                                      height: 15,
                                    ),
                                  ),
                                )))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyNameTextWidget(),
                  const SizedBox(
                    height: 3,
                  ),
                  MyNumberTextWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            width: 1, color: AppColors.darkPrimaryColor)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () async {},
                            horizontalTitleGap: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.decsGrey),
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: SvgPicture.asset(
                                  AppIcons.feedbackIcon,
                                  color: AppColors.darkPrimaryColor,
                                ),
                              ),
                            ),
                            title: Text(
                              ConstString.feedback,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkPrimaryColor,
                                  ),
                            ),
                            trailing: SvgPicture.asset(
                              AppIcons.arrow_right,
                              color: AppColors.darkPrimaryColor,
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: AppColors.txtGrey.withOpacity(0.2),
                            height: 7,
                          ),
                          ListTile(
                            onTap: () {
                              // Get.to(() => const ContactUs());
                            },
                            horizontalTitleGap: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.decsGrey),
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: SvgPicture.asset(
                                  AppIcons.contactUsIcon,
                                  color: AppColors.darkPrimaryColor,
                                ),
                              ),
                            ),
                            title: Text(
                              ConstString.contactUs,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkPrimaryColor,
                                  ),
                            ),
                            trailing: SvgPicture.asset(
                              AppIcons.arrow_right,
                              color: AppColors.darkPrimaryColor,
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: AppColors.txtGrey.withOpacity(0.2),
                            height: 7,
                          ),
                          ListTile(
                            onTap: () {
                              // Get.to(() => const PrivacyPolicy());
                            },
                            horizontalTitleGap: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.decsGrey),
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: SvgPicture.asset(
                                  AppIcons.contactUsIcon,
                                  color: AppColors.darkPrimaryColor,
                                ),
                              ),
                            ),
                            title: Text(
                              ConstString.privacyPolicy,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkPrimaryColor,
                                  ),
                            ),
                            trailing: SvgPicture.asset(
                              AppIcons.arrow_right,
                              color: AppColors.darkPrimaryColor,
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: AppColors.txtGrey.withOpacity(0.2),
                            height: 7,
                          ),
                          ListTile(
                            onTap: () {
                              logoutDialogue(context);
                            },
                            horizontalTitleGap: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tileRed),
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: SvgPicture.asset(
                                  AppIcons.logoutIcon,
                                  color: AppColors.debit,
                                ),
                              ),
                            ),
                            title: Text(
                              ConstString.logout,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.debit,
                                  ),
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: AppColors.txtGrey.withOpacity(0.2),
                            height: 7,
                          ),
                          ListTile(
                            onTap: () {
                              deleteGroupDialogue(context, () {
                                userController.deleteUserData(
                                    context, user.mobileNo!); //LW //Tr
                              });
                            },
                            horizontalTitleGap: 10,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tileRed),
                              height: 40,
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  AppIcons.deleteIcon,
                                  color: AppColors.debit,
                                ),
                              ),
                            ),
                            title: Text(
                              ConstString.deleteAccount,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.debit,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Future editUserProfileDialogue(
    BuildContext context,
    UserModel user,
    Function() onSaveSuccess,
  ) {
    PickImageController pickController = Get.put(PickImageController());

    UserModel? userModel;

    userModel = user;

    pickController.userNameController.text = userModel.name ?? '';
    pickController.selectedAvatarId.value = userModel.avatarId ?? '';
    pickController.selectedUserProfileImage = userModel.profilePicture ?? '';
    pickController.update();

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      ConstString.editUser,
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
              child: SizedBox(
                  height: 75,
                  width: 75,
                  child: getProfilePic(pickController, user, context)),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ConstString.enterName,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontRegular,
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
                      controller: pickController.userNameController,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.darkPrimaryColor, fontSize: 14),
                      cursorColor: AppColors.txtGrey,
                      decoration: InputDecoration(
                          hintText: "Enter Name",
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
                              borderSide:
                                  BorderSide(color: AppColors.decsGrey)),
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
                          pickController.userNameController.text.trim();
                      String userid = FirebaseAuth.instance.currentUser!.uid;

                      Map<String, dynamic> updateData = {};

                      if (name.isNotEmpty && name != userModel!.name) {
                        updateData['name'] = name;
                      }

                      // Check if a profile image is selected
                      if (pickController.selectedUserProfileImage.isNotEmpty) {
                        pickController.selectedAvatarId.value = "";
                        showProgressDialogue(context);
                        final ref =
                            FirebaseStorage.instance.ref('profiles/$userid');
                        final picFile =
                            File(pickController.selectedUserProfileImage);

                        if (await picFile.exists()) {
                          UploadTask uploadTask = ref.putFile(picFile);
                          await Future.value(uploadTask).then((value) async {
                            var newUrl = await ref.getDownloadURL();
                            updateData['profilePicture'] = newUrl.toString();
                            updateData['avatarId'] =
                                ""; // Set avatarId to null when a profile image is selected
                          }).onError((error, stackTrace) {
                            showInSnackBar(context, "$error", isSuccess: false);
                          });
                        }
                      } else if (pickController.selectedAvatarId.isNotEmpty) {
                        // If an avatar is selected, set the avatarId
                        updateData['avatarId'] =
                            pickController.selectedAvatarId.value;
                        updateData['profilePicture'] = "";
                      } else {
                        updateData['avatarId'] = "";
                      }

                      if (updateData.isNotEmpty) {
                        try {
                          /// if userModel!.profilePicture is not same as updateData['profilePicture'] then delete the old image
                          // if (userModel!.profilePicture != null &&
                          //     userModel.profilePicture !=
                          //         updateData['profilePicture']) {
                          //   if (userModel.profilePicture!.startsWith('http')) {
                          //     await FirebaseStorage.instance
                          //         .refFromURL(userModel.profilePicture!)
                          //         .delete();
                          //   }
                          // }
                          await UserRepository.instance
                              .updateUser(userModel!.copyWith(
                            id: userid,
                            name: updateData['name'],
                            profilePicture: updateData['profilePicture'],
                            avatarId: updateData['avatarId'],
                          ))
                              .then((value) {
                            Get.find<UserController>();
                            Get.back();
                            Get.back();
                            showInSnackBar(
                                context, "Profile data edited successfully",
                                isSuccess: true, title: "Split");
                            pickController.userNameController.clear();
                            pickController.selectedUserProfileImage = "";
                            pickController.selectedAvatarId.value = "";
                            onSaveSuccess();
                            pickController.update();
                            userController.update();
                          }).onError((error, stackTrace) {
                            showInSnackBar(context, "$error", isSuccess: false);
                          });
                        } catch (e) {
                          Get.back();
                          debugPrint("Exception Thrown : $e");
                        }
                      } else {
                        Get.back();
                        Get.back();
                        // showInSnackBar(context, "No changes to update!",
                        //     isSuccess: false);
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

  Obx getProfilePic(PickImageController pickController, UserModel user,
      BuildContext context) {
    return Obx(() => Stack(
          children: [
            pickController.selectedAvatarId.value.isNotEmpty
                ? Container(
                    height: 70,
                    width: 70,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Image.asset(
                      AppImages.avtar(pickController.selectedAvatarId.value),
                      height: 70,
                      width: 70,
                    ),
                  )
                : pickController.selectedUserProfileImage.isEmpty
                    ? UserProfileWidget(
                        size: const Size(70, 70),
                        userData: user,
                        name: user.name)
                    : Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(color: AppColors.white, width: 1),
                        ),
                        child: ClipOval(
                          child: pickController.selectedUserProfileImage
                                  .startsWith('https')
                              ? CachedNetworkImage(
                                  imageUrl:
                                      pickController.selectedUserProfileImage,
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return Icon(Icons.error);
                                  },
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                            child: CircularProgressIndicator(
                                              value: downloadProgress.progress,
                                              color: AppColors.primaryColor,
                                            ),
                                          ))
                              : Image.file(
                                  File(pickController.selectedUserProfileImage),
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                ),
                        )),
            Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                    onTap: () {
                      pickController.pickUserImage(context);
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          border: Border.all(color: AppColors.white, width: 1),
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
        ));
  }
}

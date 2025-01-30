// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/pick_image_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/group_details.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/app_dialogue.dart';

class CreateNewGroup extends StatelessWidget {
  final Set<ContactModel>? selectedContact;

  CreateNewGroup({super.key, this.selectedContact});

  // HomeController homeController = Get.find<HomeController>();
  final PickImageController pickController = Get.put(PickImageController());
  final GroupController controller = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 1,
        shadowColor: AppColors.decsGrey.withOpacity(0.5),
        backgroundColor: AppColors.white,
        centerTitle: false,
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
        titleSpacing: -10,
        title: Text(
          ConstString.namegroup,
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: groupWidget(context),
    );
  }

  Widget groupWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Obx(() => Stack(
                    children: [
                      pickController.selectedGroupProfileImage.isEmpty
                          ? CircleAvatar(
                              child: SvgPicture.asset(AppImages.split_logo,
                                  height: 40),
                              radius: 40,
                              backgroundColor: Colors.black,
                            )
                          // ? CustomGroupAvtarWidget(
                          //     size: const Size(160, 160),
                          //     userMobileList: const [
                          //       "?",
                          //       "?",
                          //       "?",
                          //     ],
                          //   )
                          : SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipOval(
                                child: Image.file(
                                  File(
                                      pickController.selectedGroupProfileImage),
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
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    border: Border.all(
                                        color: AppColors.white, width: 3),
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    AppIcons.penFillIcon,
                                    height: 15,
                                  ),
                                ),
                              )))
                    ],
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.groupName,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: controller.groupNameController,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.txtGrey, fontSize: 14),
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
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.estimategroup,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.number,
                    controller: controller.groupBudgetController,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.txtGrey, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        hintText: "Enter Estimate Group Budget",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
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
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  String userId = FirebaseAuth.instance.currentUser!.uid;

                  String groupId = controller.groupRef.doc().id;
                  var groupImageUrl;

                  String? userMobileNo =
                      await controller.fetchUserMobileNumber(userId);

                  List<Map<String, String>> memberIds = [];

                  for (ContactModel contact in selectedContact!) {
                    if (contact.contactNumber != null &&
                        contact.contactNumber!.isNotEmpty) {
                      final phoneNumber = contact.contactNumber ?? '';
                      String sanitizedPhoneNumber =
                          phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
                      final contactName = contact.contactName ?? 'SplitX User';

                      // await FirebaseFirestore.instance
                      //     .collection('users')
                      //     .where('mobileNo', isEqualTo: sanitizedPhoneNumber)
                      //     .get()
                      //     .then(
                      //   (value) {
                      //     print('Test == ${value.docs}');
                      //     List<UserModel> temp = value.docs
                      //         .map((doc) => UserModel.fromMap(
                      //             doc.data() as Map<String, dynamic>))
                      //         .toList();
                      //     temp.forEach((element) {
                      //       print('${element.fcmToken}');
                      //       controller.fcmTokan = element.fcmToken ?? '';
                      //       controller.customerId = element.id!;
                      //
                      //       print('customerId---->${controller.customerId}');
                      //     });
                      //   },
                      // );
                      memberIds.add({
                        'name': contactName,
                        'mobileNo': sanitizedPhoneNumber,
                        'addedTime': "${DateTime.now()}",
                        'fcmToken': controller.fcmTokan,
                        'id': '${controller.customerId}'
                      });
                    }
                  }

                  memberIds.insert(0, {
                    'name': "${controller.loggedInUser!.name}",
                    'mobileNo': userMobileNo ?? "",
                    'fcmToken': '${controller.userDataModel?.fcmToken}',
                    'addedTime': "${DateTime.now()}",
                    'id': controller.currentUserId
                  });

                  if (controller.validateData(context)) {
                    if (int.parse(controller.groupBudgetController.text) > 0) {
                      showProgressDialogue(context);

                      if (pickController.selectedGroupProfileImage.isNotEmpty) {
                        final ref = FirebaseStorage.instance
                            .ref('group_profiles/$groupId');
                        final picFile =
                            File(pickController.selectedGroupProfileImage);

                        if (await picFile.exists()) {
                          UploadTask uploadTask = ref.putFile(picFile);
                          await Future.value(uploadTask).then((value) async {
                            groupImageUrl = await ref.getDownloadURL();
                          }).onError((error, stackTrace) {
                            showInSnackBar(context, "$error", isSuccess: false);
                          });
                        }
                      }

                      List<GroupMember> groupMembers = memberIds
                          .map((e) => GroupMember(
                                user: UserModel.newUser(
                                    fcmToken: e['fcmToken'],
                                    id: e['id'],
                                    mobileNo: e['mobileNo'],
                                    name: e['name'],
                                    createdAt: DateTime.parse(e['addedTime']!)),
                                status: 'active',
                              ))
                          .toList();

                      GroupDataModel groupData = GroupDataModel(
                          id: groupId,
                          name: controller.groupNameController.text.trim(),
                          description: "",
                          budget: controller.groupBudgetController.text.trim(),
                          groupProfile: groupImageUrl,
                          memberIds: groupMembers,
                          adminIds: [
                            GroupMember(
                                user: UserModel.newUser(
                                    mobileNo: userMobileNo,
                                    id: controller.userDataModel?.id,
                                    fcmToken:
                                        controller.userDataModel?.fcmToken))
                          ],
                          createdAt: DateTime.now());

                      await controller
                          .createGroup(groupData)
                          .then((value) async {
                        Get.back();
                        Get.back();
                        Get.off(() => GroupDetails(
                              groupData: groupData,
                            ));
                        // await FirebaseFirestore.instance
                        //     .collection('groups')
                        //     .where('id', isEqualTo: groupId)
                        //     .get()
                        //     .then(
                        //   (value) {
                        //     print('New Group Test == ${value.docs}');
                        //     List<GroupDataModel> temp = value.docs
                        //         .map((doc) => GroupDataModel.fromMap(
                        //             doc.data() as Map<String, dynamic>))
                        //         .toList();
                        //     temp.forEach((element) {
                        //       for (GroupMember member in element.memberIds!) {
                        //         controller.newGroupFcmTokenList
                        //             .add(member.user.fcmToken ?? "");
                        //         controller.newGroupCustomerIdList
                        //             .add(member.user.id ?? "");
                        //       }
                        //     });
                        //     print(
                        //         '---newGroupFcmTokenList--->${controller.newGroupFcmTokenList.length}');
                        //     print(
                        //         '---newGroupCustomerIdList--->${controller.newGroupCustomerIdList.length}');
                        //   },
                        // );

                        // print('-------->create_group');

                        // await NotificationService.sendMultipleNotifications(
                        //   senderId: '${controller.userDataModel?.id}',
                        //   title:
                        //       '${controller.userDataModel?.name} created the group ${controller.groupNameController.text}.',
                        //   body: '',
                        //   type: 'create_group',
                        //   tokens: controller.newGroupFcmTokenList,
                        //   groupId: groupId,
                        //   customerIdList: controller.newGroupCustomerIdList,
                        // );

                        controller.newGroupFcmTokenList.clear();
                        controller.newGroupCustomerIdList.clear();

                        controller.groupNameController.clear();
                        controller.groupBudgetController.clear();
                        pickController.selectedGroupProfileImage = "";
                        controller.selectedContacts.clear();
                        //TODO: Send Notification of Create Group
                      });
                    } else {
                      showInSnackBar(
                          context, "Please enter valid group budget");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    fixedSize: const Size(200, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: Text(
                  ConstString.create,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontMedium),
                )),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${selectedContact!.length + 1} Members",
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontSize: 14,
                    fontFamily: AppFont.fontSemiBold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              "Y",
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontFamily: AppFont.fontSemiBold,
                                      fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              "You",
                              textScaler: const TextScaler.linear(1),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppFont.fontRegular,
                                      fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: selectedContact!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          List<ContactModel> contactList =
                              selectedContact!.toList();
                          ContactModel selected = contactList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primaryColor,
                                  child: Text(
                                    selected.contactName != null
                                        ? String.fromCharCodes(selected
                                                .contactName!.runes
                                                .take(1))
                                            .toUpperCase()
                                        : "?",
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontSemiBold,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    selected.contactName!,
                                    textScaler: const TextScaler.linear(1),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: AppColors.darkPrimaryColor,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: AppFont.fontRegular,
                                            fontSize: 13),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
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
  }
}

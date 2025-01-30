// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/screen/add_contact_screen.dart';
import 'package:split/screen/add_member_screen.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/app_dialogue.dart';
import 'package:split/widgets/user/my_number_text_widget.dart';

class GroupSetting extends StatelessWidget {
  final GroupDataModel? groupData;

  double payableAmount = 0;

  GroupSetting({super.key, this.groupData});

  ExpenseController expenseController = Get.find<ExpenseController>();
  GroupController controller = Get.find<GroupController>();
  final UserController userController = Get.find<UserController>();

  final List taskList = [
    "Add Member",
    "Invite Link",
    "Leave Group",
    "Delete Group"
  ];

  final List iconList = [
    AppIcons.addIcon,
    AppIcons.linkIcon,
    AppIcons.logoutIcon,
    AppIcons.deleteIcon
  ];

  List<ContactModel?> groupUsers = [];

  @override
  Widget build(BuildContext context) {
    groupUsers = expenseController.getContactDataByNumbers(groupData!.memberIds!
        .where((element) => element.user.mobileNo != null)
        .map((e) => e.user.mobileNo!)
        .toList());
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
          ConstString.groupSetting,
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: groupSettingWidget(context),
    );
  }

  Widget groupSettingWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            groupData!.groupProfile != null &&
                groupData!.groupProfile!.isNotEmpty
                ? ClipOval(
              child: CachedNetworkImage(
                height: 80,
                width: 80,
                imageUrl: groupData!.groupProfile ?? '',
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
                progressIndicatorBuilder:
                    (context, url, downloadProgress) => SizedBox(
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
            )
                : Container(
              height: 80,
              width: 80,
              decoration:
              BoxDecoration(
                color: AppColors
                    .darkPrimaryColor,
                shape: BoxShape
                    .circle,
              ),
              child: Padding(
                padding:
                const EdgeInsets
                    .all(
                    15.0),
                child: SvgPicture
                    .asset(AppImages
                    .split_logo),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  groupData!.name ?? "Group",
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      if (controller.checkUserStatus(
                          groupData!, controller.loggedInUser!.mobileNo!)) {
                        editGroupDialogue(context, groupData!);
                      } else {
                        showInSnackBar(context,
                            "You can't edit group data because you're no longer a member.");
                      }
                    },
                    child: SvgPicture.asset(
                      AppIcons.editPenIcon,
                      height: 17,
                    ))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstString.groupInfo,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
                StreamBuilder(
                  stream:
                      expenseController.getSpentExpenseForGroup(groupData!.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CupertinoActivityIndicator();
                    } else if (snapshot.hasData) {
                      double groupTotal = snapshot.data!;
                      return Text(
                        "Total: ${userController.currencySymbol}${groupTotal.formatAmount()}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontMedium,
                            fontSize: 15),
                      );
                    } else {
                      return Text(
                        "Total: ${userController.currencySymbol}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontMedium,
                            fontSize: 15),
                      );
                    }
                  },
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.darkPrimaryColor)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupUsers.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                    color: AppColors.lineGrey,
                  );
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserProfileWidget(
                          size: Size(40, 40),
                          userData: controller.userController
                              .getUserData(
                              groupUsers[index]!.contactNumber!),
                          name: controller.userController
                              .getNameByPhoneNumber(
                              groupUsers[index]!.contactNumber),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: !groupUsers[index]!
                                      .contactNumber!
                                      .contains(
                                          controller.loggedInUser!.mobileNo!)
                                  ? Text(
                                      getUserName(index),
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: groupData!
                                                          .memberIds![index]
                                                          .status ==
                                                      'left'
                                                  ? AppColors.debit
                                                  : AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontMedium),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      "You",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: groupData!
                                                          .memberIds![index]
                                                          .status ==
                                                      'left'
                                                  ? AppColors.debit
                                                  : AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontMedium),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            groupUsers[index]!.contactNumber != null
                                ? Text(
                                    groupUsers[index]!.contactNumber ??
                                        'No Contact',
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 12,
                                            color: groupData!.memberIds![index]
                                                        .status ==
                                                    'left'
                                                ? AppColors.debit
                                                : AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontRegular),
                                  )
                                : MyGroupNumberTextWidget(),
                          ],
                        ),
                        const Spacer(),
                        StreamBuilder(
                          stream:
                              expenseController.fetchTotalGroupAmountForUser(
                                  groupData!.id!,
                                  groupUsers[index]!.contactNumber ??
                                      controller.loggedInUser!.mobileNo!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CupertinoActivityIndicator();
                            } else if (snapshot.hasData) {
                              double userAmount = snapshot.data!;
                              return Text(
                                "${userController.currencySymbol}${userAmount.toPrecision(2)}",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontMedium,
                                        color: AppColors.darkPrimaryColor),
                              );
                            } else {
                              return Text(
                                "${userController.currencySymbol}0.0",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontMedium,
                                        color: AppColors.darkPrimaryColor),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            StreamBuilder(
              stream: controller.fetchUserStatusStream(groupData!.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasData) {
                  String userStatus = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.darkPrimaryColor)),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            List<ContactModel> selectedContacts = groupData!
                                    .memberIds
                                    ?.where((member) =>
                                        member.user.mobileNo !=
                                        controller.loggedInUser!
                                            .mobileNo) // Filter out the current user
                                    .map((member) => controller
                                        .convertGroupMemberToContactModel(
                                            member))
                                    .toList() ??
                                [];
                            Get.to(() => AddMemberScreen(
                                  groupContacts: selectedContacts,
                                  groupData: groupData,
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor),
                                  height: 50,
                                  width: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(17),
                                    child: SvgPicture.asset(
                                      iconList[0],
                                      color: AppColors.darkPrimaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  taskList[0],
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontSize: 14,
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider(
                        //   height: 0,
                        //   thickness: 1,
                        //   indent: 15,
                        //   endIndent: 15,
                        //   color: AppColors.lineGrey,
                        // ),
                        // GestureDetector(
                        //   onTap: () async {
                        //     await FirebaseDynamicsLinking().createDynamicLink();
                        //   },
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 20, vertical: 10),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Container(
                        //           decoration: BoxDecoration(
                        //               shape: BoxShape.circle,
                        //               color: AppColors.primaryColor),
                        //           height: 50,
                        //           width: 50,
                        //           child: Padding(
                        //             padding: EdgeInsets.all(16),
                        //             child: SvgPicture.asset(
                        //               iconList[1],
                        //               color: AppColors.darkPrimaryColor,
                        //             ),
                        //           ),
                        //         ),
                        //         const SizedBox(
                        //           width: 15,
                        //         ),
                        //         Text(
                        //           taskList[1],
                        //           textScaler: const TextScaler.linear(1),
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .titleSmall!
                        //               .copyWith(
                        //                   fontSize: 14,
                        //                   color: AppColors.darkPrimaryColor,
                        //                   fontFamily: AppFont.fontMedium),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Divider(
                          height: 0,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                          color: AppColors.lineGrey,
                        ),
                        Visibility(
                          visible: userStatus == 'active',
                          child: GestureDetector(
                            onTap: () async {
                              print(
                                  '----fcm---->${controller.fcmTokenList.length}');
                              print(
                                  '----customerIdList---->${controller.customerIdList.length}');
                              // TODO : Remove only when all the group expense are settle up
                              leaveGroupDialogue(context, () {
                                controller.changeRemoveUserStatus(
                                    context,
                                    groupData!.id!,
                                    controller.loggedInUser!.mobileNo!);
                              }, payableAmount: payableAmount);
                              //TODO: Send Notification of Left from group
                              print('-------->left_group');


                              // await NotificationService
                              //     .sendMultipleNotifications(
                              //         senderId:
                              //             '${controller.userDataModel?.id}',
                              //         //customerId: controller.currentUserId,
                              //         customerIdList: controller.customerIdList,
                              //         groupId:
                              //             '${controller.selectedGroup.value?.id}',
                              //         type: 'left_group',
                              //         title:
                              //             '${controller.userDataModel?.name} has left the group “${controller.selectedGroup.value?.name}”.',
                              //         body: '',
                              //         tokens: controller.fcmTokenList);

                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.debit),
                                    height: 50,
                                    width: 50,
                                    child: Padding(
                                      padding: EdgeInsets.all(14),
                                      child: SvgPicture.asset(
                                        iconList[2],
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    taskList[2],
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: userStatus == 'left',
                          child: GestureDetector(
                            onTap: () {
                              controller.deleteUserFromGroup(
                                  context,
                                  groupData!.id!,
                                  controller.loggedInUser!.mobileNo!);
                              // if (groupData!.adminIds![0].user.mobileNo!.contains(
                              //     controller.calculateLast10Digits(
                              //         controller.loggedInUser!.mobileNo!))) {
                              //   deleteGroupDialogue(context, () async {
                              //     await controller
                              //         .deleteGroupAndRelatedData(groupData!.id!);
                              //   });
                              // } else {
                              //   showInSnackBar("Only admin can delete group");
                              // }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.debit),
                                    height: 50,
                                    width: 50,
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: SvgPicture.asset(
                                        iconList[3],
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    taskList[3],
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  String getUserName(int index) {
    String name = userController
            .getNameByPhoneNumber(groupData!.memberIds![index].user.mobileNo) ??
        groupData!.memberIds![index].user.name ??
        "";
    return name;
    /*return groupData!.memberIds![index].user.name ?? "";*/
  }

  String getName(int index) {
    String name =
        userController.getNameByPhoneNumber(groupUsers[index]!.contactNumber) ??
            groupUsers[index]!.contactName ??
            "-";
    return name[0].toUpperCase();
    /*return groupData!.memberIds![index].user.name != null
        ? groupData!.memberIds![index].user.mobileNo ==
                controller.loggedInUser!.mobileNo
            ? "Y"
            : String.fromCharCodes(
                    groupData!.memberIds![index].user.name!.runes.take(1))
                .toUpperCase()
        : "-";*/
  }
}

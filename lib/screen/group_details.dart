// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/pick_image_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/main.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/message_model.dart';
import 'package:split/screen/add_expense_form.dart';
import 'package:split/screen/group_expense_history.dart';
import 'package:split/screen/group_setting.dart';
import 'package:split/screen/settle_up_screen.dart';
import 'package:split/screen/view_split_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/app_dialogue.dart';
import 'package:split/widgets/chat_message_content.dart';

import '../model/user_contact_model.dart';

class GroupDetails extends GetWidget<GroupController> {
  final GroupDataModel? groupData;

  GroupDetails({super.key, this.groupData}) {
    Get.find<GroupController>()
        .initMessagesSubcollectionExistFuture(groupData!.id!);
  }

  final ExpenseController expenseController = Get.put(ExpenseController());
  final UserController userController = Get.find<UserController>();
  final PickImageController pickController = Get.put(PickImageController());

  final ScrollController _scrollController = ScrollController();

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
            controller.isAddExpense.value = false;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SvgPicture.asset(
              AppIcons.back_icon,
            ),
          ),
        ),
        titleSpacing: -10,
        title: GestureDetector(
          onTap: () {
            // controller.selectGroup(groupData!);
            print('------>Group setting page');
            Get.to(() => GroupSetting(
                  groupData: groupData,
                ));
          },
          child: Row(
            children: [
              groupData!.groupProfile != null &&
                      groupData!.groupProfile!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        height: 35,
                        width: 35,
                        imageUrl: groupData!.groupProfile! ?? "",
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
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(AppImages.split_logo),
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
              Text(
                groupData!.name ?? "Group",
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => GroupExpenseHistory(
                    groupData: groupData,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SvgPicture.asset(
                AppIcons.listBook,
                height: 22,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // if (controller.totalGroupAmount!.toInt() == 0) {
                // update status as settled to user where memberIds in the group
                // bool hasUpdatedStatus =
                //     await controller.settleUpGroup(
                //         groupData!.id!);
                // if (hasUpdatedStatus) {
                //   showInSnackBar(
                //       context, 'Settled Up!',
                //       isSuccess: true);
                // }
              // } else {
                Get.to(() => SettleUpScreen(
                      groupData: groupData,
                    ));
              // }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AppIcons.settleUpIcon,
                height: 22,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: GetBuilder<GroupController>(
        builder: (controller) {
          return FutureBuilder<bool>(
            future: controller.messagesSubcollectionExistFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CupertinoActivityIndicator(radius: 12));
              } else if (snapshot.hasData && snapshot.data!) {
                print('test');
                return groupDetails(context, () {
                  Future.delayed(const Duration(milliseconds: 1), () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(microseconds: 1),
                        curve: Curves.easeOut);
                  });
                });
              } else {
                return SizedBox(
                    width: double.infinity, child: noGroupDataWidget(context));
              }
            },
          );
        },
      ),
      floatingActionButton: Obx(() {
        return controller.isSuggestionMode.value
            ? Container(
                // height: 120,
                width: 200,
                margin: const EdgeInsets.only(bottom: 70),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.txtGrey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.white),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0,
                      thickness: 1,
                      color: AppColors.decsGrey,
                    );
                  },
                  shrinkWrap: true,
                  itemCount: controller.userSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "@${controller.userSuggestions[index]!}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 14),
                      ),
                      onTap: () {
                        controller
                            .onUserSelected(controller.userSuggestions[index]!);
                      },
                    );
                  },
                ),
              )
            : Container();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomSheet: Obx(() => Container(
        height:
        pickController.selectedGroupChatImage.isNotEmpty ? 200 : 70,
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
        child: controller.checkUserStatus(
            groupData!, controller.loggedInUser!.mobileNo!)
            ? Padding(
          padding: const EdgeInsets.only(
              left: 15, right: 15, bottom: 10),
          child: Column(
            children: [
              pickController.selectedGroupChatImage.isNotEmpty
                  ? Container(
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(pickController
                            .selectedGroupChatImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
                  : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Obx(
                        () => controller.isAddExpense.value
                        ? ElevatedButton(
                        onPressed: () async {
                          Get.to(() => ExpenseForm(
                            selectedGroup: groupData,
                          ));
                          controller.isAddExpense.value =
                          false;
                        },
                        style: ElevatedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10),
                            backgroundColor:
                            AppColors.primaryColor,
                            fixedSize: const Size(110, 45),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    30))),
                        child: Text(
                          ConstString.addExpense,
                          textScaler:
                          const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                              fontSize: 13,
                              color: AppColors
                                  .darkPrimaryColor,
                              fontFamily:
                              AppFont.fontMedium),
                        ))
                        : SizedBox(
                      height: 45,
                      width: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            controller.isAddExpense.value =
                            !controller
                                .isAddExpense.value;
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 10),
                              backgroundColor:
                              AppColors.primaryColor,
                              fixedSize: const Size(40, 45),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      30))),
                          child: SvgPicture.asset(
                            AppIcons.arrow_right,
                            height: 20,
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: CustomTextField(
                        controller: controller,
                        groupData: groupData!,
                        pickController: pickController,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
            : Center(
          child: Container(
            height: 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: AppColors.decsGrey.withOpacity(0.5),
            child: Text(
              "You can't send messages to this group because you're no longer a member.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(
                  color: AppColors.txtGrey, fontSize: 13),
            ),
          ),
        ),
      ))
    );
  }

  Widget noGroupDataWidget(BuildContext context) {
    List<ContactModel?> groupMembers = controller.getContactNamesByNumbers(
        groupData!.memberIds!
            .where((element) => element.user.mobileNo != null)
            .map((e) => e.user.mobileNo!)
            .toList());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          groupData!.groupProfile != null && groupData!.groupProfile!.isNotEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      height: 80,
                      width: 80,
                      imageUrl: groupData!.groupProfile! ?? '',
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
                  ),
                )
              : CustomGroupAvtarWidget(
                  size: const Size(150, 150),
                  userMobileList: groupData!.memberIds!
                      .map((e) => e.user.mobileNo)
                      .toList(),
                ),
          const SizedBox(
            height: 10,
          ),
          Text(
            groupData!.name ?? "Group",
            textScaler: const TextScaler.linear(1),
            // ConstString.splitAppName,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: AppFont.fontMedium),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            getTextBasedOnUserName(groupMembers),
            textScaler: const TextScaler.linear(1),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColors.darkPrimaryColor),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Create, strategize, and manage shared expenses \nseamlessly all in one location.",
            textScaler: const TextScaler.linear(1),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColors.darkPrimaryColor),
          ),
          TextButton(
              onPressed: () async {
                MessageModel message = MessageModel(
                    messageId: uuid.v1(),
                    message: "Hello👋",
                    sender: controller.loggedInUser!.mobileNo,
                    createdTime: DateTime.now(),
                    isSeen: false,
                    expenseId: "");
                await controller.sendMessage(message, groupData!.id!);
              },
              child: Text(
                "Say “Hello👋”",
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 13,
                    color: AppColors.debit,
                    fontFamily: AppFont.fontMedium),
              ))
        ],
      ),
    );
  }

  String getTextBasedOnUserName(List<ContactModel?> groupMembers) {
    if (groupMembers.length > 2) {
      return groupMembers.length > 1
          ? "You created “${groupData?.name ?? "Group"}” with ${groupMembers[1]?.contactName?.split(" ").first ?? "You"},\n ${groupMembers[2]?.contactName?.split(" ").first ?? "You"} and other..."
          : "You created “${groupData?.name ?? "Group"}” with ${groupMembers[0]?.contactName?.split(" ").first ?? "You"},\n and other...";
    } else if (groupMembers.length > 1) {
      return "You created “${groupData?.name ?? "Group"}” with ${groupMembers[0]?.contactName?.split(" ").first ?? "You"},\n ${groupMembers[1]?.contactName?.split(" ").first ?? "You"} and other...";
    } else {
      return "You created “${groupData?.name ?? "Group"}” with ${groupMembers[0]?.contactName?.split(" ").first ?? "You"},\n and other...";
    }
  }

  Widget groupDetails(BuildContext context, void Function()? onMessageLoaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          GetBuilder<GroupController>(
            builder: (controller) {
              if (controller.totalGroupAmount != null) {
                double amount = controller.totalGroupAmount!;
                return Column(
                  children: [
                    Container(
                      // height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: amount >= 0
                            ? AppColors.primaryColor
                            : AppColors.payColor,
                        border: Border.all(
                            color: AppColors.darkPrimaryColor, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amount > 0
                                      ? ConstString.youGetBack
                                      : ConstString.youAreNeed,
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontSize: 13,
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontMedium),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${userController.currencySymbol}${amount.toPrecision(2)}",
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          fontSize: 22,
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontSemiBold),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 33,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        Get.to(() => ViewSplitScreen(
                                              groupData: groupData,
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          backgroundColor:
                                              AppColors.darkPrimaryColor,
                                          fixedSize: const Size(85, 18),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      child: Text(
                                        ConstString.viewSplit,
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                fontSize: 13,
                                                color: AppColors.white,
                                                fontFamily: AppFont.fontMedium),
                                      )),
                                ),
                                // if (amount != 0) const SizedBox(height: 10),
                                // if (amount != 0)
                                //   SizedBox(
                                //     height: 33,
                                //     child: ElevatedButton(
                                //         onPressed: () async {
                                //           if (amount == 0) {
                                //             // update status as settled to user where memberIds in the group
                                //             // bool hasUpdatedStatus =
                                //             //     await controller.settleUpGroup(
                                //             //         groupData!.id!);
                                //             // if (hasUpdatedStatus) {
                                //             //   showInSnackBar(
                                //             //       context, 'Settled Up!',
                                //             //       isSuccess: true);
                                //             // }
                                //           } else {
                                //             Get.to(() => SettleUpScreen(
                                //                   groupData: groupData,
                                //                 ));
                                //           }
                                //         },
                                //         style: ElevatedButton.styleFrom(
                                //             padding: const EdgeInsets.symmetric(
                                //                 horizontal: 10),
                                //             backgroundColor:
                                //                 AppColors.darkPrimaryColor,
                                //             fixedSize: const Size(85, 18),
                                //             elevation: 0,
                                //             shape: RoundedRectangleBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(30))),
                                //         child: Text(
                                //           ConstString.settleUp,
                                //           textScaler:
                                //               const TextScaler.linear(1),
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .titleMedium!
                                //               .copyWith(
                                //                   fontSize: 13,
                                //                   color: AppColors.primaryColor,
                                //                   fontFamily:
                                //                       AppFont.fontMedium),
                                //         )),
                                //   ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container(); // Or some loading/error state
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GetBuilder(
              id: 'messages',
              init: GroupController(),
              builder: (controller) {
                if (controller.messages != null) {
                  List<MessageModel> messages = controller.messages!;
                  if (onMessageLoaded != null) {
                    onMessageLoaded();
                  }
                  if (controller.expenses == null &&
                      controller.expenses.isEmpty) {
                    return const Center(
                      child: CupertinoActivityIndicator(
                        radius: 12,
                      ),
                    );
                  }
                  final groupedMessages = <DateTime, List<MessageModel>>{};
                  for (var message in messages) {
                    final date = DateTime(message.createdTime!.year,
                        message.createdTime!.month, message.createdTime!.day);
                    groupedMessages.putIfAbsent(date, () => []);
                    groupedMessages[date]!.add(message);
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      final date = groupedMessages.keys.toList()[index];
                      final messagesForDate = groupedMessages[date]!;

                      Widget dateHeader = const SizedBox.shrink();
                      if (index == 0 ||
                          date != groupedMessages.keys.toList()[index - 1]) {
                        dateHeader = Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 15),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(date),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: AppColors.txtGrey,
                                    fontSize: 11,
                                    fontFamily: AppFont.fontMedium),
                          ),
                          decoration: BoxDecoration(
                              color: AppColors.decsGrey,
                              borderRadius: BorderRadius.circular(10)),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          dateHeader,
                          ListView.builder(
                            // controller: _scrollController,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messagesForDate.length,
                            // physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              MessageModel messageData = messagesForDate[index];
                              bool isFirstInGroup = false;
                              bool isLastInGroup = false;

                              if (index == 0) {
                                isFirstInGroup = true;
                              } else {
                                MessageModel previousMessage =
                                    messages[index - 1];
                                if (messageData.sender !=
                                    previousMessage.sender) {
                                  isFirstInGroup = true;
                                }
                              }

                              if (index == messages.length - 1) {
                                isLastInGroup = true;
                              } else {
                                MessageModel nextMessage = messages[index + 1];
                                if (messageData.sender != nextMessage.sender) {
                                  isLastInGroup = true;
                                }
                              }

                              String message = messageData.message ?? "";
                              String image = messageData.image ?? "";
                              String messageTime = DateFormat('h:mm a')
                                  .format(messageData.createdTime!);
                              bool sender = messageData.sender ==
                                  controller.loggedInUser!.mobileNo;
                              String senderId = messageData.sender!;
                              String expenseId = messageData.expenseId!;

                              return MyChatWidget(
                                  message,
                                  image,
                                  messageTime,
                                  senderId,
                                  expenseId,
                                  groupData!,
                                  sender,
                                  isFirstInGroup,
                                  isLastInGroup);
                            },
                          )
                        ],
                      );
                    },
                  );
                  // return ListView.builder(
                  //   controller: _scrollController,
                  //   // shrinkWrap: false,
                  //   // physics: const NeverScrollableScrollPhysics(),
                  //   // reverse: true,
                  //   itemCount: messages.length,
                  //   physics: const ClampingScrollPhysics(),
                  //   itemBuilder: (context, index) {
                  //     MessageModel messageData = messages[index];
                  //     bool isFirstInGroup = false;
                  //     bool isLastInGroup = false;
                  //
                  //     if (index == 0) {
                  //       isFirstInGroup = true;
                  //     } else {
                  //       MessageModel previousMessage = messages[index - 1];
                  //       if (messageData.sender != previousMessage.sender) {
                  //         isFirstInGroup = true;
                  //       }
                  //     }
                  //
                  //     if (index == messages.length - 1) {
                  //       isLastInGroup = true;
                  //     } else {
                  //       MessageModel nextMessage = messages[index + 1];
                  //       if (messageData.sender != nextMessage.sender) {
                  //         isLastInGroup = true;
                  //       }
                  //     }
                  //
                  //     String message = messageData.message ?? "";
                  //     String messageTime =
                  //         DateFormat('h:mm a').format(messageData.createdTime!);
                  //     bool sender = messageData.sender ==
                  //         controller.loggedInUser!.mobileNo;
                  //     String senderId = messageData.sender!;
                  //     String expenseId = messageData.expenseId!;
                  //
                  //     return MyChatWidget(
                  //         message,
                  //         messageTime,
                  //         senderId,
                  //         expenseId,
                  //         groupData!,
                  //         sender,
                  //         isFirstInGroup,
                  //         isLastInGroup);
                  //   },
                  // );
                } else if (controller.messages == null) {
                  // Handle the loading or empty state
                  return const Center(
                    child: Text(
                      "An Error Occured! Please try again later.",
                      textScaler: TextScaler.linear(1),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      "Hello 🤘",
                      textScaler: const TextScaler.linear(1),
                      style: TextStyle(
                          color: AppColors.primaryColor, fontSize: 30),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 70,
          )
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final GroupController controller;
  final GroupDataModel groupData;
  final PickImageController pickController;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.groupData,
    required this.pickController,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  void _onSendMessage() async {
    if (widget.controller.messageController.text.isNotEmpty ||
        widget.pickController.selectedGroupChatImage.isNotEmpty) {
      String selectedImage = "";
      if (widget.pickController.selectedGroupChatImage.isNotEmpty) {
        showProgressDialogue(context);
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        Random random = Random();
        int randomNumber = random.nextInt(999999);

        final ref = FirebaseStorage.instance
            .ref('groups/Image$timestamp$randomNumber.jpg');
        final picFile = File(widget.pickController.selectedGroupChatImage);

        if (await picFile.exists()) {
          UploadTask uploadTask = ref.putFile(picFile);
          await Future.value(uploadTask).then((value) async {
            var newUrl = await ref.getDownloadURL();
            selectedImage = newUrl.toString();
            Get.back();
          }).onError((error, stackTrace) {
            showInSnackBar(context, "$error", isSuccess: false);
          });
        }
      }

      String messageText = widget.controller.messageController.text.trim();
      widget.controller.messageController.clear();
      MessageModel message = MessageModel(
          messageId: uuid.v1(),
          message: messageText,
          sender: widget.controller.loggedInUser!.mobileNo,
          image: selectedImage,
          createdTime: DateTime.now(),
          isSeen: false,
          expenseId: "",
          msgType: "Text");
      await widget.controller
          .sendMessage(message, widget.groupData.id!)
          .then((value) {
        widget.pickController.selectedGroupChatImage = "";
        widget.controller.messageSent();
      });
    }
    widget.controller.isSuggestionMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: TextFormField(
          focusNode: widget.controller.messageFocusNode,
          textCapitalization: TextCapitalization.sentences,
          controller: widget.controller.messageController,
          onChanged: (value) {
            widget.controller.suggestUsers(value, widget.groupData);
          },
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: AppColors.txtGrey, fontSize: 14),
          cursorColor: AppColors.txtGrey,
          decoration: InputDecoration(
              prefixIcon: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                    widget.pickController.pickGroupChatImage(context);

                },
                child: Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 20,
                  color: AppColors.darkPrimaryColor,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: _onSendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(AppIcons.sendIcon),
                ),
              ),
              hintText: "Send a message",
              hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontFamily: AppFont.fontRegular,
                  color: AppColors.darkPrimaryColor,
                  fontSize: 13.5),
              filled: true,
              fillColor: AppColors.decsGrey,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: AppColors.decsGrey)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.decsGrey, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.decsGrey, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.decsGrey, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 20)),
        ));
  }

// @override
// void dispose() {
//   widget.controller.messageController.dispose();
//   super.dispose();
// }
}

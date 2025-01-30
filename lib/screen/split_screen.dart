// ignore_for_file: deprecated_member_use, prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/app_dialogue.dart';
import 'package:split/widgets/user/my_number_text_widget.dart';
import 'package:split/widgets/user/my_profile_widget.dart';

class SplitScreen extends StatefulWidget {
  final Expense? expense;
  final GroupDataModel? groupData;
  String? editAmout;

  SplitScreen({super.key, this.expense, this.groupData, this.editAmout});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  ExpenseController controller = Get.find<ExpenseController>();
  final UserController userController = Get.find<UserController>();
  final GroupController groupController = Get.put(GroupController());
  late List<ContactModel?> groupUsers;
  GroupDataModel? groupData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        tabController.animateTo(1,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        tabController.animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      });
    });
    groupData = widget.groupData;
    tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    groupUsers = controller.getContactDataByNumbers(controller
        .expenseData.value.groupDataModel!.memberIds!
        .where((groupMember) =>
            groupMember.user.mobileNo != null && groupMember.status == 'active')
        .map((groupMember) => groupMember.user.mobileNo!)
        .toList());
    controller.initializeUsers(
        controller.expenseData.value.groupDataModel!.memberIds!
            .where((groupMember) =>
                groupMember.user.mobileNo != null &&
                groupMember.status == 'active')
            .map((groupMember) => groupMember.user.mobileNo!)
            .toList(),
        controller.expenseData.value.amount!);
    controller.updateExpenseSplit();
    controller.expenseData.value.splitMode = controller.splitMode.toString();
    controller.remainingAmount.value = controller.expenseData.value.amount!;
    controller.resetState();
  }

  int getTabIndexForSplitMode(String splitMode) {
    switch (splitMode) {
      case 'Amount':
        return 1; // Assuming Amount is the second tab
      case 'Percentage':
        return 2;
      case 'Share':
        return 3; // Assuming Percentage is the third tab
      default:
        return 0; // Default tab index, for example, 'Equally'
    }
  }

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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ElevatedButton(
            onPressed: () async {
              //groupController.selectGroup(groupData!);
              if (widget.expense == null) {
                if (controller.expenseData.value.equality != null) {
                  if (controller.hasDistributedTotalAmount()) {
                    showProgressDialogue(context);
                    //TODO: Send Notification of Add Expense
                    // print(
                    //     '--customerIdList-->${groupController.customerIdList}');
                    // await NotificationService.sendMultipleNotifications(
                    //     senderId: '${groupController.userDataModel?.id}',
                    //     groupId: widget.groupData!.id!,
                    //     //customerId: groupController.currentUserId,
                    //     customerIdList: groupController.customerIdList,
                    //     type: 'add_expense',
                    //     title:
                    //         '${groupController.userDataModel?.name} added a ${userController.currencySymbol}${controller.expenseAmountController.text} expense for ${controller.expenseDescriptionController.text} in “${groupController.selectedGroup.value?.name}”.',
                    //     body: '',
                    //     tokens: groupController.fcmTokenList);

                    await controller.addExpense(context);

                    groupController.fcmTokenList.clear();
                    groupController.customerIdList.clear();
                  } else {
                    showInSnackBar(
                        context, "Please split all amount between the users.");
                  }
                } else {
                  showInSnackBar(context, "Please fill required fields");
                }
              } else {
                if (!controller.hasDistributedTotalAmount()) {
                  showInSnackBar(
                      context, "Please split all amount between the users.");
                  return;
                }
                Expense expense = Expense(
                    expenseId: widget.expense!.expenseId,
                    title: controller.expenseData.value.title,
                    payerId: controller.expenseData.value.payerId,
                    groupId: widget.groupData!.id,
                    splitMode: controller.expenseData.value.splitMode,
                    behalfAddUser:
                        GroupMember(user: groupController.loggedInUser!),
                    splitExpenseAt: DateTime.now(),
                    createdAt: controller.expenseData.value.createdAt,
                    amount: controller.expenseData.value.amount,
                    equality: controller.expenseData.value.equality);
                await controller.editExpense(context, widget.groupData!.id!,
                    widget.expense!.expenseId!, expense);
                //TODO: Send Notification of Edit Expense
                // await NotificationService.instance.sendTestNotification();

                // print('--customerIdList-->${groupController.customerIdList}');
                // await NotificationService.sendMultipleNotifications(
                //     senderId: '${groupController.userDataModel?.id}',
                //     groupId: widget.groupData!.id!,
                //     //customerId: groupController.currentUserId,
                //     customerIdList: groupController.customerIdList,
                //     type: 'edited_expense',
                //     title:
                //         '${groupController.userDataModel?.name} Edited the ${widget.expense?.title} expense from ${userController.currencySymbol}${widget.expense?.amount} to ${userController.currencySymbol}${widget.editAmout}  in “${widget.groupData!.name}”.',
                //     body: '',
                //     tokens: groupController.fcmTokenList);

                groupController.fcmTokenList.clear();
                groupController.customerIdList.clear();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                fixedSize: const Size(200, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Text(
              widget.expense != null
                  ? ConstString.editExpense
                  : ConstString.addExpense,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontMedium),
            )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ConstString.total,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "${userController.currencySymbol} ${controller.expenseData.value.amount}",
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontSize: 30,
                    fontFamily: AppFont.fontSemiBold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TabBar(
              labelPadding: const EdgeInsets.all(3),
              controller: tabController,
              dividerColor: AppColors.paymentLine.withOpacity(0.2),
              // dividerHeight: 1,
              physics: const BouncingScrollPhysics(),
              labelColor: AppColors.darkPrimaryColor,
              labelStyle: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: 12, fontFamily: AppFont.fontMedium),
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelStyle: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: 12, fontFamily: AppFont.fontRegular),
              onTap: (value) {
                tabController.index = value;
                if (value == 0) {
                  controller.updateSplitMode(SplitMode.Equally);
                  controller.splitEqually();
                } else if (value == 1) {
                  controller.updateSplitMode(SplitMode.Amount);
                  controller.splitByAmount();
                } else if (value == 2) {
                  controller.updateSplitMode(SplitMode.Percentage);
                  controller.percentageSplit();
                } else if (value == 3) {
                  controller.updateSplitMode(SplitMode.Share);
                  controller.shareSplit();
                } else {
                  controller.updateSplitMode(SplitMode.Equally);
                  controller.splitEqually();
                }
                controller.remainingAmount.value =
                    controller.expenseData.value.amount!;
                controller.resetState();
                controller.updateExpenseSplit();
                setState(() {});
              },
              unselectedLabelColor: AppColors.paymentLine,
              indicatorColor: AppColors.darkPrimaryColor,
              tabs: [
                Tab(
                  icon: SvgPicture.asset(
                    AppIcons.equalIcon,
                    height: 17,
                    color: tabController.index == 0
                        ? AppColors.darkPrimaryColor
                        : AppColors.paymentLine,
                  ),
                  text: "Equally",
                  height: 50,
                ),
                Tab(
                  icon: SvgPicture.asset(
                    AppIcons.doller_fill,
                    height: 17,
                    color: tabController.index == 1
                        ? AppColors.darkPrimaryColor
                        : AppColors.paymentLine,
                  ),
                  text: "Amount",
                  height: 50,
                ),
                Tab(
                  icon: SvgPicture.asset(
                    AppIcons.percentageIcon,
                    height: 15,
                    color: tabController.index == 2
                        ? AppColors.darkPrimaryColor
                        : AppColors.paymentLine,
                  ),
                  text: "Percentage",
                  height: 50,
                ),
                Tab(
                  icon: SvgPicture.asset(
                    AppIcons.paidUserFillIcon,
                    color: tabController.index == 3
                        ? AppColors.darkPrimaryColor
                        : AppColors.paymentLine,
                    height: 17,
                  ),
                  text: "Share",
                  height: 50,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: TabBarView(controller: tabController, children: [
                equalWidget(),
                amountWidget(),
                percentageWidget(),
                shareWidget(),
              ]),
            )
          ],
        ));
  }

  Widget equalWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.splitEqualy,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontMedium,
                      fontSize: 15,
                    ),
              ),
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
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    color: AppColors.lineGrey,
                  );
                },
                itemBuilder: (context, index) {
                  return Obx(() {
                    var selectedUserIds =
                        controller.selectedUsers.keys.toList();
                    String userId = selectedUserIds[index];
                    bool isSelected = controller.selectedUsers[userId] ?? false;
                    double splitAmount = controller.splitAmounts[userId] ?? 0;
                    return GestureDetector(
                      onTap: () {
                        controller.toggleUserSelection(userId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                                child: SvgPicture.asset(
                              isSelected
                                  ? AppIcons.checkFill
                                  : AppIcons.emptyCheck,
                              height: 18,
                            )),
                            const SizedBox(
                              width: 7,
                            ),
                            groupData!.memberIds![index].user.name != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryColor,
                                    child: Text(
                                      groupData!.memberIds![index].user.name !=
                                              null
                                          ? groupData!.memberIds![index].user
                                                      .mobileNo ==
                                                  groupController
                                                      .loggedInUser!.mobileNo
                                              ? "Y"
                                              : getName(index).substring(0, 1)
                                          : "?",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontSemiBold,
                                              fontSize: 20),
                                    ),
                                  )
                                : MyGroupProfileWidget(),
                            const SizedBox(
                              width: 7,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    getName(index),
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                groupUsers[index]!.contactNumber != null
                                    ? Text(
                                        getNumber(index),
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                fontSize: 12,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontFamily:
                                                    AppFont.fontRegular),
                                      )
                                    : MyGroupNumberTextWidget(),
                              ],
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                child: Text(
                                  "${userController.currencySymbol}${splitAmount.formatAmount()}",
                                  textScaler: const TextScaler.linear(1),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontFamily: AppFont.fontMedium,
                                          color: AppColors.darkPrimaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }

  String getNumber(int index) {
    return (groupUsers[index]!
            .contactNumber
            ?.replaceAll(RegExp(r'[^\d]'), '')) ??
        'No Contact';
  }

  String getName(int index) {
    if (groupUsers[index]!.contactName != null) {
      return groupUsers[index]!.contactName ?? "";
    } else {
      if (groupController.loggedInUser!.mobileNo ==
          groupUsers[index]!.contactNumber!) {
        return "You";
      }
      return userController
              .getUserData(groupUsers[index]!.contactNumber!)
              ?.name ??
          "-";
    }
  }

  Widget amountWidget() {
    // controller.initializeAmountFields(widget.expense, groupUsers);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstString.exactAmount,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
                Obx(() => Text(
                      "${userController.currencySymbol}${controller.remainingAmount.value.formatAmount()} Left",
                      textScaler: const TextScaler.linear(1),
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 15,
                              ),
                    )),
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
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    color: AppColors.lineGrey,
                  );
                },
                itemBuilder: (context, index) {
                  return Obx(() {
                    var selectedUserIds =
                        controller.selectedUsers.keys.toList();
                    String userId = selectedUserIds[index];
                    bool isSelected = controller.selectedUsers[userId] ?? false;
                    // var amountController = controller.amountControllers[userId];
                    return GestureDetector(
                      onTap: () {
                        controller.toggleUserSelection(userId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                                child: SvgPicture.asset(
                              isSelected
                                  ? AppIcons.checkFill
                                  : AppIcons.emptyCheck,
                              height: 18,
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            groupData!.memberIds![index].user.name != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryColor,
                                    child: Text(
                                      groupData!.memberIds![index].user.name !=
                                              null
                                          ? groupData!.memberIds![index].user
                                                      .mobileNo ==
                                                  groupController
                                                      .loggedInUser!.mobileNo
                                              ? "Y"
                                              : getName(index).substring(0, 1)
                                          : "?",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontSemiBold,
                                              fontSize: 20),
                                    ),
                                  )
                                : MyGroupProfileWidget(),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    getName(index),
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                groupUsers[index]!.contactNumber != null
                                    ? Text(
                                        getNumber(index),
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                fontSize: 12,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontFamily:
                                                    AppFont.fontRegular),
                                      )
                                    : MyGroupNumberTextWidget(),
                              ],
                            ),
                            const Spacer(),
                            isSelected
                                ? Expanded(
                                    child: SizedBox(
                                      height: 40,
                                      width: 60,
                                      child: MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              textScaler:
                                                  const TextScaler.linear(1)),
                                          child: TextFormField(
                                            // controller: amountController,
                                            onChanged: (value) {
                                              double amount =
                                                  double.tryParse(value) ?? 0;
                                              controller.setUserAmount(
                                                  userId, amount);
                                              controller
                                                  .updateRemainingAmount();
                                            },
                                            keyboardType: TextInputType.number,
                                            cursorColor: AppColors.paymentLine,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    color: AppColors
                                                        .darkPrimaryColor,
                                                    fontFamily:
                                                        AppFont.fontMedium),
                                            decoration: InputDecoration(
                                                hintText:
                                                    "${userController.currencySymbol} 000",
                                                hintStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        color: AppColors
                                                            .darkPrimaryColor
                                                            .withOpacity(0.5),
                                                        fontFamily:
                                                            AppFont.fontMedium),
                                                border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .paymentLine)),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .paymentLine)),
                                                focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine))),
                                          )),
                                    ),
                                  )
                                : Text(
                                    "${userController.currencySymbol}0.0",
                                    textScaler: const TextScaler.linear(1),
                                    // "\$${controller.equalDivide(groupUsers.length)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontFamily: AppFont.fontMedium,
                                            color: AppColors.darkPrimaryColor),
                                  ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }

  Widget percentageWidget() {
    // controller.initializePercentageFields(widget.expense, groupUsers);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstString.splitPercentage,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
                Obx(() => Text(
                      "${controller.remainingPercentage.value.formatAmount()}% Left",
                      textScaler: const TextScaler.linear(1),
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 15,
                              ),
                    )),
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
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    color: AppColors.lineGrey,
                  );
                },
                itemBuilder: (context, index) {
                  return Obx(() {
                    var selectedUserIds =
                        controller.selectedUsers.keys.toList();
                    String userId = selectedUserIds[index];
                    bool isSelected = controller.selectedUsers[userId] ?? false;
                    // var percentageController =
                    //     controller.percentageControllers[userId];
                    return GestureDetector(
                      onTap: () {
                        controller.toggleUserSelection(userId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                                child: SvgPicture.asset(
                              isSelected
                                  ? AppIcons.checkFill
                                  : AppIcons.emptyCheck,
                              height: 18,
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            groupData!.memberIds![index].user.name != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryColor,
                                    child: Text(
                                      groupData!.memberIds![index].user.name !=
                                              null
                                          ? groupData!.memberIds![index].user
                                                      .mobileNo ==
                                                  groupController
                                                      .loggedInUser!.mobileNo
                                              ? "Y"
                                              : getName(index).substring(0, 1)
                                          : "?",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontSemiBold,
                                              fontSize: 20),
                                    ),
                                  )
                                : MyGroupProfileWidget(),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    getName(index),
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                groupUsers[index]!.contactNumber != null
                                    ? Text(
                                        getNumber(index),
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                fontSize: 12,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontFamily:
                                                    AppFont.fontRegular),
                                      )
                                    : MyGroupNumberTextWidget(),
                              ],
                            ),
                            const Spacer(),
                            isSelected
                                ? Expanded(
                                    child: SizedBox(
                                      height: 40,
                                      width: 60,
                                      child: MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              textScaler:
                                                  const TextScaler.linear(1)),
                                          child: TextFormField(
                                            // controller: percentageController,
                                            onChanged: (value) {
                                              double percentage =
                                                  double.tryParse(value) ?? 0;
                                              controller.setUserPercentage(
                                                  userId, percentage);
                                              controller
                                                  .updateRemainingPercentage();
                                            },
                                            keyboardType: TextInputType.number,
                                            cursorColor: AppColors.paymentLine,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    color: AppColors
                                                        .darkPrimaryColor,
                                                    fontFamily:
                                                        AppFont.fontMedium),
                                            decoration: InputDecoration(
                                                hintText: "\% 000",
                                                hintStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        color: AppColors
                                                            .darkPrimaryColor
                                                            .withOpacity(0.5),
                                                        fontFamily:
                                                            AppFont.fontMedium),
                                                border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .paymentLine)),
                                                disabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .paymentLine)),
                                                focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine)),
                                                errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.paymentLine))),
                                          )),
                                    ),
                                  )
                                : Text(
                                    "\%0.0",
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontFamily: AppFont.fontMedium,
                                            color: AppColors.darkPrimaryColor),
                                  ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }

  Widget shareWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.splitShare,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontMedium,
                      fontSize: 15,
                    ),
              ),
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
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    color: AppColors.lineGrey,
                  );
                },
                itemBuilder: (context, index) {
                  return Obx(() {
                    var selectedUserIds =
                        controller.selectedUsers.keys.toList();
                    String userId = selectedUserIds[index];
                    bool isSelected = controller.selectedUsers[userId] ?? false;
                    int userShare = controller.userShares[userId] ?? 0;
                    double userAmount = controller.getUserAmount(userId);

                    return GestureDetector(
                      onTap: () {
                        controller.toggleUserSelection(userId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                                child: SvgPicture.asset(
                              isSelected
                                  ? AppIcons.checkFill
                                  : AppIcons.emptyCheck,
                              height: 18,
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            groupData!.memberIds![index].user.name != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryColor,
                                    child: Text(
                                      groupData!.memberIds![index].user.name !=
                                              null
                                          ? groupData!.memberIds![index].user
                                                      .mobileNo ==
                                                  groupController
                                                      .loggedInUser!.mobileNo
                                              ? "Y"
                                              : getName(index).substring(0, 1)
                                          : "?",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontSemiBold,
                                              fontSize: 20),
                                    ),
                                  )
                                : MyGroupProfileWidget(),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    getName(index),
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            fontSize: 14,
                                            color: AppColors.darkPrimaryColor,
                                            fontFamily: AppFont.fontMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                isSelected
                                    ? Text(
                                        "${userController.currencySymbol}${userAmount.isFinite ? userAmount.formatAmount() : "0.0"}",
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                fontSize: 12,
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                fontFamily:
                                                    AppFont.fontRegular),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.updateUserShare(userId,
                                        (userShare > 1) ? userShare - 1 : 1);
                                  },
                                  child: Container(
                                    height: 23,
                                    width: 23,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.paymentLine),
                                        color: AppColors.decsGrey,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.remove,
                                      color: AppColors.darkPrimaryColor,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  userShare.toString(),
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontFamily: AppFont.fontMedium,
                                          color: AppColors.darkPrimaryColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.updateUserShare(
                                        userId, userShare + 1);
                                  },
                                  child: Container(
                                    height: 23,
                                    width: 23,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.paymentLine),
                                        color: AppColors.decsGrey,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.darkPrimaryColor,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}

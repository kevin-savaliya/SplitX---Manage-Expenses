import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/screen/add_expense_form.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/app_dialogue.dart';
import 'package:split/widgets/user/my_number_text_widget.dart';

class ExpenseDetails extends StatelessWidget {
  final Expense? expense;
  final GroupDataModel? groupData;
  final bool? isSender;

  ExpenseDetails(
      {super.key, this.expense, this.groupData, this.isSender = false});

  List<ContactModel?> groupUsers = [];

  final ExpenseController expenseController = Get.put(ExpenseController());
  final GroupController controller = Get.find<GroupController>();
  final UserController userController = Get.find<UserController>();

  // final GroupController groupController = Get.put(GroupController());

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
        actions: [
          isSender!
              ? GestureDetector(
                  onTap: () {
                    Get.to(() => ExpenseForm(
                          selectedGroup: groupData,
                          expense: expense,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      AppIcons.editIcon,
                      height: 18,
                    ),
                  ),
                )
              : const SizedBox(),
          if (isSender!)
            GestureDetector(
              onTap: () {
                deleteExpenseDialogue(
                  context,
                  () async {
                    expenseController.deleteExpense(
                        context, groupData!.id!, expense!.expenseId!);

                    // await NotificationService.sendMultipleNotifications(
                    //     senderId: '${controller.userDataModel?.id}',
                    //     groupId: groupData!.id!,
                    //     //customerId: controller.currentUserId,
                    //     customerIdList: controller.customerIdList,
                    //     type: 'delete_expense',
                    //     title:
                    //         '${controller.userDataModel?.name} deleted the ${expense?.title} expense of ${userController.currencySymbol}${expense?.amount} From “${groupData?.name}”.',
                    //     body: '',
                    //     tokens: controller.fcmTokenList);

                    controller.fcmTokenList.clear();
                    controller.customerIdList.clear();

                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 15),
                child: SvgPicture.asset(
                  AppIcons.deleteIcon,
                  height: 18,
                ),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
      body: expenseDetailWidget(context),
      // bottomNavigationBar: BannerAdWidget(),
    );
  }

  Widget expenseDetailWidget(BuildContext context) {
    String? expenseUserName =
        expense!.payerId!.user.mobileNo != controller.loggedInUser!.mobileNo
            ? expense!.payerId!.user.name!.split(" ").first
            : "You";
    String? expenseBehalfUserName = expense!.behalfAddUser!.user.mobileNo !=
            controller.loggedInUser!.mobileNo
        ? expense!.behalfAddUser!.user.name!.split(" ").first
        : "You";
    String expenseDate = DateFormat('d MMM yyyy').format(expense!.createdAt!);
    String expenseAddDate =
        DateFormat('d MMM yyyy').format(expense!.splitExpenseAt!);
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
            Text(
              groupData!.name ?? "Group",
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 17),
            ),
            expenseUserName != expenseBehalfUserName
                ? RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: expenseBehalfUserName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: AppFont.fontMedium, fontSize: 12),
                      ),
                      TextSpan(
                        text: " has added expense behalf of ",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: AppFont.fontRegular, fontSize: 12),
                      ),
                      TextSpan(
                        text: expenseUserName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: AppFont.fontMedium, fontSize: 12),
                      ),
                    ]))
                : RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      // TextSpan(
                      //   text: expenseBehalfUserName!.split(" ").first,
                      //   style: Theme.of(context)
                      //       .textTheme
                      //       .titleMedium!
                      //       .copyWith(fontFamily: AppFont.fontMedium, fontSize: 12),
                      // ),
                      TextSpan(
                        text: "Expense added by ",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: AppFont.fontRegular, fontSize: 12),
                      ),
                      TextSpan(
                        text: expenseUserName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFamily: AppFont.fontMedium, fontSize: 12),
                      ),
                    ])),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: "Expense Date: ",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontFamily: AppFont.fontMedium, fontSize: 12),
                  ),
                  TextSpan(
                    text: expenseDate,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontFamily: AppFont.fontRegular, fontSize: 12),
                  ),
                ])),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: "Added By ",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontFamily: AppFont.fontMedium, fontSize: 12),
                  ),
                  TextSpan(
                    text:
                        "${expenseBehalfUserName.split(" ").first} on $expenseAddDate",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontFamily: AppFont.fontRegular, fontSize: 12),
                  ),
                ])),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstString.splitList,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
                Text(
                  "Total: ${userController.currencySymbol}${double.parse((expense?.amount ?? 0.0).toString()).formatAmount()}",
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontMedium,
                      fontSize: 15),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: expenseController.fetchExpense(
                  groupData!.id!, expense!.expenseId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CupertinoActivityIndicator();
                } else if (snapshot.hasData) {
                  Expense expense = snapshot.data!;
                  List<double> amounts = expenseController.getAmountsForUsers(
                      expense, groupData!.memberIds!);
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.darkPrimaryColor)),
                    child: Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupUsers.length,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 0,
                              thickness: 1,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: !groupUsers[index]!
                                                .contactNumber!
                                                .contains(controller
                                                    .loggedInUser!.mobileNo!)
                                            ? Text(
                                                userController
                                                        .getNameByPhoneNumber(
                                                            groupData!
                                                                .memberIds![
                                                                    index]
                                                                .user
                                                                .mobileNo) ??
                                                    groupData!.memberIds![index]
                                                        .user.name ??
                                                    "",
                                                textScaler:
                                                    const TextScaler.linear(1),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: groupData!
                                                                    .memberIds![
                                                                        index]
                                                                    .status ==
                                                                'left'
                                                            ? AppColors.debit
                                                            : AppColors
                                                                .darkPrimaryColor,
                                                        fontFamily:
                                                            AppFont.fontMedium),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Text(
                                                "You",
                                                textScaler:
                                                    const TextScaler.linear(1),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: groupData!
                                                                    .memberIds![
                                                                        index]
                                                                    .status ==
                                                                'left'
                                                            ? AppColors.debit
                                                            : AppColors
                                                                .darkPrimaryColor,
                                                        fontFamily:
                                                            AppFont.fontMedium),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      groupUsers[index]!.contactNumber != null
                                          ? Text(
                                              groupUsers[index]!
                                                      .contactNumber ??
                                                  'No Contact',
                                              textScaler:
                                                  const TextScaler.linear(1),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      color: groupData!
                                                                  .memberIds![
                                                                      index]
                                                                  .status ==
                                                              'left'
                                                          ? AppColors.debit
                                                          : AppColors
                                                              .darkPrimaryColor,
                                                      fontFamily:
                                                          AppFont.fontRegular),
                                            )
                                          : MyGroupNumberTextWidget(),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${userController.currencySymbol}${amounts[index].formatAmount()}",
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
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Text(
                    "No Data",
                    textScaler: const TextScaler.linear(1),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String avatarPlaceHolder(int index) {
    String? name = userController
        .getNameByPhoneNumber(groupData!.memberIds![index].user.mobileNo);
    return (name ?? groupData!.memberIds![index].user.name ?? '?')[0]
        .toUpperCase();
    /*return groupData!.memberIds![index].user.name != null
        ? groupData!.memberIds![index].user.mobileNo ==
                controller.loggedInUser!.mobileNo
            ? "Y"
            : String.fromCharCodes(
                    groupData!.memberIds![index].user.name!.runes.take(1))
                .toUpperCase()
        : "?";*/
  }
}

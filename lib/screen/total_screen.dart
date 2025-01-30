import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';

import '../utils/string.dart';

class TotalScreen extends StatefulWidget {
  final GroupDataModel? groupData;

  const TotalScreen({super.key, this.groupData});

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  List<Expense> expenses = [];

  final UserController userController = Get.find<UserController>();

  final ExpenseController expenseController = Get.find<ExpenseController>();
  final GroupController groupController = Get.find<GroupController>();

  @override
  void initState() {
    expenseController.fetchExpenses(widget.groupData!.id!).then((value) {
      setState(() {
        expenses = value;
      });
    });
    super.initState();
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
        title: Text(
          ConstString.totals,
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(width: 1, color: AppColors.darkPrimaryColor)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    ListTile(
                      onTap: null,
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.decsGrey),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: SvgPicture.asset(
                            AppIcons.groupIcon,
                            color: AppColors.darkPrimaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        ConstString.totalSpending,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.darkPrimaryColor,
                            ),
                      ),
                      trailing: Text(
                        "${userController.currencySymbol}${calculateTotalGroupSpending(expenses).formatAmount()}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.lightGreen,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 14),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: AppColors.txtGrey.withOpacity(0.2),
                      height: 7,
                    ),
                    ListTile(
                      onTap: null,
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.decsGrey),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: SvgPicture.asset(
                            AppIcons.paid_user,
                            color: AppColors.darkPrimaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        ConstString.totalPaid,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.darkPrimaryColor,
                            ),
                      ),
                      trailing: Text(
                        "${userController.currencySymbol}${calculateTotalYouPaidFor(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.debit,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 14),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: AppColors.txtGrey.withOpacity(0.2),
                      height: 7,
                    ),
                    ListTile(
                      onTap: null,
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.decsGrey),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: SvgPicture.asset(
                            AppIcons.share_user,
                            color: AppColors.darkPrimaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        ConstString.totalShare,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.darkPrimaryColor,
                            ),
                      ),
                      trailing: Text(
                        "${userController.currencySymbol}${calculateYourTotalShare(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.lightGreen,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 14),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: AppColors.txtGrey.withOpacity(0.2),
                      height: 7,
                    ),
                    ListTile(
                      onTap: null,
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.decsGrey),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: SvgPicture.asset(
                            AppIcons.receive_user,
                            color: AppColors.darkPrimaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        ConstString.paymentReceived,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.darkPrimaryColor,
                            ),
                      ),
                      trailing: Text(
                        "${userController.currencySymbol}${calculatePaymentReceived(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.debit,
                                fontFamily: AppFont.fontMedium,
                                fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateTotalGroupSpending(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return 0.0;
    }
    return expenses.fold(0.0, (total, expense) => total + expense.amount!);
  }

  double calculateTotalYouPaidFor(List<Expense> expenses, String yourUserId) {
    if (expenses.isEmpty) {
      return 0.0;
    }
    return expenses.fold(
        0.0,
        (total, expense) =>
            total +
            (expense.payerId != null &&
                    expense.payerId!.user.mobileNo == yourUserId
                ? expense.amount!
                : 0.0));
  }

  double calculateYourTotalShare(List<Expense> expenses, String yourUserId) {
    return expenses.fold(
        0.0,
        (total, expense) =>
            total +
            (expense.equality!
                    .where((equality) => equality.userId == yourUserId)
                    .isNotEmpty
                ? (expense.amount! / expense.equality!.length)
                : 0.0));
  }

  double calculatePaymentReceived(List<Expense> expenses, String yourUserId) {
    return expenses.fold(
        0.0,
        (total, expense) =>
            total +
            (expense.payerId!.user.mobileNo != yourUserId
                ? expense.equality!
                    .where((equality) => equality.userId == yourUserId)
                    .fold(0.0, (share, equality) => share + equality.amount)
                : 0.0));
  }
}

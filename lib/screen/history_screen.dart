import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_history_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/home_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/screen/expense_details.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class HistoryScreen extends GetView<ExpenseHistoryController> {
  HistoryScreen({Key? key}) : super(key: key);

  final GroupController groupController = Get.find<GroupController>();
  final UserController userController = Get.find<UserController>();
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseHistoryController>(
        // init: ExpenseHistoryController(),
        builder: (controller) {
          controller.fetchAllGroups();
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: GetBuilder<ExpenseHistoryController>(
              id: "toolbar",
              builder: (controller) {
                return controller.hasSearchEnabled.value
                    ? SizedBox(
                        height: 50,
                        child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1)),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                controller.searchExpense(value);
                              },
                              cursorColor: AppColors.txtGrey,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontFamily: AppFont.fontRegular),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  hintText: ConstString.search_expenses,
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontFamily: AppFont.fontRegular,
                                          fontSize: 14,
                                          color: AppColors.txtGrey),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      controller.closeSearchExpense();
                                    },
                                    child: Icon(
                                      Icons.close_outlined,
                                      color: AppColors.txtGrey,
                                      size: 20,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15)),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.lineGrey),
                                      borderRadius: BorderRadius.circular(15))),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                            )),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ConstString.expenseHistory,
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 22,
                                    fontFamily: AppFont.fontSemiBold,
                                    color: AppColors.darkPrimaryColor),
                          ),
                          Text(
                            ConstString.historyTitle,
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    fontFamily: AppFont.fontRegular,
                                    fontSize: 12,
                                    color: AppColors.darkPrimaryColor),
                          ),
                        ],
                      );
              }),
          actions: [
            GetBuilder<ExpenseHistoryController>(
                id: "toolbar",
                builder: (controller) {
                  return controller.hasSearchEnabled.value
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            controller.searchExpense("");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SvgPicture.asset(AppIcons.searchIcon),
                          ),
                        );
                })
          ],
        ),
        body: GetBuilder<ExpenseHistoryController>(
          id: "history",
          builder: (controller) {
            if (controller.hasSearchEnabled.value) {
              return controller.filteredExpenseData.isNotEmpty
                  ? expenseListWidget(controller.filteredExpenseData)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.intro2,
                          height: 110,
                          width: double.infinity,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          ConstString.noExpenseData,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: AppColors.darkPrimaryColor,
                                  fontSize: 15,
                                  fontFamily: AppFont.fontSemiBold),
                        ),
                      ],
                    );
            }
            return allExpenseWidget();
          },
        ),
      );
    });
  }

  Widget allExpenseWidget() {
    return FutureBuilder(
      future: homeController
          .fetchUserGroupIdsByMobile(homeController.loggedInMobileNo! ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HistoryListShimmer(itemCount: 10);
        } else if (snapshot.hasData) {
          List<String> groupIds = snapshot.data!;
          return FutureBuilder(
            future: controller.fetchExpensesByGroupIds(groupIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: HistoryListShimmer(itemCount: 10));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<Expense> expenses = snapshot.data!;

                return expenseListWidget(expenses);
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.intro2,
                      height: 150,
                      width: double.infinity,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      ConstString.noExpenseData,
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.darkPrimaryColor,
                          fontFamily: AppFont.fontSemiBold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      ConstString.noExpenseDataSentance,
                      textScaler: const TextScaler.linear(1),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          height: 1.4,
                          fontSize: 13,
                          color: AppColors.blackText,
                          fontFamily: AppFont.fontRegular),
                    ),
                  ],
                );
              }
            },
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.intro2,
                height: 150,
                width: double.infinity,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                ConstString.noExpenseData,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontSemiBold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                ConstString.noExpenseDataSentance,
                textScaler: const TextScaler.linear(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    height: 1.4,
                    fontSize: 13,
                    color: AppColors.blackText,
                    fontFamily: AppFont.fontRegular),
              ),
            ],
          );
        }
      },
    );
  }

  ListView expenseListWidget(List<Expense> expenses) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: expenses.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          thickness: 1,
          color: AppColors.lineGrey,
        );
      },
      itemBuilder: (context, index) {
        Expense expense = expenses[index];

        String? payerName = userController
                .getNameByPhoneNumber(expense.payerId?.user.mobileNo) ??
            expense.payerId?.user.name ??
            "You";


          return expenseItemWidget(expense, payerName,context);

      },
    );
  }

  Widget expenseItemWidget(
      Expense expense, String payerName,BuildContext context) {
    GroupDataModel? groupData = controller.getGroupData(expense.groupId!);
    return GestureDetector(
      onTap: () {
        Get.to(() => ExpenseDetails(
          expense: expense,
          groupData: groupData,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            expense.payerId!.user.profilePicture != null &&
                expense.payerId!.user.profilePicture!.isNotEmpty
                ? ClipOval(
              child: CachedNetworkImage(
                height: 40,
                width: 40,
                imageUrl: expense.payerId!.user.profilePicture!,
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
                : ClipOval(
                child: Container(
                    height: 40,
                    width: 40,
                    color: AppColors.darkPrimaryColor,
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                        SvgPicture.asset(AppImages.split_logo)))),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title ?? "",
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                        fontSize: 14,
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${groupData!.name} - Paid By ${payerName.split(" ").first}",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                        fontSize: 13,
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontRegular),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    DateFormat('dd MMM yyyy h:mm a')
                        .format(expense.createdAt!),
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                        fontSize: 13,
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium),
                  ),
                ],
              ),
            ),
            Text(
              "${userController.currencySymbol}${expense.amount?.formatAmount()}",
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontFamily: AppFont.fontSemiBold,
                  color: AppColors.lightGreen),
            ),
          ],
        ),
      ),
    );
  }
}

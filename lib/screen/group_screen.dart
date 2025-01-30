// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/home_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/group_data.dart';
import 'package:split/screen/add_expense_screen.dart';
import 'package:split/screen/group_details.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupController controller = Get.find<GroupController>();

  final ExpenseController expenseController = Get.put(ExpenseController());
  final UserController userController = Get.find<UserController>();
  final HomeController homeController = Get.put(HomeController());

  List<GroupDataModel> groups = [];
  StreamSubscription<List<GroupDataModel>>? groupsSubscription;
  bool isGroupLoad = false;
  String? spentBudget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchUserData().then((value) {
      groupsSubscription = controller
          .fetchActiveGroupsForUser(controller.loggedInUser!.mobileNo! ?? "")
          .listen((groupData) {
        setState(() {
          groups = groupData;
          isGroupLoad = true;
        });
      });
    });
    // loadGroups();
  }

  // loadGroups() async {
  //   groups = await controller
  //       .fetchActiveGroupsForUserFuture(controller.loggedInUser!.mobileNo!);
  //   isGroupLoad = true;
  //   setState(() {});
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    groupsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ConstString.groups,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 22,
                  fontFamily: AppFont.fontSemiBold,
                  color: AppColors.darkPrimaryColor),
            ),
            Text(
              ConstString.groupTitle,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontFamily: AppFont.fontRegular,
                  fontSize: 12,
                  color: AppColors.darkPrimaryColor),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => AddExpenseScreen(
                    isExpense: false,
                  ));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.linePrimary),
              height: 45,
              width: 45,
              child: Icon(Icons.add, color: AppColors.darkPrimaryColor),
            ),
          ),
        ],
      ),
      body: groupWidget(context),
    );
  }

  Widget groupWidget(BuildContext context) {
    return SingleChildScrollView(
      // physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.overview,
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
            Row(
              children: [
                Expanded(
                    child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: AppColors.darkPrimaryColor),
                      color: AppColors.darkPrimaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ConstString.youNeed,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontSize: 13,
                                  color: AppColors.white,
                                  fontFamily: AppFont.fontMedium),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        StreamBuilder(
                          stream: controller.fetchGroupIds(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CupertinoActivityIndicator();
                            } else if (snapshot.hasData) {
                              List<String> groupIds = snapshot.data!;
                              return StreamBuilder(
                                stream: expenseController.fetchBalancesStream(
                                    groupIds,
                                    controller.loggedInUser!.mobileNo!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    double totalNegativeBalance =
                                        snapshot.data!['negative'] ?? 0.0;
                                    return Text(
                                      "${userController.currencySymbol}${totalNegativeBalance.toPrecision(2)}",
                                      textScaler: const TextScaler.linear(1),
                                      // "- ${userController.currencySymbol}$amount",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontSize: 20,
                                              color: AppColors.white,
                                              fontFamily: AppFont.fontSemiBold),
                                    );
                                  } else {
                                    return Text(
                                      "${userController.currencySymbol}0.0",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontSize: 20,
                                              color: AppColors.white,
                                              fontFamily: AppFont.fontSemiBold),
                                    );
                                  }
                                },
                              );
                            } else {
                              return Text(
                                "${userController.currencySymbol}0.0",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 20,
                                        color: AppColors.white,
                                        fontFamily: AppFont.fontSemiBold),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: AppColors.darkPrimaryColor),
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ConstString.youGetBack,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontSize: 13,
                                  color: AppColors.white,
                                  fontFamily: AppFont.fontMedium),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        StreamBuilder(
                          stream: controller.fetchGroupIds(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CupertinoActivityIndicator();
                            } else if (snapshot.hasData) {
                              List<String> groupIds = snapshot.data!;
                              return StreamBuilder(
                                stream: expenseController.fetchBalancesStream(
                                    groupIds,
                                    controller.loggedInUser!.mobileNo!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    double totalPositiveBalance =
                                        snapshot.data!['positive'] ?? 0.0;
                                    return Text(
                                      "${userController.currencySymbol}${totalPositiveBalance.toPrecision(2)}",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontSize: 20,
                                              color: AppColors.white,
                                              fontFamily: AppFont.fontSemiBold),
                                    );
                                  } else {
                                    return Text(
                                      "${userController.currencySymbol}0.0",
                                      textScaler: const TextScaler.linear(1),
                                      // "- ${userController.currencySymbol}$amount",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontSize: 20,
                                              color: AppColors.white,
                                              fontFamily: AppFont.fontSemiBold),
                                    );
                                  }
                                },
                              );
                            } else {
                              return Text(
                                "${userController.currencySymbol}0.0",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 20,
                                        color: AppColors.white,
                                        fontFamily: AppFont.fontSemiBold),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ConstString.groupList,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => AddExpenseScreen(
                          isExpense: false,
                        ));
                  },
                  child: Text(
                    ConstString.viewAll,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontRegular,
                        fontSize: 14),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            isGroupLoad
                ? groups.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          String formattedDate =
                              DateFormat('dd MMM yy • hh:mm a')
                                  .format(groups[index].createdAt!);

                          return StreamBuilder(
                            stream: controller
                                .fetchUserStatusStream(groups[index].id!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const GroupDataShimmer(itemCount: 3);
                              } else if (snapshot.hasData) {
                                String userStatus = snapshot.data!;

                                  return Visibility(
                                    visible: userStatus != 'deleted',
                                    child: GestureDetector(
                                      onTap: () async {
                                        controller.selectGroup(groups[index]);
                                        Get.to(() => GroupDetails(
                                              groupData: groups[index],
                                            ));
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    AppColors.darkPrimaryColor,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  groups[index].groupProfile !=
                                                              null &&
                                                          groups[index]
                                                              .groupProfile!
                                                              .isNotEmpty
                                                      ? ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            height: 45,
                                                            width: 45,
                                                            imageUrl: groups[
                                                                    index]
                                                                .groupProfile!,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                            progressIndicatorBuilder:
                                                                (context, url,
                                                                        downloadProgress) =>
                                                                    SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child: Center(
                                                                  child:
                                                                      LoadingIndicator(
                                                                colors: [
                                                                  AppColors
                                                                      .primaryColor
                                                                ],
                                                                indicatorType:
                                                                    Indicator
                                                                        .ballScale,
                                                                strokeWidth: 1,
                                                              )),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 45,
                                                          width: 45,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .darkPrimaryColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: SvgPicture
                                                                .asset(AppImages
                                                                    .split_logo),
                                                          ),
                                                        ),
                                                  // : CustomGroupAvtarWidget(
                                                  //     size:
                                                  //         const Size(90, 90),
                                                  //     userMobileList:
                                                  //         groups[index]
                                                  //             .memberIds!
                                                  //             .map((e) => e
                                                  //                 .user
                                                  //                 .mobileNo)
                                                  //             .toList(),
                                                  //   ),
                                                  // const SizedBox(
                                                  //   width: 5,
                                                  // ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        groups[index].name ??
                                                            "Group $index",
                                                        textScaler:
                                                            const TextScaler
                                                                .linear(1),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontFamily: AppFont
                                                                    .fontSemiBold),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ConstString
                                                                    .estimated,
                                                                textScaler:
                                                                    const TextScaler
                                                                        .linear(
                                                                        1),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        fontFamily:
                                                                            AppFont
                                                                                .fontMedium,
                                                                        color: AppColors
                                                                            .debit),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                "${userController.currencySymbol}${groups[index].budget}",
                                                                textScaler:
                                                                    const TextScaler
                                                                        .linear(
                                                                        1),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        fontFamily:
                                                                            AppFont
                                                                                .fontMedium,
                                                                        color: AppColors
                                                                            .darkPrimaryColor),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 50,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                ConstString
                                                                    .spent,
                                                                textScaler:
                                                                    const TextScaler
                                                                        .linear(
                                                                        1),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        fontFamily:
                                                                            AppFont
                                                                                .fontMedium,
                                                                        color: AppColors
                                                                            .lightGreen),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              StreamBuilder(
                                                                stream: expenseController
                                                                    .getSpentExpenseForGroup(
                                                                        groups[index]
                                                                            .id!),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return const CupertinoActivityIndicator();
                                                                  } else if (snapshot
                                                                      .hasData) {
                                                                    double
                                                                        spentAmount =
                                                                        snapshot
                                                                            .data!;
                                                                    //TODO: Send Notification when Spent Amount is More than Group's Budget Amount
                                                                    spentBudget =
                                                                        spentAmount
                                                                            .formatAmount();
                                                                    //print('-----spentBudget----->${spentBudget}');

                                                                    return Text(
                                                                      "${userController.currencySymbol}${spentAmount.formatAmount()}",
                                                                      textScaleFactor:
                                                                          1,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleSmall!
                                                                          .copyWith(
                                                                              fontFamily: AppFont.fontMedium,
                                                                              color: AppColors.darkPrimaryColor),
                                                                    );
                                                                  } else {
                                                                    return Text(
                                                                      "${userController.currencySymbol}0.0",
                                                                      textScaleFactor:
                                                                          1,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleSmall!
                                                                          .copyWith(
                                                                              fontFamily: AppFont.fontMedium,
                                                                              color: AppColors.darkPrimaryColor),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              StreamBuilder(
                                                stream: expenseController
                                                    .getSpentExpenseForGroup(
                                                        groups[index].id!),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return DividerWidgetShimmer();
                                                  } else if (snapshot.hasData) {
                                                    double spentAmount =
                                                        snapshot.data!;
                                                    return Stack(
                                                      children: [
                                                        GFProgressBar(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          percentage: expenseController
                                                              .calculateProgress(
                                                                  spentAmount,
                                                                  double.parse(groups[
                                                                          index]
                                                                      .budget!)),
                                                          lineHeight: 12,
                                                          backgroundColor: AppColors
                                                              .darkPrimaryColor,
                                                          progressBarColor:
                                                              AppColors
                                                                  .primaryColor,
                                                        ),
                                                        const Positioned(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        6.5),
                                                            child: DottedDashedLine(
                                                                dashSpace: 7,
                                                                strokeWidth:
                                                                    1.5,
                                                                height: 0,
                                                                width: double
                                                                    .infinity,
                                                                axis: Axis
                                                                    .horizontal),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  } else {
                                                    return GFProgressBar(
                                                      padding: EdgeInsets.zero,
                                                      percentage: 0.5,
                                                      lineHeight: 10,
                                                      backgroundColor: AppColors
                                                          .darkPrimaryColor,
                                                      progressBarColor:
                                                          AppColors
                                                              .primaryColor,
                                                    );
                                                  }
                                                },
                                              ),
                                              // const SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Padding(
                                              //   padding: const EdgeInsets.symmetric(
                                              //       horizontal: 5),
                                              //   child: Row(
                                              //     mainAxisAlignment:
                                              //         MainAxisAlignment.spaceBetween,
                                              //     children: [
                                              //       Column(
                                              //         crossAxisAlignment:
                                              //             CrossAxisAlignment.start,
                                              //         children: [
                                              //           Text(
                                              //             ConstString.totalPayout,
                                              //             textScaler:
                                              //                 const TextScaler.linear(
                                              //                     1),
                                              //             style: Theme.of(context)
                                              //                 .textTheme
                                              //                 .titleSmall!
                                              //                 .copyWith(
                                              //                     color: AppColors
                                              //                         .darkPrimaryColor),
                                              //           ),
                                              //           const SizedBox(
                                              //             height: 2,
                                              //           ),
                                              //           Row(
                                              //             children: [
                                              //               SvgPicture.asset(
                                              //                 AppIcons.watchIcon,
                                              //                 height: 15,
                                              //               ),
                                              //               const SizedBox(
                                              //                 width: 5,
                                              //               ),
                                              //               Text(
                                              //                 "6 of 3 paids",
                                              //                 textScaler:
                                              //                     const TextScaler
                                              //                         .linear(1),
                                              //                 style: Theme.of(context)
                                              //                     .textTheme
                                              //                     .titleSmall!
                                              //                     .copyWith(
                                              //                         fontFamily: AppFont
                                              //                             .fontMedium,
                                              //                         color: AppColors
                                              //                             .darkPrimaryColor),
                                              //               ),
                                              //             ],
                                              //           )
                                              //         ],
                                              //       ),
                                              //       Text(
                                              //         formattedDate,
                                              //         textScaler:
                                              //             const TextScaler.linear(1),
                                              //         style: Theme.of(context)
                                              //             .textTheme
                                              //             .titleSmall!
                                              //             .copyWith(
                                              //                 color: AppColors
                                              //                     .darkPrimaryColor),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => GroupDetails(
                                          groupData: groups[index],
                                        ));
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: AppColors.darkPrimaryColor,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 20),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              groups[index].groupProfile !=
                                                          null &&
                                                      groups[index]
                                                          .groupProfile!
                                                          .isNotEmpty
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        height: 45,
                                                        width: 45,
                                                        imageUrl: groups[index]
                                                            .groupProfile!,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: Center(
                                                              child:
                                                                  LoadingIndicator(
                                                            colors: [
                                                              AppColors
                                                                  .primaryColor
                                                            ],
                                                            indicatorType:
                                                                Indicator
                                                                    .ballScale,
                                                            strokeWidth: 1,
                                                          )),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : CustomGroupAvtarWidget(
                                                      size: const Size(80, 80),
                                                      userMobileList:
                                                          groups[index]
                                                              .memberIds!
                                                              .map((e) => e.user
                                                                  .mobileNo)
                                                              .toList(),
                                                    ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    groups[index].name ??
                                                        "Group $index",
                                                    textScaler:
                                                        const TextScaler.linear(
                                                            1),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            fontFamily: AppFont
                                                                .fontSemiBold),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            ConstString
                                                                .estimated,
                                                            textScaler:
                                                                const TextScaler
                                                                    .linear(1),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall!
                                                                .copyWith(
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontMedium,
                                                                    color: AppColors
                                                                        .debit),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            "${userController.currencySymbol}${double.parse(groups[index].budget ?? '0.0').formatAmount()}",
                                                            textScaler:
                                                                const TextScaler
                                                                    .linear(1),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall!
                                                                .copyWith(
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontMedium,
                                                                    color: AppColors
                                                                        .darkPrimaryColor),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 30,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            ConstString.spent,
                                                            textScaler:
                                                                const TextScaler
                                                                    .linear(1),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall!
                                                                .copyWith(
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontMedium,
                                                                    color: AppColors
                                                                        .lightGreen),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          StreamBuilder(
                                                            stream: expenseController
                                                                .getSpentExpenseForGroup(
                                                                    groups[index]
                                                                        .id!),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const CupertinoActivityIndicator();
                                                              } else if (snapshot
                                                                  .hasData) {
                                                                double
                                                                    spentAmount =
                                                                    snapshot
                                                                        .data!;
                                                                return Text(
                                                                  "${userController.currencySymbol}${spentAmount.formatAmount()}",
                                                                  textScaleFactor:
                                                                      1,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleSmall!
                                                                      .copyWith(
                                                                          fontFamily: AppFont
                                                                              .fontMedium,
                                                                          color:
                                                                              AppColors.darkPrimaryColor),
                                                                );
                                                              } else {
                                                                return Text(
                                                                  "${userController.currencySymbol}0.0",
                                                                  textScaleFactor:
                                                                      1,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleSmall!
                                                                      .copyWith(
                                                                          fontFamily: AppFont
                                                                              .fontMedium,
                                                                          color:
                                                                              AppColors.darkPrimaryColor),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SvgPicture.asset(
                                                        AppIcons.arrow_right,
                                                        height: 20,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          StreamBuilder(
                                            stream: expenseController
                                                .getSpentExpenseForGroup(
                                                    groups[index].id!),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return DividerWidgetShimmer();
                                              } else if (snapshot.hasData) {
                                                double spentAmount =
                                                    snapshot.data!;
                                                return Stack(
                                                  children: [
                                                    GFProgressBar(
                                                      padding: EdgeInsets.zero,
                                                      percentage: expenseController
                                                          .calculateProgress(
                                                              spentAmount,
                                                              double.parse(
                                                                  groups[index]
                                                                      .budget!)),
                                                      lineHeight: 12,
                                                      backgroundColor: AppColors
                                                          .darkPrimaryColor,
                                                      progressBarColor:
                                                          AppColors
                                                              .primaryColor,
                                                    ),
                                                    const Positioned(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6.5),
                                                        child: DottedDashedLine(
                                                            dashSpace: 7,
                                                            strokeWidth: 1.5,
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            axis: Axis
                                                                .horizontal),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              } else {
                                                return GFProgressBar(
                                                  padding: EdgeInsets.zero,
                                                  percentage: 0.5,
                                                  lineHeight: 10,
                                                  backgroundColor: AppColors
                                                      .darkPrimaryColor,
                                                  progressBarColor:
                                                      AppColors.primaryColor,
                                                );
                                              }
                                            },
                                          ),
                                          // const SizedBox(
                                          //   height: 5,
                                          // ),
                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(
                                          //       horizontal: 5),
                                          //   child: Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.spaceBetween,
                                          //     children: [
                                          //       Column(
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment.start,
                                          //         children: [
                                          //           Text(
                                          //             ConstString.totalPayout,
                                          //             textScaler:
                                          //                 const TextScaler.linear(
                                          //                     1),
                                          //             style: Theme.of(context)
                                          //                 .textTheme
                                          //                 .titleSmall!
                                          //                 .copyWith(
                                          //                     color: AppColors
                                          //                         .darkPrimaryColor),
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 2,
                                          //           ),
                                          //           Row(
                                          //             children: [
                                          //               SvgPicture.asset(
                                          //                 AppIcons.watchIcon,
                                          //                 height: 15,
                                          //               ),
                                          //               const SizedBox(
                                          //                 width: 5,
                                          //               ),
                                          //               Text(
                                          //                 "6 of 3 paids",
                                          //                 textScaler:
                                          //                     const TextScaler
                                          //                         .linear(1),
                                          //                 style: Theme.of(context)
                                          //                     .textTheme
                                          //                     .titleSmall!
                                          //                     .copyWith(
                                          //                         fontFamily: AppFont
                                          //                             .fontMedium,
                                          //                         color: AppColors
                                          //                             .darkPrimaryColor),
                                          //               ),
                                          //             ],
                                          //           )
                                          //         ],
                                          //       ),
                                          //       Text(
                                          //         formattedDate,
                                          //         textScaler:
                                          //             const TextScaler.linear(1),
                                          //         style: Theme.of(context)
                                          //             .textTheme
                                          //             .titleSmall!
                                          //             .copyWith(
                                          //                 color: AppColors
                                          //                     .darkPrimaryColor),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      )
                    : SizedBox(
                        height: 400,
                        child: SafeArea(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.intro2,
                              height: 100,
                              width: double.infinity,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              ConstString.noData,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: AppColors.darkPrimaryColor,
                                      fontFamily: AppFont.fontSemiBold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              ConstString.noDataSentance,
                              textScaler: const TextScaler.linear(1),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      height: 1.4,
                                      fontSize: 13,
                                      color: AppColors.blackText,
                                      fontFamily: AppFont.fontRegular),
                            ),
                          ],
                        )),
                      )
                : GroupDataShimmer(itemCount: 3),
            // StreamBuilder(
            //   stream: controller
            //       .fetchActiveGroupsForUser(controller.loggedInUser!.mobileNo!),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const GroupDataShimmer(itemCount: 3);
            //     } else if (snapshot.hasError) {
            //       return Text(
            //         "Error : ${snapshot.error}",
            //         textScaler: const TextScaler.linear(1),
            //       );
            //     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //       List<GroupDataModel> groups = snapshot.data!;
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         physics: const NeverScrollableScrollPhysics(),
            //         itemCount: groups.length,
            //         itemBuilder: (context, index) {
            //           String formattedDate = DateFormat('dd MMM yy • hh:mm a')
            //               .format(groups[index].createdAt!);
            //           return StreamBuilder(
            //             stream:
            //                 controller.fetchUserStatusStream(groups[index].id!),
            //             builder: (context, snapshot) {
            //               if (snapshot.connectionState ==
            //                   ConnectionState.waiting) {
            //                 return const GroupDataShimmer(itemCount: 3);
            //               } else if (snapshot.hasData) {
            //                 String userStatus = snapshot.data!;
            //                 return Visibility(
            //                   visible: userStatus != 'deleted',
            //                   child: GestureDetector(
            //                     onTap: () {
            //                       Get.to(() => GroupDetails(
            //                             groupData: groups[index],
            //                           ));
            //                     },
            //                     child: Container(
            //                       margin: const EdgeInsets.only(bottom: 10),
            //                       decoration: BoxDecoration(
            //                           border: Border.all(
            //                               color: AppColors.darkPrimaryColor,
            //                               width: 1),
            //                           borderRadius: BorderRadius.circular(15)),
            //                       child: Padding(
            //                         padding: const EdgeInsets.symmetric(
            //                             horizontal: 10, vertical: 10),
            //                         child: Column(
            //                           children: [
            //                             Row(
            //                               mainAxisAlignment:
            //                                   MainAxisAlignment.spaceEvenly,
            //                               crossAxisAlignment:
            //                                   CrossAxisAlignment.start,
            //                               children: [
            //                                 groups[index].groupProfile !=
            //                                             null &&
            //                                         groups[index]
            //                                             .groupProfile!
            //                                             .isNotEmpty
            //                                     ? ClipOval(
            //                                         child: CachedNetworkImage(
            //                                           height: 45,
            //                                           width: 45,
            //                                           imageUrl: groups[index]
            //                                               .groupProfile!,
            //                                           errorWidget: (context,
            //                                                   url, error) =>
            //                                               const Icon(
            //                                                   Icons.error),
            //                                           progressIndicatorBuilder:
            //                                               (context, url,
            //                                                       downloadProgress) =>
            //                                                   SizedBox(
            //                                             width: 30,
            //                                             height: 30,
            //                                             child: Center(
            //                                                 child:
            //                                                     LoadingIndicator(
            //                                               colors: [
            //                                                 AppColors
            //                                                     .primaryColor
            //                                               ],
            //                                               indicatorType:
            //                                                   Indicator
            //                                                       .ballScale,
            //                                               strokeWidth: 1,
            //                                             )),
            //                                           ),
            //                                           fit: BoxFit.cover,
            //                                         ),
            //                                       )
            //                                     : CustomGroupAvtarWidget(
            //                                         size: const Size(90, 90),
            //                                         userMobileList:
            //                                             groups[index]
            //                                                 .memberIds!
            //                                                 .map((e) =>
            //                                                     e.user.mobileNo)
            //                                                 .toList(),
            //                                       ),
            //                                 // const SizedBox(
            //                                 //   width: 5,
            //                                 // ),
            //                                 Column(
            //                                   crossAxisAlignment:
            //                                       CrossAxisAlignment.start,
            //                                   children: [
            //                                     Text(
            //                                       groups[index].name ??
            //                                           "Group $index",
            //                                       textScaler:
            //                                           const TextScaler.linear(
            //                                               1),
            //                                       style: Theme.of(context)
            //                                           .textTheme
            //                                           .titleMedium!
            //                                           .copyWith(
            //                                               fontFamily: AppFont
            //                                                   .fontSemiBold),
            //                                     ),
            //                                     const SizedBox(
            //                                       height: 5,
            //                                     ),
            //                                     Row(
            //                                       mainAxisAlignment:
            //                                           MainAxisAlignment
            //                                               .spaceBetween,
            //                                       crossAxisAlignment:
            //                                           CrossAxisAlignment.start,
            //                                       children: [
            //                                         Column(
            //                                           crossAxisAlignment:
            //                                               CrossAxisAlignment
            //                                                   .start,
            //                                           children: [
            //                                             Text(
            //                                               ConstString.estimated,
            //                                               textScaler:
            //                                                   const TextScaler
            //                                                       .linear(1),
            //                                               style: Theme.of(
            //                                                       context)
            //                                                   .textTheme
            //                                                   .titleSmall!
            //                                                   .copyWith(
            //                                                       fontFamily:
            //                                                           AppFont
            //                                                               .fontMedium,
            //                                                       color: AppColors
            //                                                           .debit),
            //                                             ),
            //                                             const SizedBox(
            //                                               height: 5,
            //                                             ),
            //                                             Text(
            //                                               "${userController.currencySymbol}${groups[index].budget}",
            //                                               textScaler:
            //                                                   const TextScaler
            //                                                       .linear(1),
            //                                               style: Theme.of(
            //                                                       context)
            //                                                   .textTheme
            //                                                   .titleSmall!
            //                                                   .copyWith(
            //                                                       fontFamily:
            //                                                           AppFont
            //                                                               .fontMedium,
            //                                                       color: AppColors
            //                                                           .darkPrimaryColor),
            //                                             ),
            //                                           ],
            //                                         ),
            //                                         const SizedBox(
            //                                           width: 50,
            //                                         ),
            //                                         Column(
            //                                           crossAxisAlignment:
            //                                               CrossAxisAlignment
            //                                                   .end,
            //                                           children: [
            //                                             Text(
            //                                               ConstString.spent,
            //                                               textScaler:
            //                                                   const TextScaler
            //                                                       .linear(1),
            //                                               style: Theme.of(
            //                                                       context)
            //                                                   .textTheme
            //                                                   .titleSmall!
            //                                                   .copyWith(
            //                                                       fontFamily:
            //                                                           AppFont
            //                                                               .fontMedium,
            //                                                       color: AppColors
            //                                                           .lightGreen),
            //                                             ),
            //                                             const SizedBox(
            //                                               height: 5,
            //                                             ),
            //                                             StreamBuilder(
            //                                               stream: expenseController
            //                                                   .getSpentExpenseForGroup(
            //                                                       groups[index]
            //                                                           .id!),
            //                                               builder: (context,
            //                                                   snapshot) {
            //                                                 if (snapshot
            //                                                         .connectionState ==
            //                                                     ConnectionState
            //                                                         .waiting) {
            //                                                   return const CupertinoActivityIndicator();
            //                                                 } else if (snapshot
            //                                                     .hasData) {
            //                                                   double
            //                                                       spentAmount =
            //                                                       snapshot
            //                                                           .data!;
            //                                                   //TODO: Send Notification when Spent Amount is More than Group's Budget Amount
            //                                                   NotificationService
            //                                                       .instance
            //                                                       .sendTestNotification();
            //                                                   return Text(
            //                                                     "${userController.currencySymbol}${spentAmount.formatAmount()}",
            //                                                     textScaleFactor:
            //                                                         1,
            //                                                     style: Theme.of(
            //                                                             context)
            //                                                         .textTheme
            //                                                         .titleSmall!
            //                                                         .copyWith(
            //                                                             fontFamily:
            //                                                                 AppFont
            //                                                                     .fontMedium,
            //                                                             color: AppColors
            //                                                                 .darkPrimaryColor),
            //                                                   );
            //                                                 } else {
            //                                                   return Text(
            //                                                     "${userController.currencySymbol}0.0",
            //                                                     textScaleFactor:
            //                                                         1,
            //                                                     style: Theme.of(
            //                                                             context)
            //                                                         .textTheme
            //                                                         .titleSmall!
            //                                                         .copyWith(
            //                                                             fontFamily:
            //                                                                 AppFont
            //                                                                     .fontMedium,
            //                                                             color: AppColors
            //                                                                 .darkPrimaryColor),
            //                                                   );
            //                                                 }
            //                                               },
            //                                             ),
            //                                           ],
            //                                         ),
            //                                       ],
            //                                     ),
            //                                   ],
            //                                 )
            //                               ],
            //                             ),
            //                             const SizedBox(
            //                               height: 10,
            //                             ),
            //                             StreamBuilder(
            //                               stream: expenseController
            //                                   .getSpentExpenseForGroup(
            //                                       groups[index].id!),
            //                               builder: (context, snapshot) {
            //                                 if (snapshot.connectionState ==
            //                                     ConnectionState.waiting) {
            //                                   return const CupertinoActivityIndicator();
            //                                 } else if (snapshot.hasData) {
            //                                   double spentAmount =
            //                                       snapshot.data!;
            //                                   return Stack(
            //                                     children: [
            //                                       GFProgressBar(
            //                                         padding: EdgeInsets.zero,
            //                                         percentage: expenseController
            //                                             .calculateProgress(
            //                                                 spentAmount,
            //                                                 double.parse(
            //                                                     groups[index]
            //                                                         .budget!)),
            //                                         lineHeight: 12,
            //                                         backgroundColor: AppColors
            //                                             .darkPrimaryColor,
            //                                         progressBarColor:
            //                                             AppColors.primaryColor,
            //                                       ),
            //                                       const Positioned(
            //                                         child: Padding(
            //                                           padding:
            //                                               EdgeInsets.symmetric(
            //                                                   horizontal: 10,
            //                                                   vertical: 6.5),
            //                                           child: DottedDashedLine(
            //                                               dashSpace: 7,
            //                                               strokeWidth: 1.5,
            //                                               height: 0,
            //                                               width:
            //                                                   double.infinity,
            //                                               axis:
            //                                                   Axis.horizontal),
            //                                         ),
            //                                       )
            //                                     ],
            //                                   );
            //                                 } else {
            //                                   return GFProgressBar(
            //                                     padding: EdgeInsets.zero,
            //                                     percentage: 0.5,
            //                                     lineHeight: 10,
            //                                     backgroundColor:
            //                                         AppColors.darkPrimaryColor,
            //                                     progressBarColor:
            //                                         AppColors.primaryColor,
            //                                   );
            //                                 }
            //                               },
            //                             ),
            //                             // const SizedBox(
            //                             //   height: 5,
            //                             // ),
            //                             // Padding(
            //                             //   padding: const EdgeInsets.symmetric(
            //                             //       horizontal: 5),
            //                             //   child: Row(
            //                             //     mainAxisAlignment:
            //                             //         MainAxisAlignment.spaceBetween,
            //                             //     children: [
            //                             //       Column(
            //                             //         crossAxisAlignment:
            //                             //             CrossAxisAlignment.start,
            //                             //         children: [
            //                             //           Text(
            //                             //             ConstString.totalPayout,
            //                             //             textScaler:
            //                             //                 const TextScaler.linear(
            //                             //                     1),
            //                             //             style: Theme.of(context)
            //                             //                 .textTheme
            //                             //                 .titleSmall!
            //                             //                 .copyWith(
            //                             //                     color: AppColors
            //                             //                         .darkPrimaryColor),
            //                             //           ),
            //                             //           const SizedBox(
            //                             //             height: 2,
            //                             //           ),
            //                             //           Row(
            //                             //             children: [
            //                             //               SvgPicture.asset(
            //                             //                 AppIcons.watchIcon,
            //                             //                 height: 15,
            //                             //               ),
            //                             //               const SizedBox(
            //                             //                 width: 5,
            //                             //               ),
            //                             //               Text(
            //                             //                 "6 of 3 paids",
            //                             //                 textScaler:
            //                             //                     const TextScaler
            //                             //                         .linear(1),
            //                             //                 style: Theme.of(context)
            //                             //                     .textTheme
            //                             //                     .titleSmall!
            //                             //                     .copyWith(
            //                             //                         fontFamily: AppFont
            //                             //                             .fontMedium,
            //                             //                         color: AppColors
            //                             //                             .darkPrimaryColor),
            //                             //               ),
            //                             //             ],
            //                             //           )
            //                             //         ],
            //                             //       ),
            //                             //       Text(
            //                             //         formattedDate,
            //                             //         textScaler:
            //                             //             const TextScaler.linear(1),
            //                             //         style: Theme.of(context)
            //                             //             .textTheme
            //                             //             .titleSmall!
            //                             //             .copyWith(
            //                             //                 color: AppColors
            //                             //                     .darkPrimaryColor),
            //                             //       ),
            //                             //     ],
            //                             //   ),
            //                             // )
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 );
            //               } else {
            //                 return GestureDetector(
            //                   onTap: () {
            //                     Get.to(() => GroupDetails(
            //                           groupData: groups[index],
            //                         ));
            //                   },
            //                   child: Container(
            //                     margin: const EdgeInsets.symmetric(vertical: 5),
            //                     decoration: BoxDecoration(
            //                         border: Border.all(
            //                             color: AppColors.darkPrimaryColor,
            //                             width: 1),
            //                         borderRadius: BorderRadius.circular(15)),
            //                     child: Padding(
            //                       padding: const EdgeInsets.symmetric(
            //                           horizontal: 10, vertical: 20),
            //                       child: Column(
            //                         children: [
            //                           Row(
            //                             mainAxisAlignment:
            //                                 MainAxisAlignment.center,
            //                             crossAxisAlignment:
            //                                 CrossAxisAlignment.start,
            //                             children: [
            //                               groups[index].groupProfile != null &&
            //                                       groups[index]
            //                                           .groupProfile!
            //                                           .isNotEmpty
            //                                   ? ClipOval(
            //                                       child: CachedNetworkImage(
            //                                         height: 45,
            //                                         width: 45,
            //                                         imageUrl: groups[index]
            //                                             .groupProfile!,
            //                                         errorWidget: (context, url,
            //                                                 error) =>
            //                                             const Icon(Icons.error),
            //                                         progressIndicatorBuilder:
            //                                             (context, url,
            //                                                     downloadProgress) =>
            //                                                 SizedBox(
            //                                           width: 30,
            //                                           height: 30,
            //                                           child: Center(
            //                                               child:
            //                                                   LoadingIndicator(
            //                                             colors: [
            //                                               AppColors.primaryColor
            //                                             ],
            //                                             indicatorType:
            //                                                 Indicator.ballScale,
            //                                             strokeWidth: 1,
            //                                           )),
            //                                         ),
            //                                         fit: BoxFit.cover,
            //                                       ),
            //                                     )
            //                                   : CustomGroupAvtarWidget(
            //                                       size: const Size(80, 80),
            //                                       userMobileList: groups[index]
            //                                           .memberIds!
            //                                           .map((e) =>
            //                                               e.user.mobileNo)
            //                                           .toList(),
            //                                     ),
            //                               const SizedBox(
            //                                 width: 10,
            //                               ),
            //                               Column(
            //                                 crossAxisAlignment:
            //                                     CrossAxisAlignment.start,
            //                                 children: [
            //                                   Text(
            //                                     groups[index].name ??
            //                                         "Group $index",
            //                                     textScaler:
            //                                         const TextScaler.linear(1),
            //                                     style: Theme.of(context)
            //                                         .textTheme
            //                                         .titleMedium!
            //                                         .copyWith(
            //                                             fontFamily: AppFont
            //                                                 .fontSemiBold),
            //                                   ),
            //                                   const SizedBox(
            //                                     height: 5,
            //                                   ),
            //                                   Row(
            //                                     mainAxisAlignment:
            //                                         MainAxisAlignment
            //                                             .spaceBetween,
            //                                     crossAxisAlignment:
            //                                         CrossAxisAlignment.start,
            //                                     children: [
            //                                       Column(
            //                                         crossAxisAlignment:
            //                                             CrossAxisAlignment
            //                                                 .start,
            //                                         children: [
            //                                           Text(
            //                                             ConstString.estimated,
            //                                             textScaler:
            //                                                 const TextScaler
            //                                                     .linear(1),
            //                                             style: Theme.of(context)
            //                                                 .textTheme
            //                                                 .titleSmall!
            //                                                 .copyWith(
            //                                                     fontFamily: AppFont
            //                                                         .fontMedium,
            //                                                     color: AppColors
            //                                                         .debit),
            //                                           ),
            //                                           const SizedBox(
            //                                             height: 5,
            //                                           ),
            //                                           Text(
            //                                             "${userController.currencySymbol}${double.parse(groups[index].budget ?? '0.0').formatAmount()}",
            //                                             textScaler:
            //                                                 const TextScaler
            //                                                     .linear(1),
            //                                             style: Theme.of(context)
            //                                                 .textTheme
            //                                                 .titleSmall!
            //                                                 .copyWith(
            //                                                     fontFamily: AppFont
            //                                                         .fontMedium,
            //                                                     color: AppColors
            //                                                         .darkPrimaryColor),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                       const SizedBox(
            //                                         width: 30,
            //                                       ),
            //                                       Column(
            //                                         crossAxisAlignment:
            //                                             CrossAxisAlignment.end,
            //                                         children: [
            //                                           Text(
            //                                             ConstString.spent,
            //                                             textScaler:
            //                                                 const TextScaler
            //                                                     .linear(1),
            //                                             style: Theme.of(context)
            //                                                 .textTheme
            //                                                 .titleSmall!
            //                                                 .copyWith(
            //                                                     fontFamily: AppFont
            //                                                         .fontMedium,
            //                                                     color: AppColors
            //                                                         .lightGreen),
            //                                           ),
            //                                           const SizedBox(
            //                                             height: 5,
            //                                           ),
            //                                           StreamBuilder(
            //                                             stream: expenseController
            //                                                 .getSpentExpenseForGroup(
            //                                                     groups[index]
            //                                                         .id!),
            //                                             builder: (context,
            //                                                 snapshot) {
            //                                               if (snapshot
            //                                                       .connectionState ==
            //                                                   ConnectionState
            //                                                       .waiting) {
            //                                                 return const CupertinoActivityIndicator();
            //                                               } else if (snapshot
            //                                                   .hasData) {
            //                                                 double spentAmount =
            //                                                     snapshot.data!;
            //                                                 return Text(
            //                                                   "${userController.currencySymbol}${spentAmount.formatAmount()}",
            //                                                   textScaleFactor:
            //                                                       1,
            //                                                   style: Theme.of(
            //                                                           context)
            //                                                       .textTheme
            //                                                       .titleSmall!
            //                                                       .copyWith(
            //                                                           fontFamily:
            //                                                               AppFont
            //                                                                   .fontMedium,
            //                                                           color: AppColors
            //                                                               .darkPrimaryColor),
            //                                                 );
            //                                               } else {
            //                                                 return Text(
            //                                                   "${userController.currencySymbol}0.0",
            //                                                   textScaleFactor:
            //                                                       1,
            //                                                   style: Theme.of(
            //                                                           context)
            //                                                       .textTheme
            //                                                       .titleSmall!
            //                                                       .copyWith(
            //                                                           fontFamily:
            //                                                               AppFont
            //                                                                   .fontMedium,
            //                                                           color: AppColors
            //                                                               .darkPrimaryColor),
            //                                                 );
            //                                               }
            //                                             },
            //                                           ),
            //                                         ],
            //                                       ),
            //                                       const SizedBox(
            //                                         width: 10,
            //                                       ),
            //                                       SvgPicture.asset(
            //                                         AppIcons.arrow_right,
            //                                         height: 20,
            //                                       )
            //                                     ],
            //                                   ),
            //                                 ],
            //                               )
            //                             ],
            //                           ),
            //                           const SizedBox(
            //                             height: 10,
            //                           ),
            //                           StreamBuilder(
            //                             stream: expenseController
            //                                 .getSpentExpenseForGroup(
            //                                     groups[index].id!),
            //                             builder: (context, snapshot) {
            //                               if (snapshot.connectionState ==
            //                                   ConnectionState.waiting) {
            //                                 return const CupertinoActivityIndicator();
            //                               } else if (snapshot.hasData) {
            //                                 double spentAmount = snapshot.data!;
            //                                 return Stack(
            //                                   children: [
            //                                     GFProgressBar(
            //                                       padding: EdgeInsets.zero,
            //                                       percentage: expenseController
            //                                           .calculateProgress(
            //                                               spentAmount,
            //                                               double.parse(
            //                                                   groups[index]
            //                                                       .budget!)),
            //                                       lineHeight: 12,
            //                                       backgroundColor: AppColors
            //                                           .darkPrimaryColor,
            //                                       progressBarColor:
            //                                           AppColors.primaryColor,
            //                                     ),
            //                                     const Positioned(
            //                                       child: Padding(
            //                                         padding:
            //                                             EdgeInsets.symmetric(
            //                                                 horizontal: 10,
            //                                                 vertical: 6.5),
            //                                         child: DottedDashedLine(
            //                                             dashSpace: 7,
            //                                             strokeWidth: 1.5,
            //                                             height: 20,
            //                                             width: double.infinity,
            //                                             axis: Axis.horizontal),
            //                                       ),
            //                                     )
            //                                   ],
            //                                 );
            //                               } else {
            //                                 return GFProgressBar(
            //                                   padding: EdgeInsets.zero,
            //                                   percentage: 0.5,
            //                                   lineHeight: 10,
            //                                   backgroundColor:
            //                                       AppColors.darkPrimaryColor,
            //                                   progressBarColor:
            //                                       AppColors.primaryColor,
            //                                 );
            //                               }
            //                             },
            //                           ),
            //                           // const SizedBox(
            //                           //   height: 5,
            //                           // ),
            //                           // Padding(
            //                           //   padding: const EdgeInsets.symmetric(
            //                           //       horizontal: 5),
            //                           //   child: Row(
            //                           //     mainAxisAlignment:
            //                           //         MainAxisAlignment.spaceBetween,
            //                           //     children: [
            //                           //       Column(
            //                           //         crossAxisAlignment:
            //                           //             CrossAxisAlignment.start,
            //                           //         children: [
            //                           //           Text(
            //                           //             ConstString.totalPayout,
            //                           //             textScaler:
            //                           //                 const TextScaler.linear(
            //                           //                     1),
            //                           //             style: Theme.of(context)
            //                           //                 .textTheme
            //                           //                 .titleSmall!
            //                           //                 .copyWith(
            //                           //                     color: AppColors
            //                           //                         .darkPrimaryColor),
            //                           //           ),
            //                           //           const SizedBox(
            //                           //             height: 2,
            //                           //           ),
            //                           //           Row(
            //                           //             children: [
            //                           //               SvgPicture.asset(
            //                           //                 AppIcons.watchIcon,
            //                           //                 height: 15,
            //                           //               ),
            //                           //               const SizedBox(
            //                           //                 width: 5,
            //                           //               ),
            //                           //               Text(
            //                           //                 "6 of 3 paids",
            //                           //                 textScaler:
            //                           //                     const TextScaler
            //                           //                         .linear(1),
            //                           //                 style: Theme.of(context)
            //                           //                     .textTheme
            //                           //                     .titleSmall!
            //                           //                     .copyWith(
            //                           //                         fontFamily: AppFont
            //                           //                             .fontMedium,
            //                           //                         color: AppColors
            //                           //                             .darkPrimaryColor),
            //                           //               ),
            //                           //             ],
            //                           //           )
            //                           //         ],
            //                           //       ),
            //                           //       Text(
            //                           //         formattedDate,
            //                           //         textScaler:
            //                           //             const TextScaler.linear(1),
            //                           //         style: Theme.of(context)
            //                           //             .textTheme
            //                           //             .titleSmall!
            //                           //             .copyWith(
            //                           //                 color: AppColors
            //                           //                     .darkPrimaryColor),
            //                           //       ),
            //                           //     ],
            //                           //   ),
            //                           // )
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 );
            //               }
            //             },
            //           );
            //         },
            //       );
            //     } else {
            //       return SizedBox(
            //         height: 400,
            //         child: SafeArea(
            //             child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Image.asset(
            //               AppImages.intro2,
            //               height: 100,
            //               width: double.infinity,
            //             ),
            //             const SizedBox(
            //               height: 30,
            //             ),
            //             Text(
            //               ConstString.noData,
            //               textScaler: const TextScaler.linear(1),
            //               style: Theme.of(context)
            //                   .textTheme
            //                   .titleMedium!
            //                   .copyWith(
            //                       color: AppColors.darkPrimaryColor,
            //                       fontFamily: AppFont.fontSemiBold),
            //             ),
            //             const SizedBox(
            //               height: 10,
            //             ),
            //             Text(
            //               ConstString.noDataSentance,
            //               textScaler: const TextScaler.linear(1),
            //               textAlign: TextAlign.center,
            //               style: Theme.of(context)
            //                   .textTheme
            //                   .titleMedium!
            //                   .copyWith(
            //                       height: 1.4,
            //                       fontSize: 13,
            //                       color: AppColors.blackText,
            //                       fontFamily: AppFont.fontRegular),
            //             ),
            //           ],
            //         )),
            //       );
            //     }
            //   },
            // )
          ],
        ),
      ),
    );
  }
}

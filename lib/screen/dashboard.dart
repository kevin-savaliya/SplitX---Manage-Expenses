import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:split/controller/expense_history_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/home_controller.dart';
import 'package:split/horizontal_avtar_widgets.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/expense_details.dart';
import 'package:split/screen/group_details.dart';
import 'package:split/screen/notification_screen.dart';
import 'package:split/screen/settle_up_screen.dart';
import 'package:split/screen/view_split_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/shimmer_widgets.dart';
import 'package:split/widgets/user/my_name_text_widget.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GroupController groupController = Get.put(GroupController());
  HomeController controller = Get.put(HomeController());

  AppStorage appStorage = AppStorage();

  StreamSubscription<List<GroupDataModel>>? groupSubscription;
  List<GroupDataModel>? groups;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((value) {
      groupSubscription = groupController
          .fetchDashboardGroups()
          .listen((List<GroupDataModel> groups) async {
        await appStorage.setDashboardGroups(groups);
      });
    });
    _loadGroups();
  }

  void _loadGroups() async {
    var storedGroups = await appStorage.getDashboardGroups();
    setState(() {
      groups = storedGroups ?? [];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    groupSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupController>(
      init: GroupController(),
      builder: (groupController) {
        return StreamBuilder(
          stream: groupController.fetchActiveGroupsForUser(
              controller.loggedInUser.value?.mobileNo ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const HomeLoadWidgetShimmer(itemCount: 0);
            }

            if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.titleMedium,
              );
            }

            if (snapshot.data?.isEmpty ?? true) {
              return homeNoDataWidget(context);
            } else {
              return homeWidget(context, controller);
            }
          },
        );
      },
    );
  }

  Widget homeWidget(BuildContext context, HomeController controller) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        titleSpacing: 10,
        title: StreamBuilder(
          stream: controller.userController
              .streamUser(controller.userController.currentUserId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return HeaderNameWidgetShimmer(itemCount: 1);
            } else if (snapshot.hasData) {
              UserModel user = snapshot.data!;
              return Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    padding: const EdgeInsets.all(4),
                    child: UserProfileWidget(
                        size: const Size(45, 45),
                        userData: user,
                        name: user.name ?? ''),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.firebaseUser != null) ...[
                          Row(
                            children: [
                              MyNameTextWidget(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontBold,
                                        color: AppColors.darkPrimaryColor),
                              ),
                              Text(
                                " 👋",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontBold,
                                        color: AppColors.darkPrimaryColor),
                              ),
                            ],
                          )
                        ] else
                          Container(),
                        Text(
                          ConstString.homeTitle,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontFamily: AppFont.fontMedium,
                                  fontSize: 11,
                                  color: AppColors.darkPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const NotificationScreen());
              },
              icon: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset(
                  AppIcons.notificationIcon,
                ),
              ))
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ConstString.overviewGroup,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium,
                        fontSize: 15,
                      ),
                ),
              ),
            ),
            SizedBox(
              // height: 180,
              child: GetBuilder<GroupController>(
                init: GroupController(),
                builder: (controller) {
                  return StreamBuilder(
                    stream: controller.fetchActiveGroupsForUser(controller.loggedInUser?.mobileNo ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DashboardGroupWidgetShimmer(itemCount: 2);
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                      } else if (snapshot.hasData) {
                        List<GroupDataModel> groups = snapshot.data!;

                        // List<GroupDataModel>? groups =
                        //     appStorage.getDashboardGroups();
                        // print("GList : $groups");

                        return FutureBuilder<List<String?>>(
                          future: Future.wait(groups.map((group) => controller
                              .fetchUserStatusStream(group.id!)
                              .first)),
                          builder: (context, statusSnapshot) {
                            if (!statusSnapshot.hasData) {
                              return const DashboardGroupWidgetShimmer(
                                  itemCount: 2);
                            }

                            List<GroupDataModel> visibleGroups = [];
                            int addedGroupsCount = 0;
                            for (int i = 0; i < groups.length; i++) {
                              if (statusSnapshot.data![i] != 'deleted') {
                                visibleGroups.add(groups[i]);
                                addedGroupsCount++;

                              }
                            }
                            visibleGroups.reversed;
                            return buildGroupList(visibleGroups, context,controller);
                          },
                        );
                      } else {
                        return const Center(
                            child: Text("No Group Found",
                                textScaler: const TextScaler.linear(1)));
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ConstString.expenseHistory,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: AppColors.darkPrimaryColor,
                          fontFamily: AppFont.fontMedium,
                          fontSize: 15,
                        ),
                  ),
                  TextButton(
                      onPressed: () {
                        controller.pageUpdateOnHomeScreen(2);
                      },
                      child: Text(
                        ConstString.viewAll,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontRegular,
                            fontSize: 14),
                      ))
                ],
              ),
            ),
            GetBuilder<ExpenseHistoryController>(
              init: ExpenseHistoryController(),
              builder: (ExController) {
                return FutureBuilder(
                  future: controller
                      .fetchUserGroupIdsByMobile(controller.loggedInMobileNo!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const HistoryListShimmer(itemCount: 3);
                    } else if (snapshot.hasData) {
                      List<String> groupIds = snapshot.data!;
                      return FutureBuilder(
                        future: ExController.fetchDashboardExpensesByGroupIds(
                            groupIds),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: HistoryListShimmer(itemCount: 3));
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            List<Expense> expenses = snapshot.data!;
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: AppColors.darkPrimaryColor)),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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

                                  String? payerName = controller.userController
                                          .getNameByPhoneNumber(
                                              expense.payerId?.user.mobileNo) ??
                                      expense.payerId?.user.name ??
                                      "You";
                                  return StreamBuilder(
                                    stream: ExController.fetchGroupData(
                                        expense.groupId!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const HistoryWidgetShimmer(
                                            itemCount: 10);
                                      } else if (snapshot.hasData) {
                                        GroupDataModel groupData =
                                            snapshot.data!;
                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(() => ExpenseDetails(
                                                  expense: expense,
                                                  groupData: groupData,
                                                ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                expense.payerId!.user.profilePicture !=
                                                            null &&
                                                    expense.payerId!.user.profilePicture!
                                                            .isNotEmpty
                                                    ? ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 40,
                                                          width: 40,
                                                          imageUrl: expense.payerId!.user.profilePicture! ??
                                                              '',
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
                                                    : ClipOval(
                                                        child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            color: AppColors
                                                                .darkPrimaryColor,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        12.0),
                                                                child: SvgPicture
                                                                    .asset(AppImages
                                                                        .split_logo)))),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 160,
                                                      child: Text(
                                                        expense.title ?? "",
                                                        textScaler:
                                                            const TextScaler
                                                                .linear(1),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .darkPrimaryColor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontFamily: AppFont
                                                                    .fontMedium),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                      width: 160,
                                                      child: Text(
                                                        "${groupData.name} - Paid By ${payerName.split(" ").first}",
                                                        textScaler:
                                                            const TextScaler
                                                                .linear(1),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 13,
                                                                color: AppColors
                                                                    .darkPrimaryColor,
                                                                fontFamily: AppFont
                                                                    .fontRegular),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      DateFormat(
                                                              'dd MMM yyyy h:mm a')
                                                          .format(expense
                                                              .createdAt!),
                                                      textScaler:
                                                          const TextScaler
                                                              .linear(1),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color: AppColors
                                                                  .darkPrimaryColor,
                                                              fontFamily: AppFont
                                                                  .fontMedium),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                SizedBox(
                                                  child: Text(
                                                    "${controller.userController.currencySymbol}${expense.amount}",
                                                    textScaler:
                                                        const TextScaler.linear(
                                                            1),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontFamily: AppFont
                                                                .fontSemiBold,
                                                            color: AppColors
                                                                .lightGreen),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          } else {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      width: 1, color: Colors.black26)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.intro2,
                                      height: 70,
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
                                              fontSize: 14,
                                              color: AppColors.darkPrimaryColor,
                                              fontFamily: AppFont.fontSemiBold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(width: 1, color: Colors.black26)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.intro2,
                                height: 70,
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
                                        fontSize: 14,
                                        color: AppColors.darkPrimaryColor,
                                        fontFamily: AppFont.fontSemiBold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      )),
    );
  }

  Widget homeNoDataWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // elevation: 1,
        // shadowColor: AppColors.decsGrey.withOpacity(0.5),
        backgroundColor: AppColors.white,
        title: StreamBuilder(
          stream: controller.userController
              .streamUser(controller.userController.currentUserId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return HeaderNameWidgetShimmer(itemCount: 1);
            } else if (snapshot.hasData) {
              UserModel user = snapshot.data!;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: UserProfileWidget(
                        size: const Size(45, 45),
                        userData: user,
                        name: user.name ?? ''),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.firebaseUser != null) ...[
                          Row(
                            children: [
                              MyNameTextWidget(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontBold,
                                        color: AppColors.darkPrimaryColor),
                              ),
                              Text(
                                " 👋",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: AppFont.fontBold,
                                        color: AppColors.darkPrimaryColor),
                              ),
                            ],
                          )
                        ] else
                          Container(),
                        Text(
                          ConstString.homeTitle,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontFamily: AppFont.fontMedium,
                                  fontSize: 11,
                                  color: AppColors.darkPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Get.to(() => const NotificationScreen());
        //       },
        //       icon: Padding(
        //         padding: const EdgeInsets.all(5.0),
        //         child: SvgPicture.asset(
        //           AppIcons.notificationIcon,
        //         ),
        //       ))
        // ],
      ),
      body: SafeArea(
          child: Column(
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
            ConstString.noData,
            textScaler: const TextScaler.linear(1),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                height: 1.4,
                fontSize: 13,
                color: AppColors.blackText,
                fontFamily: AppFont.fontRegular),
          ),
        ],
      )),
    );
  }

  Widget buildGroupList(List<GroupDataModel> groups, BuildContext context,
      GroupController grpController) {
    return Column(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            reverse: false,
            aspectRatio: 2,
            enableInfiniteScroll: true,
            viewportFraction: groups.length > 1 ? 0.87 : 0.95,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            padEnds: true,
            animateToClosest: true,
            onPageChanged: (index, reason) {
              grpController.groupIndex.value = index;
            },
          ),
          itemCount: groups.length,
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            GroupDataModel group = groups[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.to(() => GroupDetails(groupData: group));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: groups.length == 1
                      ? MediaQuery.of(context).size.width * 0.95
                      : 300,
                  height: 180,
                  decoration: BoxDecoration(
                      color: controller.itemColorList[
                      index % controller.itemColorList.length],
                      border: Border.all(color: AppColors.darkPrimaryColor),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groups[index].name ?? "Group",
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                              fontSize: 13,
                              color: AppColors.darkPrimaryColor,
                              fontFamily: AppFont.fontMedium),
                        ),
                        Divider(
                          color: AppColors.inActive.withOpacity(0.1),
                          thickness: 1,
                          indent: 1,
                          height: 0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ConstString.total,
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
                                  height: 2,
                                ),
                                StreamBuilder(
                                  stream: controller.expenseController
                                      .getSpentExpenseForGroup(
                                      groups[index].id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CupertinoActivityIndicator();
                                    } else if (snapshot.hasData) {
                                      double totalAmount = snapshot.data!;
                                      return SizedBox(
                                        width: 130,
                                        child: Row(
                                          children: [
                                            Text(
                                              "${controller.userController.currencySymbol}",
                                              textScaler:
                                              const TextScaler.linear(1),
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                  fontSize: 22,
                                                  color: AppColors
                                                      .darkPrimaryColor,
                                                  fontFamily:
                                                  AppFont.fontSemiBold),
                                            ),
                                            Text(
                                              totalAmount.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                  fontSize: 22,
                                                  color: AppColors
                                                      .darkPrimaryColor,
                                                  fontFamily:
                                                  AppFont.fontSemiBold),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        "${controller.userController.currencySymbol} 0.0",
                                        textScaler: const TextScaler.linear(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                            fontSize: 22,
                                            color:
                                            AppColors.darkPrimaryColor,
                                            fontFamily:
                                            AppFont.fontSemiBold),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            StreamBuilder(
                              stream: controller.expenseController
                                  .fetchTotalGroupAmountForUser(
                                  groups[index].id!,
                                  controller.loggedInUser.value!.mobileNo!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                } else if (snapshot.hasData) {
                                  double payableAmount = snapshot.data!;
                                  return SizedBox(
                                    width: 120,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            payableAmount >= 0
                                                ? ConstString.youGetBack
                                                : ConstString.youNeed,
                                            textScaler:
                                            const TextScaler.linear(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                fontSize: 13,
                                                color: AppColors
                                                    .darkPrimaryColor,
                                                fontFamily:
                                                AppFont.fontMedium),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${controller.userController.currencySymbol}",
                                                textScaler:
                                                const TextScaler.linear(1),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                    fontSize: 22,
                                                    color: AppColors
                                                        .darkPrimaryColor,
                                                    fontFamily: AppFont
                                                        .fontSemiBold),
                                              ),
                                              Text(
                                                payableAmount.toStringAsFixed(2),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                    fontSize: 22,
                                                    color: AppColors
                                                        .darkPrimaryColor,
                                                    fontFamily: AppFont
                                                        .fontSemiBold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "${controller.userController.currencySymbol} 0.0",
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                        fontSize: 22,
                                        color: AppColors.darkPrimaryColor,
                                        fontFamily: AppFont.fontSemiBold),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ConstString.splitTo,
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
                                  height: 2,
                                ),
                                HorizontalAvtarWidgets(
                                  height: 25,
                                  userMobileList: groups[index]
                                      .memberIds!
                                      .map((e) => e.user.mobileNo)
                                      .toList(),
                                )
                              ],
                            ),
                            // SizedBox(
                            //   height: 33,
                            //   child: ElevatedButton(
                            //       onPressed: () async {
                            //         Get.to(() => SettleUpScreen(
                            //               groupData: group,
                            //             ));
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 10),
                            //           backgroundColor: AppColors.darkPrimaryColor,
                            //           fixedSize: const Size(90, 18),
                            //           elevation: 0,
                            //           shape: RoundedRectangleBorder(
                            //               borderRadius: BorderRadius.circular(30))),
                            //       child: Text(
                            //         ConstString.settleUp,
                            //         textScaler: const TextScaler.linear(1),
                            //         style: Theme.of(context)
                            //             .textTheme
                            //             .titleMedium!
                            //             .copyWith(
                            //                 fontSize: 14,
                            //                 color: controller.itemColorList[index %
                            //                     controller.itemColorList.length],
                            //                 fontFamily: AppFont.fontMedium),
                            //       )),
                            // ),
                            SizedBox(
                              height: 33,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    Get.to(() => ViewSplitScreen(
                                      groupData: group,
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      backgroundColor:
                                      AppColors.darkPrimaryColor,
                                      fixedSize: const Size(90, 18),
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
                                        fontSize: 14,
                                        color: controller.itemColorList[
                                        index %
                                            controller
                                                .itemColorList.length],
                                        fontFamily: AppFont.fontMedium),
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        groups.length > 1
            ? SizedBox(
          height: 10,
        )
            : SizedBox(),
        groups.length > 1
            ? Obx(() => SizedBox(
            height: 10,
            child: AnimatedSmoothIndicator(
              activeIndex: grpController.groupIndex.value,
              count: groups.length,
              curve: Curves.easeOut,
              effect: ScrollingDotsEffect(
                  maxVisibleDots: 5,
                  dotHeight: 5,
                  dotWidth: 5,
                  activeDotColor: AppColors.darkPrimaryColor),
            )))
            : SizedBox()
      ],
    );
  }
}

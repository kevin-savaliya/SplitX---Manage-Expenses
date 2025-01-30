import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/screen/record_payment_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';

class ViewSplitScreen extends StatefulWidget {
  final GroupDataModel? groupData;

  const ViewSplitScreen({super.key, this.groupData});

  @override
  State<ViewSplitScreen> createState() => _ViewSplitScreenState();
}

class _ViewSplitScreenState extends State<ViewSplitScreen> {
  List<Expense> expenses = [];

  final UserController userController = Get.find<UserController>();

  final ExpenseController expenseController = Get.find<ExpenseController>();

  final GroupController groupController = Get.find<GroupController>();

  Uint8List? listViewScreenshot;

  List<SplitTransaction> splitTransactions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expenseController.fetchExpenses(widget.groupData!.id!).then((value) {
      setState(() {
        expenses = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          FutureBuilder<List<Expense>>(
              future: expenseController.fetchExpenses(widget.groupData!.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  splitTransactions = generateSplitInformation(
                      snapshot.data ?? [],
                      groupController.loggedInUser!.mobileNo!);
                  print('splitTransactions ${splitTransactions.length}');
                  return splitBody(context, splitTransactions);
                } else {
                  return const Center(
                    child: CupertinoActivityIndicator(radius: 12),
                  );
                }
              }),
          Obx(() => Offstage(
                offstage: !groupController.isOffstageWidgetVisible.value,
                child: groupController.isOffstageWidgetVisible.value
                    ? CombinedImageWidget(
                        key: groupController.offstageKey,
                        screenshotBytes:
                            groupController.capturedScreenshotBytes ??
                                Uint8List(0),
                      )
                    : const SizedBox.shrink(),
              )),
        ],
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

  List<SplitTransaction> generateSplitInformation(
      List<Expense> expenses, String yourUserId) {
    // Calculate each user's total expenses
    List<UserExpense> userExpenses = [];
    Map<String, double> userBalances = {};

    for (Expense expense in expenses) {
      if (expense.payerId != null) {
        String payerId = expense.payerId!.user.mobileNo!;
        double totalExpense = calculateTotalExpense(expense);

        if (!userBalances.containsKey(payerId)) {
          userBalances[payerId] = 0;
        }

        userBalances[payerId] = userBalances[payerId]! - totalExpense;

        for (Equality equality in expense.equality!) {
          String userId = equality.userId;
          double amount = equality.amount;

          if (!userBalances.containsKey(userId)) {
            userBalances[userId] = 0;
          }

          userBalances[userId] = userBalances[userId]! + amount;
        }
      }
    }

    // Separate debts and credits
    List<Debt> debts = [];
    List<Debt> credits = [];

    userBalances.forEach((userId, balance) {
      if (balance < 0) {
        debts.add(Debt(userId, yourUserId, -balance));
      } else if (balance > 0) {
        credits.add(Debt(yourUserId, userId, balance));
      }
    });

    // Calculate transactions to settle debts
    List<SplitTransaction> splitTransactions = [];

    while (debts.isNotEmpty && credits.isNotEmpty) {
      Debt debtor = debts.first;
      Debt creditor = credits.first;

      double amount = min(debtor.amount, creditor.amount);

      splitTransactions.add(SplitTransaction(
        senderId: debtor.debtor,
        receiverId: creditor.creditor,
        amount: amount,
      ));

      debtor.amount -= amount;
      creditor.amount -= amount;

      if (debtor.amount == 0) {
        debts.removeAt(0);
      }

      if (creditor.amount == 0) {
        credits.removeAt(0);
      }
    }

    return splitTransactions;
  }

  double calculateTotalExpense(Expense expense) {
    double total = 0.0;

    if (expense.equality != null) {
      for (Equality equality in expense.equality!) {
        total += equality.amount;
      }
    }

    return total;
  }

  GroupMember findUserById(String userId) {
    return widget.groupData!.memberIds!
        .firstWhere((member) => member.user.mobileNo == userId);
  }

  Widget splitBody(
      BuildContext context, List<SplitTransaction> splitTransactions) {
    return splitTransactions.isNotEmpty
        ? SingleChildScrollView(
      child: Column(
        children: [
          Container(
            // height: 200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: GradientThemeColors.splitgradient,
                    tileMode: TileMode.mirror,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                    AssetImage("asset/images/split_vector.png"))),
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  forceMaterialTransparency: true,
                  backgroundColor: Colors.transparent,
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                    ConstString.viewSplit,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                        fontFamily: AppFont.fontSemiBold,
                        fontSize: 16),
                  ),
                  actions: [
                    if (groupController.firebaseUser != null)
                      IconButton(
                        onPressed: () {
                          // list is empty then return
                          if (splitTransactions.isEmpty) {
                            showInSnackBar(
                                context, 'No split data to share!');
                            return;
                          }
                          try {
                            groupController.captureAndShareList();
                            groupController
                                .toggleOffstageWidgetVisibility(false);
                          } catch (e) {
                            print(
                                "Error generating or sharing invoice: $e");
                          }
                        },
                        icon: SvgPicture.asset(AppIcons.splitIcon),
                      ),
                    SizedBox(
                      width: 5,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${userController.currencySymbol} ${calculateTotalGroupSpending(expenses).formatAmount()}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(
                      fontFamily: AppFont.fontSemiBold,
                      fontSize: 25,
                      color: AppColors.darkPrimaryColor),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Total Group Expense",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                      fontFamily: AppFont.fontMedium,
                      fontSize: 13,
                      color: AppColors.darkPrimaryColor),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            AppIcons.paid_user,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Contributions",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontRegular,
                            fontSize: 12,
                            color: AppColors.darkPrimaryColor),
                      ),
                      Text(
                        "${userController.currencySymbol} ${calculateTotalYouPaidFor(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontSemiBold,
                            fontSize: 16,
                            color: AppColors.darkPrimaryColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                            color: AppColors.purple,
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            AppIcons.share_user,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Per Person Cost",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontRegular,
                            fontSize: 12,
                            color: AppColors.darkPrimaryColor),
                      ),
                      Text(
                        "${userController.currencySymbol} ${calculateYourTotalShare(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontSemiBold,
                            fontSize: 16,
                            color: AppColors.darkPrimaryColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                            color: AppColors.credit,
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            AppIcons.receive_user,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Amount Settled",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontRegular,
                            fontSize: 12,
                            color: AppColors.darkPrimaryColor),
                      ),
                      Text(
                        "${userController.currencySymbol} ${calculatePaymentReceived(expenses, groupController.loggedInUser!.mobileNo!).formatAmount()}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            fontFamily: AppFont.fontSemiBold,
                            fontSize: 16,
                            color: AppColors.darkPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Payment Summary",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(
                    fontFamily: AppFont.fontSemiBold,
                    color: AppColors.darkPrimaryColor,
                    fontSize: 15),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: splitTransactions.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex:1,
                          child: Column(
                            children: [
                              FutureBuilder(
                                future: userController
                                    .fetchUserProfilePicture(
                                    splitTransactions[index]
                                        .receiverId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: LoadingIndicator(
                                        colors: [AppColors.primaryColor],
                                        indicatorType:
                                        Indicator.ballScale,
                                        strokeWidth: 1,
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return ClipOval(
                                      child: CachedNetworkImage(
                                        height: 40,
                                        width: 40,
                                        imageUrl: snapshot.data ?? '',
                                        errorWidget:
                                            (context, url, error) =>
                                        const Icon(Icons.error),
                                        progressIndicatorBuilder:
                                            (context, url,
                                            downloadProgress) =>
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Center(
                                                  child: LoadingIndicator(
                                                    colors: [
                                                      AppColors.primaryColor
                                                    ],
                                                    indicatorType:
                                                    Indicator.ballScale,
                                                    strokeWidth: 1,
                                                  )),
                                            ),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return ClipOval(
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            color: AppColors
                                                .darkPrimaryColor,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    12.0),
                                                child: SvgPicture.asset(
                                                    AppImages
                                                        .split_logo))));
                                  }
                                },
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                getSplitReceiverName(
                                    splitTransactions[index]),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                    fontFamily: AppFont.fontMedium,overflow: TextOverflow.ellipsis,
                                    fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  dashColor: AppColors.txtGrey
                                      .withOpacity(0.5),
                                  lineThickness: 1,
                                  dashLength: 3,
                                  dashGapLength: 2,
                                  lineLength: 200,
                                  alignment: WrapAlignment.center,
                                ),
                                Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          SvgPicture.asset(
                                              AppIcons
                                                  .arrow2_icon),
                                          Text(
                                            "${userController.currencySymbol} ${splitTransactions[index].amount.formatAmount()}",
                                            style: Theme.of(
                                                context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                color: AppColors
                                                    .darkPrimaryColor,
                                                fontFamily:
                                                AppFont
                                                    .fontMedium),
                                          ),
                                          SvgPicture.asset(
                                              AppIcons
                                                  .arrow2_icon),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            StreamBuilder(
                              stream: expenseController
                                  .fetchTotalGroupAmountForUser(
                                  widget.groupData!.id!,
                                  splitTransactions[index]
                                      .receiverId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CupertinoActivityIndicator();
                                } else if (snapshot.hasData) {
                                  double amount = snapshot.data!;
                                  return Text(
                                    "Total Spending ${userController.currencySymbol} ${amount.toStringAsFixed(2)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                        color: AppColors.arrGrey,
                                        fontSize: 12),
                                  );
                                } else {
                                  return Text(
                                    "Total Spending \$ 0.00",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                        color: AppColors.arrGrey,
                                        fontSize: 12),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                        Expanded(flex:1,
                          child: Column(
                            children: [
                              FutureBuilder(
                                future: userController
                                    .fetchUserProfilePicture(
                                    splitTransactions[index]
                                        .senderId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: LoadingIndicator(
                                        colors: [AppColors.primaryColor],
                                        indicatorType:
                                        Indicator.ballScale,
                                        strokeWidth: 1,
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return ClipOval(
                                      child: CachedNetworkImage(
                                        height: 40,
                                        width: 40,
                                        imageUrl: snapshot.data ?? '',
                                        errorWidget:
                                            (context, url, error) =>
                                        const Icon(Icons.error),
                                        progressIndicatorBuilder:
                                            (context, url,
                                            downloadProgress) =>
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Center(
                                                  child: LoadingIndicator(
                                                    colors: [
                                                      AppColors.primaryColor
                                                    ],
                                                    indicatorType:
                                                    Indicator.ballScale,
                                                    strokeWidth: 1,
                                                  )),
                                            ),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return ClipOval(
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            color: AppColors
                                                .darkPrimaryColor,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    12.0),
                                                child: SvgPicture.asset(
                                                    AppImages
                                                        .split_logo))));
                                  }
                                },
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                getUserName(splitTransactions[index]),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                    fontFamily: AppFont.fontMedium,overflow: TextOverflow.ellipsis,
                                    fontSize: 13),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    )
        : SafeArea(
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
        ));
  }

  String getSplitReceiverName(SplitTransaction splitTransaction) {
    return userController
        .getSplitNameByPhoneNumber(splitTransaction.receiverId)!
        .split(" ")
        .first ??
        findUserById(splitTransaction.receiverId).user.name!.split(" ").first ??
        "";
  }

  String getUserName(SplitTransaction splitTransaction) {
    return userController
        .getSplitNameByPhoneNumber(splitTransaction.senderId)!
        .split(" ")
        .first ??
        findUserById(splitTransaction.senderId).user.name ??
        "";
  }
}

class CombinedImageWidget extends StatelessWidget {
  final Uint8List screenshotBytes;
  final GlobalKey key;

  CombinedImageWidget({required this.key, required this.screenshotBytes})
      : super(key: key) {
    print("CombinedImageWidget created with key: $key");
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: key,
      child: SingleChildScrollView(
        child: Container(
          color: AppColors.white,
          child: Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                decoration: BoxDecoration(color: AppColors.white, boxShadow: [
                  BoxShadow(
                    color: AppColors.lightGrey.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 5,
                    offset: const Offset(1, 1),
                  ),
                ]),
                child: Image.memory(
                  screenshotBytes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplitTransaction {
  String senderId;
  String receiverId;
  double amount;

  SplitTransaction({
    required this.senderId,
    required this.receiverId,
    required this.amount,
  });
}

class UserExpense {
  String userId;
  double totalExpense;

  UserExpense(this.userId, this.totalExpense);
}

class Debt {
  String debtor;
  String creditor;
  double amount;

  Debt(this.debtor, this.creditor, this.amount);
}

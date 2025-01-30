import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/user/my_number_text_widget.dart';
import 'package:split/widgets/user/my_profile_widget.dart';

import '../model/usermodel.dart';
import 'record_payment_screen.dart';

class SettleUpScreen extends StatefulWidget {
  final GroupDataModel? groupData;

  const SettleUpScreen({super.key, this.groupData});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final UserController userController = Get.find<UserController>();

  final ExpenseController expenseController = Get.put(ExpenseController());

  final GroupController groupController = Get.find<GroupController>();

  List<ContactModel?> groupUsers = [];

  @override
  Widget build(BuildContext context) {
    groupUsers = expenseController.getContactDataByNumbers(widget
        .groupData!.memberIds!
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
          ConstString.settleUp,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: FutureBuilder(
        future: expenseController.fetchExpenses(widget.groupData!.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Expense> expenses = snapshot.data!;

            List<UserTransaction> transactions = settleExpenses(expenses);

            Set<String> userIds = <String>{};
            for (var transaction in transactions) {
              userIds.add(transaction.debtorUserId);
              userIds.add(transaction.creditorUserId);
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  ...getData(expenses)

                ],
              ),
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
                  ConstString.noExpenseToSettle,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontSemiBold),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  String get getMyMobileNo => groupController.loggedInUser!.mobileNo!;

  List<UserTransaction> settleExpenses(List<Expense> expenses) {
    // Step 1: Calculate each user's total contribution and fair share
    Map<String, double> contributions = {};

    for (var expense in expenses) {
      var payerId = expense.payerId!.user.mobileNo!;
      var amount = expense.amount!;
      contributions.update(payerId, (value) => value + amount,
          ifAbsent: () => amount);
    }

    // Step 2: Calculate fair share for each user
    double totalExpenses =
    contributions.values.reduce((sum, amount) => sum + amount);
    double fairShare = totalExpenses / contributions.length;

    // Step 3: Generate creditor-debtor pairs
    List<UserTransaction> transactions = [];

    contributions.forEach((debtorUserId, amount) {
      if (amount > fairShare) {
        transactions.add(UserTransaction(
          debtorUserId: debtorUserId,
          creditorUserId: 'group',
          amount: amount - fairShare,
        ));
      } else if (amount < fairShare) {
        transactions.add(UserTransaction(
          debtorUserId: 'group',
          creditorUserId: debtorUserId,
          amount: fairShare - amount,
        ));
      }
    });

    return transactions;
  }

  List<UserTransaction> settleUp(List<UserTransaction> transactions) {
    List<UserTransaction> settlements = [];

    Set<String> userIds = transactions.fold(<String>{}, (set, transaction) {
      set.add(transaction.debtorUserId);
      set.add(transaction.creditorUserId);
      return set;
    });

    List<String> sortedUserIds = userIds.toList()..sort();

    for (var debtorUserId in sortedUserIds) {
      double totalOwed = transactions
          .where((t) => t.debtorUserId == debtorUserId)
          .map((t) => t.amount)
          .fold(0, (sum, amount) => sum + amount);

      for (var creditorUserId in sortedUserIds) {
        if (creditorUserId != debtorUserId) {
          double totalReceived = transactions
              .where((t) => t.creditorUserId == creditorUserId)
              .map((t) => t.amount)
              .fold(0, (sum, amount) => sum + amount);

          if (totalOwed > 0 && totalReceived > 0) {
            double settlementAmount =
            totalOwed < totalReceived ? totalOwed : totalReceived;
            settlements.add(UserTransaction(
              debtorUserId: debtorUserId,
              creditorUserId: creditorUserId,
              amount: settlementAmount,
            ));

            totalOwed -= settlementAmount;
            totalReceived -= settlementAmount;
          }
        }
      }
    }

    return settlements;
  }

  void settleAmounts(
      Map<String, double> balances, Map<String, String> userNames) {
    for (MapEntry<String, double> entry in balances.entries) {
      String userId = entry.key;
      double balance = entry.value;

      if (balance > 0) {
        print('${userNames[userId]} owes \$$balance. \nSettle up:');

        for (MapEntry<String, double> subEntry in balances.entries) {
          String otherUserId = subEntry.key;
          double otherBalance = subEntry.value;

          if (otherBalance < 0) {
            double settlementAmount = otherBalance.abs().clamp(0, balance);
            if (settlementAmount > 0) {
              print(
                  '  - ${userNames[userId]} pays \$$settlementAmount to ${userNames[otherUserId]}.');
              balance -= settlementAmount;
              otherBalance += settlementAmount;

              // Update balances
              balances[userId] = balance;
              balances[otherUserId] = otherBalance;
            }
          }
        }

        if (balance > 0) {
          print('${userNames[userId]} still owes \$$balance.');
        }
      }
    }
  }

  Widget settleUpWidget(BuildContext context, List<Expense> expenses) {
    List<UserTransaction> transactions =
    expenseController.settleGroupExpenses(expenses, groupUsers.length);
    return groupUsers.isNotEmpty
        ? transactions.isNotEmpty
        ? SingleChildScrollView(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.whichBalance,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(
                    fontFamily: AppFont.fontMedium, fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border:
                  Border.all(color: AppColors.darkPrimaryColor)),
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
                  UserTransaction transaction = transactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        groupUsers[index]!.contactNumber !=
                            groupController.loggedInUser!.mobileNo
                            ? CircleAvatar(
                          radius: 20,
                          backgroundColor:
                          AppColors.primaryColor,
                          child: Text(
                            groupUsers[index]!.contactName !=
                                null
                                ? String.fromCharCodes(
                                groupUsers[index]!
                                    .contactName!
                                    .runes
                                    .take(1))
                                .toUpperCase()
                                : "?",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                color: AppColors
                                    .darkPrimaryColor,
                                fontFamily:
                                AppFont.fontSemiBold,
                                fontSize: 17),
                          ),
                        )
                            : MyGroupProfileWidget(),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: groupUsers[index]!.contactName !=
                                  null
                                  ? Text(
                                groupUsers[index]!
                                    .contactName ??
                                    "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                    fontSize: 14,
                                    color: AppColors
                                        .darkPrimaryColor,
                                    fontFamily:
                                    AppFont.fontMedium),
                                overflow: TextOverflow.ellipsis,
                              )
                                  : Text(
                                "You",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                    fontSize: 14,
                                    color: AppColors
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                  fontSize: 12,
                                  color: AppColors
                                      .darkPrimaryColor,
                                  fontFamily:
                                  AppFont.fontRegular),
                            )
                                : MyGroupNumberTextWidget(),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          "${userController.currencySymbol} ${transaction.amount.formatAmount()}",
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
            ),
          ],
        ),
      ),
    )
        : Column(
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
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.darkPrimaryColor,
              fontFamily: AppFont.fontSemiBold),
        ),
      ],
    )
        : Column(
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
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.darkPrimaryColor,
              fontFamily: AppFont.fontSemiBold),
        ),
      ],
    );
  }

  Map<String, double> calculateBalances(List<Expense> expenses) {
    Map<String, double> balances = {};

    for (Expense expense in expenses) {
      String payerId = expense.payerId!.user.mobileNo!;
      double amountPaid = expense.amount ?? 0.0;

      // Initialize the payer's balance if not already done
      balances[payerId] = balances.putIfAbsent(payerId, () => 0.0);

      // Iterate over the equality array to calculate each user's share
      for (Equality share in (expense.equality ?? [])) {
        String userId = share.userId;
        double userShare = share.amount;

        // Decrease the payer's balance
        balances[payerId] = (balances[payerId]! - userShare);

        // Increase each owing user's balance
        balances[userId] = balances.putIfAbsent(userId, () => 0.0) + userShare;
      }
    }

    return balances;
  }

  List<Widget> getData(List<Expense> expenses) {
    final balances = calculateBalances(expenses);
    // Get transactions to settle up
    List<Transaction> _transactions = settleUp1(balances);

    String myMobileNo = groupController.loggedInUser!.mobileNo!;
    List<Transaction> transactions = [];
    List<Transaction> data = _transactions
        .where((element) => (element.toUserId == myMobileNo ||
        element.fromUserId == myMobileNo))
        .toList();
    transactions
        .addAll(data.where((element) => element.toUserId == myMobileNo));

    // Transaction? myTransaction = transactions
    //     .firstWhereOrNull((element) => myMobileNo == element.toUserId);
    // if (myTransaction == null) {
    //   return [Container()];
    // }

    if (transactions.isEmpty) {
      return [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.intro2,
                height: 120,
                width: double.infinity,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                ConstString.noExpenseToSettle,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontSemiBold),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          ConstString.whichBalance,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontMedium, fontSize: 15),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: transactions
              .where((element) => element.toUserId == myMobileNo)
              .toList()
              .length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];

            print("Creditor : ${transaction.toUserId}");
            print("Debtor : ${transaction.fromUserId}");
            UserModel? creditorUser =
            userController.getUserData(transaction.toUserId);
            print("CUser : $creditorUser");
            UserModel? debtorUser =
            userController.getUserData(transaction.fromUserId);
            print("DUser : $debtorUser");

            debtorUser ??=
                userController.getUserDataAnyway(transaction.fromUserId);
            creditorUser ??=
                userController.getUserDataAnyway(transaction.toUserId);

            return transaction.toUserId == myMobileNo
                ? InkWell(
              onTap: () {
                if (widget.groupData != null &&
                    creditorUser != null &&
                    debtorUser != null) {
                  Get.to(() => RecordPaymentScreen(
                    groupData: widget.groupData!,
                    amountToPay: transaction.amount.roundToDouble(),
                    creditorUser: debtorUser!,
                    debtorUser: creditorUser!,
                  ));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: AppColors.darkPrimaryColor)),
                child: Row(
                  children: [
                    getUserImageWidget(transaction.toUserId != myMobileNo,
                        creditorUser, debtorUser),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          getName(transaction.toUserId != myMobileNo,
                              creditorUser, debtorUser),
                          style: TextStyle(
                            fontFamily: AppFont.fontRegular,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.toUserId != myMobileNo
                              ? 'Owes you'
                              : 'You need to pay',
                          style: TextStyle(
                            fontSize: 13,
                            color: transaction.toUserId != myMobileNo
                                ? AppColors.credit
                                : AppColors.debit,
                            fontFamily: AppFont.fontRegular,
                          ),
                        ),
                        Text(
                          '${userController.currencySymbol} ${transaction.amount.roundToDouble().formatAmount()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: transaction.toUserId != myMobileNo
                                ? AppColors.credit
                                : AppColors.debit,
                            fontFamily: AppFont.fontMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
                : SizedBox();
          },
        ),
      ),
    ];
  }

  ImageWidget getUserImageWidget(
      bool isCreditor, UserModel? creditorUser, UserModel? debtorUser) {
    if (isCreditor) {
      return ImageWidget(
        creditorUser?.profilePicture ?? '',
        50,
        50,
        userName: creditorUser?.name ?? '',
        shouldShowUserName: true,
      );
    }
    return ImageWidget(
      debtorUser?.profilePicture ?? '',
      50,
      50,
      userName: debtorUser?.name ?? '',
      shouldShowUserName: true,
    );
  }

  String getName(
      bool isCreditor, UserModel? creditorUser, UserModel? debtorUser) {
    if (isCreditor) {

      return (creditorUser != null && creditorUser.name != null)
          ? creditorUser.name.toString()
          : (creditorUser?.mobileNo).toString();
    }
    return (debtorUser != null && debtorUser.name != null)
        ? debtorUser.name.toString()
        : (debtorUser?.mobileNo).toString();
  }

  List<Transaction> settleUp1(Map<String, double> balances) {
    List<Transaction> transactions = [];

    while (true) {
      // Find the largest debtor and creditor
      String maxDebtor =
      balances.keys.firstWhere((k) => balances[k]! < 0, orElse: () => '');
      String maxCreditor =
      balances.keys.firstWhere((k) => balances[k]! > 0, orElse: () => '');

      if (maxDebtor.isEmpty || maxCreditor.isEmpty) {
        break; // Break if no more debtors or creditors
      }

      double minAmount = min(-balances[maxDebtor]!, balances[maxCreditor]!);
      transactions.add(Transaction(
          fromUserId: maxDebtor, toUserId: maxCreditor, amount: minAmount));

      // Update the balances
      balances[maxDebtor] = balances[maxDebtor]! + minAmount;
      balances[maxCreditor] = balances[maxCreditor]! - minAmount;

      // Remove the debtor or creditor from the map if their balance is zero
      if (balances[maxDebtor] == 0) {
        balances.remove(maxDebtor);
      }
      if (balances[maxCreditor] == 0) {
        balances.remove(maxCreditor);
      }
    }

    return transactions;
  }
}

class Transaction {
  String fromUserId;
  String toUserId;
  double amount;

  Transaction(
      {required this.fromUserId, required this.toUserId, required this.amount});
}


// class SettleUpScreen extends StatefulWidget {
//   final GroupDataModel? groupData;
//
//   const SettleUpScreen({super.key, this.groupData});
//
//   @override
//   State<SettleUpScreen> createState() => _SettleUpScreenState();
// }
//
// class _SettleUpScreenState extends State<SettleUpScreen> {
//   final UserController userController = Get.find<UserController>();
//
//   final ExpenseController expenseController = Get.put(ExpenseController());
//
//   final GroupController groupController = Get.find<GroupController>();
//
//   List<ContactModel?> groupUsers = [];
//
//   @override
//   Widget build(BuildContext context) {
//     groupUsers = expenseController.getContactDataByNumbers(widget
//         .groupData!.memberIds!
//         .where((element) => element.user.mobileNo != null)
//         .map((e) => e.user.mobileNo!)
//         .toList());
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         elevation: 1,
//         shadowColor: AppColors.decsGrey.withOpacity(0.5),
//         backgroundColor: AppColors.white,
//         centerTitle: false,
//         leading: GestureDetector(
//           onTap: () {
//             Get.back();
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: SvgPicture.asset(
//               AppIcons.back_icon,
//             ),
//           ),
//         ),
//         titleSpacing: -10,
//         title: Text(
//           ConstString.settleUp,
//           style: Theme.of(context)
//               .textTheme
//               .titleMedium!
//               .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
//         ),
//       ),
//       body: FutureBuilder(
//         future: expenseController.fetchExpenses(widget.groupData!.id!),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CupertinoActivityIndicator());
//           } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//             List<Expense> expenses = snapshot.data!;
//
//             List<UserTransaction> transactions = settleExpenses(expenses);
//
//             Set<String> userIds = <String>{};
//             for (var transaction in transactions) {
//               userIds.add(transaction.debtorUserId);
//               userIds.add(transaction.creditorUserId);
//             }
//
//             List<UserTransaction> settlements = settleUp(transactions);
//
//             // Sort user IDs alphabetically
//             List<String> sortedUserIds =
//                 userIds.where((element) => element != 'group').toList()..sort();
//
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//               child: Column(
//                 children: [
//                   /*Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(color: AppColors.darkPrimaryColor)),
//                     child: ListView.separated(
//                       itemCount: sortedUserIds.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         String userId = sortedUserIds[index];
//                         double totalOwed = transactions
//                             .where((t) => t.debtorUserId == userId)
//                             .map((t) => t.amount)
//                             .fold(0, (sum, amount) => sum + amount);
//
//                         double totalReceived = transactions
//                             .where((t) => t.creditorUserId == userId)
//                             .map((t) => t.amount)
//                             .fold(0, (sum, amount) => sum + amount);
//                         UserModel? userData =
//                             userController.getUserData(userId);
//                         return InkWell(
//                           onTap: () {
//                             // FIXME: record a payment Vijay
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 8),
//                             child: Row(
//                               children: [
//                                 ImageWidget(
//                                   userData?.profilePicture ?? '',
//                                   50,
//                                   50,
//                                   userName: userData?.name ?? '',
//                                   shouldShowUserName: true,
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 5),
//                                     child: Text(
//                                       (userData?.name != null)
//                                           ? userData!.name!
//                                           : userData == null
//                                               ? userId
//                                               : userData.mobileNo!,
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       totalOwed > 0
//                                           ? 'Owes you'
//                                           : 'You need to pay',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: totalOwed > 0
//                                             ? AppColors.credit
//                                             : AppColors.debit,
//                                       ),
//                                     ),
//                                     Text(
//                                       '${userController.currencySymbol}${(totalOwed > 0 ? totalOwed : totalReceived).formatAmount()}',
//                                       style: TextStyle(
//                                           fontSize: 19,
//                                           color: totalOwed > 0
//                                               ? AppColors.credit
//                                               : AppColors.debit,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                       separatorBuilder: (BuildContext context, int index) {
//                         return Divider(
//                           height: 0,
//                           thickness: 1,
//                           color: AppColors.lineGrey,
//                         );
//                       },
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                     ),
//                   ),*/
//
//                   ...getData(expenses)
//
//                   /*Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(color: AppColors.darkPrimaryColor),
//                     ),
//                     child: ListView.separated(
//                       itemCount: settlements.where((element) {
//                         if (element.creditorUserId == 'group' ||
//                             element.debtorUserId == 'group') {
//                           return false;
//                         }
//                         return (element.creditorUserId == getMyMobileNo ||
//                             element.debtorUserId == getMyMobileNo);
//                       }).length,
//                       shrinkWrap: true,
//                       padding: EdgeInsets.zero,
//                       itemBuilder: (context, index) {
//                         UserTransaction settlement = settlements[index];
//                         UserModel? debtorUser =
//                             userController.getUserData(settlement.debtorUserId);
//                         UserModel? creditorUser = userController
//                             .getUserData(settlement.creditorUserId);
//
//                         return InkWell(
//                           onTap: () {
//                             if (widget.groupData != null &&
//                                 creditorUser != null &&
//                                 debtorUser != null) {
//                               Get.to(() => RecordPaymentScreen(
//                                     groupData: widget.groupData!,
//                                     amountToPay: settlement.amount,
//                                     creditorUser: debtorUser,
//                                     debtorUser: creditorUser,
//                                   ));
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 8),
//                             child: Row(
//                               children: [
//                                 ImageWidget(
//                                   debtorUser?.profilePicture ?? '',
//                                   50,
//                                   50,
//                                   userName: debtorUser?.name ?? '',
//                                   shouldShowUserName: true,
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 5),
//                                     child: Text(
//                                       (debtorUser != null &&
//                                               debtorUser.name != null)
//                                           ? debtorUser.name.toString()
//                                           : (debtorUser?.mobileNo).toString(),
//                                       style: TextStyle(
//                                         fontFamily: AppFont.fontRegular,
//                                         fontWeight: FontWeight.w400,
//                                         color: AppColors.black,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       settlement.amount < 0
//                                           ? 'Owes you'
//                                           : 'You need to pay',
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: settlement.amount < 0
//                                             ? AppColors.credit
//                                             : AppColors.debit,
//                                         fontFamily: AppFont.fontRegular,
//                                       ),
//                                     ),
//                                     Text(
//                                       '${userController.currencySymbol}${settlement.amount.formatAmount()}',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: settlement.amount < 0
//                                             ? AppColors.credit
//                                             : AppColors.debit,
//                                         fontFamily: AppFont.fontMedium,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                       separatorBuilder: (BuildContext context, int index) {
//                         return Divider(
//                           height: 0,
//                           thickness: 1,
//                           color: AppColors.lineGrey,
//                         );
//                       },
//                     ),
//                   ),*/
//                   ,
//                   Spacer(),
//                 ],
//               ),
//             );
//             // return settleUpWidget(context, expenses);
//           } else {
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   AppImages.intro2,
//                   height: 150,
//                   width: double.infinity,
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Text(
//                   ConstString.noExpenseToSettle,
//                   style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                       color: AppColors.darkPrimaryColor,
//                       fontFamily: AppFont.fontSemiBold),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   String get getMyMobileNo => groupController.loggedInUser!.mobileNo!;
//
//   List<UserTransaction> settleExpenses(List<Expense> expenses) {
//     // Step 1: Calculate each user's total contribution and fair share
//     Map<String, double> contributions = {};
//
//     for (var expense in expenses) {
//       var payerId = expense.payerId!.user.mobileNo!;
//       var amount = expense.amount!;
//       contributions.update(payerId, (value) => value + amount,
//           ifAbsent: () => amount);
//     }
//
//     // Step 2: Calculate fair share for each user
//     double totalExpenses =
//         contributions.values.reduce((sum, amount) => sum + amount);
//     double fairShare = totalExpenses / contributions.length;
//
//     // Step 3: Generate creditor-debtor pairs
//     List<UserTransaction> transactions = [];
//
//     contributions.forEach((debtorUserId, amount) {
//       if (amount > fairShare) {
//         transactions.add(UserTransaction(
//           debtorUserId: debtorUserId,
//           creditorUserId: 'group',
//           amount: amount - fairShare,
//         ));
//       } else if (amount < fairShare) {
//         transactions.add(UserTransaction(
//           debtorUserId: 'group',
//           creditorUserId: debtorUserId,
//           amount: fairShare - amount,
//         ));
//       }
//     });
//
//     return transactions;
//   }
//
//   List<UserTransaction> settleUp(List<UserTransaction> transactions) {
//     List<UserTransaction> settlements = [];
//
//     Set<String> userIds = transactions.fold(<String>{}, (set, transaction) {
//       set.add(transaction.debtorUserId);
//       set.add(transaction.creditorUserId);
//       return set;
//     });
//
//     List<String> sortedUserIds = userIds.toList()..sort();
//
//     for (var debtorUserId in sortedUserIds) {
//       double totalOwed = transactions
//           .where((t) => t.debtorUserId == debtorUserId)
//           .map((t) => t.amount)
//           .fold(0, (sum, amount) => sum + amount);
//
//       for (var creditorUserId in sortedUserIds) {
//         if (creditorUserId != debtorUserId) {
//           double totalReceived = transactions
//               .where((t) => t.creditorUserId == creditorUserId)
//               .map((t) => t.amount)
//               .fold(0, (sum, amount) => sum + amount);
//
//           if (totalOwed > 0 && totalReceived > 0) {
//             double settlementAmount =
//                 totalOwed < totalReceived ? totalOwed : totalReceived;
//             settlements.add(UserTransaction(
//               debtorUserId: debtorUserId,
//               creditorUserId: creditorUserId,
//               amount: settlementAmount,
//             ));
//
//             totalOwed -= settlementAmount;
//             totalReceived -= settlementAmount;
//           }
//         }
//       }
//     }
//
//     return settlements;
//   }
//
//   void settleAmounts(
//       Map<String, double> balances, Map<String, String> userNames) {
//     for (MapEntry<String, double> entry in balances.entries) {
//       String userId = entry.key;
//       double balance = entry.value;
//
//       if (balance > 0) {
//         print('${userNames[userId]} owes \$$balance. \nSettle up:');
//
//         for (MapEntry<String, double> subEntry in balances.entries) {
//           String otherUserId = subEntry.key;
//           double otherBalance = subEntry.value;
//
//           if (otherBalance < 0) {
//             double settlementAmount = otherBalance.abs().clamp(0, balance);
//             if (settlementAmount > 0) {
//               print(
//                   '  - ${userNames[userId]} pays \$$settlementAmount to ${userNames[otherUserId]}.');
//               balance -= settlementAmount;
//               otherBalance += settlementAmount;
//
//               // Update balances
//               balances[userId] = balance;
//               balances[otherUserId] = otherBalance;
//             }
//           }
//         }
//
//         if (balance > 0) {
//           print('${userNames[userId]} still owes \$$balance.');
//         }
//       }
//     }
//   }
//
//   Widget settleUpWidget(BuildContext context, List<Expense> expenses) {
//     List<UserTransaction> transactions =
//         expenseController.settleGroupExpenses(expenses, groupUsers.length);
//     return groupUsers.isNotEmpty
//         ? transactions.isNotEmpty
//             ? SingleChildScrollView(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                   child: Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           ConstString.whichBalance,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium!
//                               .copyWith(
//                                   fontFamily: AppFont.fontMedium, fontSize: 15),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             border:
//                                 Border.all(color: AppColors.darkPrimaryColor)),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: groupUsers.length,
//                           separatorBuilder: (context, index) {
//                             return Divider(
//                               height: 0,
//                               thickness: 1,
//                               color: AppColors.lineGrey,
//                             );
//                           },
//                           itemBuilder: (context, index) {
//                             UserTransaction transaction = transactions[index];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   groupUsers[index]!.contactNumber !=
//                                           groupController.loggedInUser!.mobileNo
//                                       ? CircleAvatar(
//                                           radius: 20,
//                                           backgroundColor:
//                                               AppColors.primaryColor,
//                                           child: Text(
//                                             groupUsers[index]!.contactName !=
//                                                     null
//                                                 ? String.fromCharCodes(
//                                                         groupUsers[index]!
//                                                             .contactName!
//                                                             .runes
//                                                             .take(1))
//                                                     .toUpperCase()
//                                                 : "?",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .titleLarge!
//                                                 .copyWith(
//                                                     color: AppColors
//                                                         .darkPrimaryColor,
//                                                     fontFamily:
//                                                         AppFont.fontSemiBold,
//                                                     fontSize: 17),
//                                           ),
//                                         )
//                                       : MyGroupProfileWidget(),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         width: 120,
//                                         child: groupUsers[index]!.contactName !=
//                                                 null
//                                             ? Text(
//                                                 groupUsers[index]!
//                                                         .contactName ??
//                                                     "",
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleSmall!
//                                                     .copyWith(
//                                                         fontSize: 14,
//                                                         color: AppColors
//                                                             .darkPrimaryColor,
//                                                         fontFamily:
//                                                             AppFont.fontMedium),
//                                                 overflow: TextOverflow.ellipsis,
//                                               )
//                                             : Text(
//                                                 "You",
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .titleSmall!
//                                                     .copyWith(
//                                                         fontSize: 14,
//                                                         color: AppColors
//                                                             .darkPrimaryColor,
//                                                         fontFamily:
//                                                             AppFont.fontMedium),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                       ),
//                                       const SizedBox(
//                                         height: 3,
//                                       ),
//                                       groupUsers[index]!.contactNumber != null
//                                           ? Text(
//                                               groupUsers[index]!
//                                                       .contactNumber ??
//                                                   'No Contact',
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .titleSmall!
//                                                   .copyWith(
//                                                       fontSize: 12,
//                                                       color: AppColors
//                                                           .darkPrimaryColor,
//                                                       fontFamily:
//                                                           AppFont.fontRegular),
//                                             )
//                                           : MyGroupNumberTextWidget(),
//                                     ],
//                                   ),
//                                   const Spacer(),
//                                   Text(
//                                     "${userController.currencySymbol}${transaction.amount.formatAmount()}",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleMedium!
//                                         .copyWith(
//                                             fontFamily: AppFont.fontMedium,
//                                             color: AppColors.darkPrimaryColor),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     AppImages.intro2,
//                     height: 150,
//                     width: double.infinity,
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Text(
//                     ConstString.noExpenseData,
//                     style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                         color: AppColors.darkPrimaryColor,
//                         fontFamily: AppFont.fontSemiBold),
//                   ),
//                 ],
//               )
//         : Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 AppImages.intro2,
//                 height: 150,
//                 width: double.infinity,
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//               Text(
//                 ConstString.noExpenseData,
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                     color: AppColors.darkPrimaryColor,
//                     fontFamily: AppFont.fontSemiBold),
//               ),
//             ],
//           );
//   }
//
//   Map<String, double> calculateBalances(List<Expense> expenses) {
//     Map<String, double> balances = {};
//
//     for (Expense expense in expenses) {
//       String payerId = expense.payerId!.user.mobileNo!;
//       double amountPaid = expense.amount ?? 0.0;
//
//       // Initialize the payer's balance if not already done
//       balances[payerId] = balances.putIfAbsent(payerId, () => 0.0);
//
//       // Iterate over the equality array to calculate each user's share
//       for (Equality share in (expense.equality ?? [])) {
//         String userId = share.userId;
//         double userShare = share.amount;
//
//         // Decrease the payer's balance
//         balances[payerId] = (balances[payerId]! - userShare);
//
//         // Increase each owing user's balance
//         balances[userId] = balances.putIfAbsent(userId, () => 0.0) + userShare;
//       }
//     }
//
//     return balances;
//   }
//
//   List<Widget> getData(List<Expense> expenses) {
//     final balances = calculateBalances(expenses);
//     // Get transactions to settle up
//     List<Transaction> _transactions = settleUp1(balances);
//
//     String myMobileNo = groupController.loggedInUser!.mobileNo!;
//     List<Transaction> transactions = [];
//     List<Transaction> data = _transactions
//         .where((element) => (element.toUserId == myMobileNo ||
//             element.fromUserId == myMobileNo))
//         .toList();
//     transactions.addAll(data);
//     // Transaction? myTransaction = transactions
//     //     .firstWhereOrNull((element) => myMobileNo == element.toUserId);
//     // if (myTransaction == null) {
//     //   return [Container()];
//     // }
//     if (transactions.isEmpty) {
//       return [
//         Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 AppImages.intro2,
//                 height: 150,
//                 width: double.infinity,
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//               Text(
//                 ConstString.noExpenseToSettle,
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                     color: AppColors.darkPrimaryColor,
//                     fontFamily: AppFont.fontSemiBold),
//               ),
//             ],
//           ),
//         ),
//       ];
//     }
//     return [
//       Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           ConstString.whichBalance,
//           style: Theme.of(context)
//               .textTheme
//               .titleMedium!
//               .copyWith(fontFamily: AppFont.fontMedium, fontSize: 15),
//         ),
//       ),
//       const SizedBox(height: 8),
//       Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: AppColors.darkPrimaryColor)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: ListView.builder(
//             shrinkWrap: true,
//             padding: EdgeInsets.zero,
//             itemCount: transactions.length,
//             itemBuilder: (context, index) {
//               final transaction = transactions[index];
//               /*return ListTile(
//               title: Text(
//                   '${userController.getUserData(transaction.toUserId)?.getName() ?? transaction.toUserId} pays ${userController.getUserData(transaction.fromUserId)?.getName() ?? transaction.fromUserId}'),
//               subtitle: Text('Amount: ${transaction.amount}'),
//             );*/
//
//               print("Creditor : ${transaction.toUserId}");
//               print("Debtor : ${transaction.fromUserId}");
//               var creditorUser =
//                   userController.getUserData(transaction.toUserId);
//               var debtorUser =
//                   userController.getUserData(transaction.fromUserId);
//
//               return InkWell(
//                 onTap: () {
//                   if (widget.groupData != null &&
//                       creditorUser != null &&
//                       debtorUser != null) {
//                     Get.to(() => RecordPaymentScreen(
//                           groupData: widget.groupData!,
//                           amountToPay: transaction.amount,
//                           creditorUser: debtorUser,
//                           debtorUser: creditorUser,
//                         ));
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     children: [
//                       ImageWidget(
//                         debtorUser?.profilePicture ?? '',
//                         50,
//                         50,
//                         userName: debtorUser?.name ?? '',
//                         shouldShowUserName: true,
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: Text(
//                             (debtorUser != null && debtorUser.name != null)
//                                 ? debtorUser.name.toString()
//                                 : (debtorUser?.mobileNo).toString(),
//                             style: TextStyle(
//                               fontFamily: AppFont.fontRegular,
//                               fontWeight: FontWeight.w400,
//                               color: AppColors.black,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             transaction.toUserId != myMobileNo
//                                 ? 'Owes you'
//                                 : 'You need to pay',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: transaction.toUserId != myMobileNo
//                                   ? AppColors.credit
//                                   : AppColors.debit,
//                               fontFamily: AppFont.fontRegular,
//                             ),
//                           ),
//                           Text(
//                             '${userController.currencySymbol}${transaction.amount.formatAmount()}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: transaction.toUserId != myMobileNo
//                                   ? AppColors.credit
//                                   : AppColors.debit,
//                               fontFamily: AppFont.fontMedium,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     ];
//   }
//
//   List<Transaction> settleUp1(Map<String, double> balances) {
//     List<Transaction> transactions = [];
//
//     while (true) {
//       // Find the largest debtor and creditor
//       String maxDebtor =
//           balances.keys.firstWhere((k) => balances[k]! < 0, orElse: () => '');
//       String maxCreditor =
//           balances.keys.firstWhere((k) => balances[k]! > 0, orElse: () => '');
//
//       if (maxDebtor.isEmpty || maxCreditor.isEmpty) {
//         break; // Break if no more debtors or creditors
//       }
//
//       double minAmount = min(-balances[maxDebtor]!, balances[maxCreditor]!);
//       transactions.add(Transaction(
//           fromUserId: maxDebtor, toUserId: maxCreditor, amount: minAmount));
//
//       // Update the balances
//       balances[maxDebtor] = balances[maxDebtor]! + minAmount;
//       balances[maxCreditor] = balances[maxCreditor]! - minAmount;
//
//       // Remove the debtor or creditor from the map if their balance is zero
//       if (balances[maxDebtor] == 0) {
//         balances.remove(maxDebtor);
//       }
//       if (balances[maxCreditor] == 0) {
//         balances.remove(maxCreditor);
//       }
//     }
//
//     return transactions;
//   }
// }
//
// class Transaction {
//   String fromUserId;
//   String toUserId;
//   double amount;
//
//   Transaction(
//       {required this.fromUserId, required this.toUserId, required this.amount});
// }

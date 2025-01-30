import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/horizontal_avtar_widgets.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/expense_details.dart';
import 'package:split/screen/image_preview_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class MyChatWidget extends Container {
  final String message;
  final String image;
  final String time;
  final String senderId;
  final String expenseId;
  final GroupDataModel groupData;
  final bool sender;
  final bool isFirstMessage;
  final bool isLastMessage;

  MyChatWidget(
    this.message,
    this.image,
    this.time,
    this.senderId,
    this.expenseId,
    this.groupData,
    this.sender,
    this.isFirstMessage,
    this.isLastMessage, {
    super.key,
  });

  final GroupController controller = Get.find<GroupController>();
  final UserController userController = Get.find<UserController>();

  final settings = RestrictedPositions(
    maxCoverage: 0.2,
    minCoverage: 0.2,
    align: StackAlign.left,
  );

  List<ContactModel?>? groupUserNames;

  @override
  Widget build(BuildContext context) {
    Expense? expense =
        controller.fetchExpenseForDisplay(expenseId, controller.expenses);

    groupUserNames = controller.getContactNamesByNumbers(groupData.memberIds!
        .where((element) => element.user.mobileNo != senderId)
        .map((e) => e.user.mobileNo!)
        .toList());
    return Padding(
      padding:
          isFirstMessage ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
      child: Row(
        mainAxisAlignment:
            sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sender
              ? const SizedBox()
              : isFirstMessage
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: UserProfileWidget(
                        userData: userController.getUserData(senderId),
                        key: UniqueKey(),
                        mobileNo: senderId,
                        size: const Size(30, 30),
                      ),
                    )
                  : const SizedBox(),
          const SizedBox(
            width: 5,
          ),
          Padding(
            padding: isFirstMessage
                ? EdgeInsets.zero
                : sender
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                // color: Colors.black12,
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: sender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    expenseId == ""
                        ? message != "" && image == ""
                            ? _buildMessageContainer(context)
                            : _buildImageContainer(context)
                        : expense != null
                            ? _buildExpenseContainer(context, expense)
                            : FutureBuilder<Expense?>(
                                future: controller.fetchExpenseData(
                                    expenseId, groupData.id!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ExpenseWidgetShimmer(
                                        itemCount: 1);
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else if (snapshot.hasData) {
                                    return _buildExpenseContainer(
                                        context, snapshot.data!);
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (image.isNotEmpty) {
          Get.to(() => ImagePreviewScreen(
                image: image,
              ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: sender ? AppColors.decsGrey : AppColors.tilePrimaryColor,
            borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            crossAxisAlignment:
                sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              sender
                  ? const SizedBox()
                  : isFirstMessage
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 3),
                          child: Text(
                            getSenderName(senderId) ?? '-',
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: AppColors.receiveText,
                                    fontFamily: AppFont.fontMedium,
                                    fontSize: 10),
                          ),
                        )
                      : const SizedBox(),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 300,
                  imageUrl: image,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                        child: LoadingIndicator(
                      colors: [AppColors.primaryColor],
                      indicatorType: Indicator.ballScale,
                      strokeWidth: 1,
                    )),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              // expenseId == ""
              // ? sender
              //     ? isLastMessage
              //         ? Padding(
              //             padding: const EdgeInsets.only(top: 5),
              //             child: Text(
              //               time,
              //               textScaler: const TextScaler.linear(1),
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .titleSmall!
              //                   .copyWith(
              //                       fontSize: 11, color: AppColors.txtGrey),
              //             ),
              //           )
              //         : const SizedBox()
              //     : const SizedBox()
              // : const SizedBox(),
              // expenseId == ""
              //     ? !sender
              //         ? Padding(
              //             padding: const EdgeInsets.only(top: 5),
              //             child: Text(
              //               time,
              //               textScaler: const TextScaler.linear(1),
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .titleSmall!
              //                   .copyWith(color: AppColors.txtGrey, fontSize: 11),
              //             ),
              //           )
              //         : const SizedBox()
              //     : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: sender ? AppColors.decsGrey : AppColors.tilePrimaryColor,
          borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Column(
          crossAxisAlignment:
              sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            sender
                ? const SizedBox()
                : isFirstMessage
                    ? Text(
                        getSenderName(senderId) ?? '-',
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.receiveText,
                            fontFamily: AppFont.fontMedium,
                            fontSize: 10),
                      )
                    : const SizedBox(),
            const SizedBox(
              height: 2,
            ),
            Text(
              message,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.darkPrimaryColor, fontSize: 14),
            ),
            expenseId == ""
                ? sender
                    ? isLastMessage
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              time,
                              textScaler: const TextScaler.linear(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontSize: 11, color: AppColors.txtGrey),
                            ),
                          )
                        : const SizedBox()
                    : const SizedBox()
                : const SizedBox(),
            expenseId == ""
                ? !sender
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          time,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: AppColors.txtGrey, fontSize: 11),
                        ),
                      )
                    : const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  String getPayerName(Expense expense) {
    return userController
            .getNameByPhoneNumber(expense.payerId!.user.mobileNo) ??
        expense.payerId!.user.name ??
        "-";
  }

  String? getSenderName(String senderId) {
    UserModel? senderData = userController.getUserData(senderId);
    if (senderData != null) {
      return senderData.name;
    }

    // return userController.getNameByPhoneNumber(senderId) ?? "Deleted User";
    return userController.getNameByPhoneNumber(senderId) ?? senderId;
  }

  Future<void> handleExpenseCardClick(Expense expense) async {
    bool hasPaidExpense = false;
    if (expense.equality == null || (expense.equality ?? []).isEmpty) {
      hasPaidExpense = false;
    } else {
      UserController userController = Get.find<UserController>();
      Equality? expenseData = expense.equality!.firstWhereOrNull((element) =>
          element.userId
              .contains(userController.loggedInUser.value?.mobileNo ?? ''));
      if (expenseData != null) {
        hasPaidExpense = (expenseData.status == "Paid");
      } else {
        hasPaidExpense = false;
      }
    }

    if (hasPaidExpense) {
      Get.to(() => ExpenseDetails(
            expense: expense,
            groupData: groupData,
            isSender: sender,
          ));
    } else {
      // Get.to(() => RecordPaymentScreen(
      //       expense: expense,
      //       groupData: groupData,
      //     ));
      // FIXME implement or redirect
    }
  }

  Widget _buildExpenseContainer(BuildContext context, Expense expense) {
    return Align(
      alignment: !sender ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          Get.to(() => ExpenseDetails(
                expense: expense,
                groupData: groupData,
                isSender: sender,
              ));
          // await handleExpenseCardClick(expense);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: !sender ? AppColors.tilePrimaryColor : AppColors.decsGrey,
              border: Border.all(
                  color: !sender ? AppColors.intro1 : AppColors.borderGrey,
                  width: 0.5)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !sender
                    ? Text(
                        getSenderName(senderId)!,
                        // getPayerName(expense),
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.receiveText,
                            fontFamily: AppFont.fontMedium,
                            fontSize: 10),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  "${expense.title}",
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 12,
                        color: AppColors.darkPrimaryColor,
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "${userController.currencySymbol}${expense.amount?.formatAmount()}",
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      color: AppColors.darkPrimaryColor,
                      fontFamily: AppFont.fontSemiBold),
                ),
                const SizedBox(
                  height: 10,
                ),
                HorizontalAvtarWidgets(
                  height: 25,
                  userMobileList:
                      groupData.memberIds!.map((e) => e.user.mobileNo).toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.watchIcon,
                      height: 15,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      controller.formatDateTime(expense.createdAt!),
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppColors.darkPrimaryColor, fontSize: 11.5),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      AppIcons.arrow_right,
                      height: 18,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class MyChatWidget extends Container {
//   final String message;
//   final String time;
//   final String senderId;
//   final String expenseId;
//   final GroupDataModel groupData;
//   final bool sender;
//   final bool isFirstMessage;
//   final bool isLastMessage;
//
//   MyChatWidget(
//     this.message,
//     this.time,
//     this.senderId,
//     this.expenseId,
//     this.groupData,
//     this.sender,
//     this.isFirstMessage,
//     this.isLastMessage, {
//     super.key,
//   });
//
//   final GroupController controller = Get.find<GroupController>();
//   final UserController userController = Get.find<UserController>();
//
//   final settings = RestrictedPositions(
//     maxCoverage: 0.2,
//     minCoverage: 0.2,
//     align: StackAlign.left,
//   );
//
//   List<ContactModel?>? groupUserNames;
//
//   @override
//   Widget build(BuildContext context) {
//     groupUserNames = controller.getContactNamesByNumbers(groupData.memberIds!
//         .where((element) => element.user.mobileNo != senderId)
//         .map((e) => e.user.mobileNo!)
//         .toList());
//     return Padding(
//       padding:
//           isFirstMessage ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
//       child: Row(
//         mainAxisAlignment:
//             sender ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           sender
//               ? const SizedBox()
//               : isFirstMessage
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                       child: UserProfileWidget(
//                         userData: userController.getUserData(senderId),
//                         key: UniqueKey(),
//                         mobileNo: senderId,
//                         size: const Size(30, 30),
//                       ),
//                     )
//                   : const SizedBox(),
//           expenseId == ""
//               ? sender
//                   ? isLastMessage
//                       ? Column(
//                           children: [
//                             SizedBox(
//                               height: 25,
//                             ),
//                             Text(
//                               time,
//                               textScaler: const TextScaler.linear(1),
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleSmall!
//                                   .copyWith(fontSize: 11),
//                             ),
//                           ],
//                         )
//                       : SizedBox()
//                   : const SizedBox()
//               : const SizedBox(),
//           const SizedBox(
//             width: 8,
//           ),
//           Padding(
//             padding: isFirstMessage
//                 ? EdgeInsets.zero
//                 : sender
//                     ? EdgeInsets.zero
//                     : const EdgeInsets.only(left: 30),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   expenseId == ""
//                       ? _buildMessageContainer(context)
//                       : FutureBuilder<Expense?>(
//                           future: controller.fetchExpenseData(
//                               expenseId, groupData.id!),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const ExpenseWidgetShimmer(itemCount: 1);
//                             } else if (snapshot.hasError) {
//                               return Text("Error: ${snapshot.error}");
//                             } else if (snapshot.hasData) {
//                               return _buildExpenseContainer(
//                                   context, snapshot.data!);
//                             } else {
//                               return const SizedBox();
//                             }
//                           },
//                         ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 8,
//           ),
//           expenseId == ""
//               ? !sender
//                   ? Column(
//                       children: [
//                         SizedBox(
//                           height: 40,
//                         ),
//                         Align(
//                           alignment: Alignment.center,
//                           child: Text(
//                             time,
//                             textScaler: const TextScaler.linear(1),
//                             style: Theme.of(context).textTheme.titleSmall,
//                           ),
//                         ),
//                       ],
//                     )
//                   : const SizedBox()
//               : const SizedBox(),
//         ],
//       ),
//     );
//   }
//
//   Container _buildMessageContainer(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: sender ? AppColors.decsGrey : AppColors.tilePrimaryColor,
//           borderRadius: BorderRadius.circular(8)),
//       margin: const EdgeInsets.symmetric(vertical: 3),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             sender
//                 ? const SizedBox()
//                 : isFirstMessage
//                     ? Text(
//                         getSenderName(senderId) ?? '-',
//                         textScaler: const TextScaler.linear(1),
//                         style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                             color: AppColors.receiveText,
//                             fontFamily: AppFont.fontMedium,
//                             fontSize: 10),
//                       )
//                     : const SizedBox(),
//             const SizedBox(
//               height: 2,
//             ),
//             Text(
//               message,
//               textScaler: const TextScaler.linear(1),
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium!
//                   .copyWith(color: AppColors.darkPrimaryColor, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String getPayerName(Expense expense) {
//     return userController
//             .getNameByPhoneNumber(expense.payerId!.user.mobileNo) ??
//         expense.payerId!.user.name ??
//         "-";
//   }
//
//   String? getSenderName(String senderId) {
//     UserModel? senderData = userController.getUserData(senderId);
//     if (senderData != null) {
//       return senderData.name;
//     }
//
//     // return userController.getNameByPhoneNumber(senderId) ?? "Deleted User";
//     return userController.getNameByPhoneNumber(senderId) ?? senderId;
//   }
//
//   Future<void> handleExpenseCardClick(Expense expense) async {
//     bool hasPaidExpense = false;
//     if (expense.equality == null || (expense.equality ?? []).isEmpty) {
//       hasPaidExpense = false;
//     } else {
//       UserController userController = Get.find<UserController>();
//       Equality? expenseData = expense.equality!.firstWhereOrNull((element) =>
//           element.userId
//               .contains(userController.loggedInUser.value?.mobileNo ?? ''));
//       if (expenseData != null) {
//         hasPaidExpense = (expenseData.status == "Paid");
//       } else {
//         hasPaidExpense = false;
//       }
//     }
//
//     if (hasPaidExpense) {
//       Get.to(() => ExpenseDetails(
//             expense: expense,
//             groupData: groupData,
//             isSender: sender,
//           ));
//     } else {
//       // Get.to(() => RecordPaymentScreen(
//       //       expense: expense,
//       //       groupData: groupData,
//       //     ));
//       // FIXME implement or redirect
//     }
//   }
//
//   Widget _buildExpenseContainer(BuildContext context, Expense expense) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: GestureDetector(
//         onTap: () async {
//           Get.to(() => ExpenseDetails(
//                 expense: expense,
//                 groupData: groupData,
//                 isSender: sender,
//               ));
//           // await handleExpenseCardClick(expense);
//         },
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 5),
//           width: 200,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: !sender ? AppColors.tilePrimaryColor : AppColors.decsGrey,
//               border: Border.all(
//                   color: !sender ? AppColors.intro1 : AppColors.borderGrey,
//                   width: 0.5)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 !sender
//                     ? Text(
//                         getSenderName(senderId)!,
//                         // getPayerName(expense),
//                         textScaler: const TextScaler.linear(1),
//                         style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                             color: AppColors.receiveText,
//                             fontFamily: AppFont.fontMedium,
//                             fontSize: 10),
//                       )
//                     : const SizedBox(),
//                 const SizedBox(
//                   height: 6,
//                 ),
//                 Text(
//                   "${expense.title}",
//                   textScaler: const TextScaler.linear(1),
//                   style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                         fontSize: 12,
//                         color: AppColors.darkPrimaryColor,
//                       ),
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Text(
//                   "${userController.currencySymbol}${expense.amount?.formatAmount()}",
//                   textScaler: const TextScaler.linear(1),
//                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                       fontSize: 18,
//                       color: AppColors.darkPrimaryColor,
//                       fontFamily: AppFont.fontSemiBold),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 HorizontalAvtarWidgets(
//                   height: 25,
//                   userMobileList:
//                       groupData.memberIds!.map((e) => e.user.mobileNo).toList(),
//                 ),
//                 // Align(
//                 //   alignment: Alignment.centerLeft,
//                 //   child: Container(
//                 //     height: 30,
//                 //     child: WidgetStack(
//                 //       positions: settings,
//                 //       stackedWidgets: [
//                 //         for (var n = 0;
//                 //             n <
//                 //                 groupUserNames!
//                 //                     .length;
//                 //             n++)
//                 //           Align(
//                 //             alignment:
//                 //                 Alignment.center,
//                 //             child: Container(
//                 //               height: 30,
//                 //               width: 30,
//                 //               decoration: BoxDecoration(
//                 //                   color: !sender
//                 //                       ? AppColors
//                 //                           .intro1
//                 //                       : AppColors
//                 //                           .borderGrey,
//                 //                   shape:
//                 //                       BoxShape.circle,
//                 //                   border: Border.all(
//                 //                       color: AppColors
//                 //                           .white,
//                 //                       width: 0.5)),
//                 //               child: Center(
//                 //                 child: Text(
//                 //                   groupUserNames![
//                 //                               n] !=
//                 //                           null
//                 //                       ? String.fromCharCodes(groupUserNames![
//                 //                                   n]!
//                 //                               .runes
//                 //                               .take(
//                 //                                   1))
//                 //                           .toUpperCase()
//                 //                       : "Y",
//                 //                   style: Theme.of(
//                 //                           context)
//                 //                       .textTheme
//                 //                       .titleSmall!
//                 //                       .copyWith(
//                 //                           fontSize:
//                 //                               13,
//                 //                           color: AppColors
//                 //                               .white,
//                 //                           fontFamily:
//                 //                               AppFont
//                 //                                   .fontSemiBold),
//                 //                 ),
//                 //               ),
//                 //             ),
//                 //           )
//                 //       ],
//                 //       buildInfoWidget: (surplus) {
//                 //         return SizedBox();
//                 //       },
//                 //     ),
//                 //   ),
//                 // ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SvgPicture.asset(
//                       AppIcons.watchIcon,
//                       height: 15,
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       controller.formatDateTime(expense.createdAt!),
//                       textScaler: const TextScaler.linear(1),
//                       style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                           color: AppColors.darkPrimaryColor, fontSize: 11.5),
//                     ),
//                     const Spacer(),
//                     SvgPicture.asset(
//                       AppIcons.arrow_right,
//                       height: 18,
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

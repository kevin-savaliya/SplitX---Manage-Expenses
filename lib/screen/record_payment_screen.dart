import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/main.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/message_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/homescreen.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/extenstions.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/user/my_profile_widget.dart';
import 'package:split/widgets/user/other_profile_widget.dart';

class RecordPaymentScreen extends StatefulWidget {
  final UserModel creditorUser;
  final UserModel debtorUser;
  final GroupDataModel groupData;
  final double amountToPay;

  const RecordPaymentScreen({
    super.key,
    required this.amountToPay,
    required this.creditorUser,
    required this.debtorUser,
    required this.groupData,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  TextEditingController amountEditController = TextEditingController();

  final GroupController groupController = Get.find<GroupController>();
  final UserController userController = Get.find<UserController>();
  late Razorpay razorpay;

  @override
  void initState() {
    amountEditController =
        TextEditingController(text: widget.amountToPay.formatAmount());
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success callback implementation
    print("Payment Successful: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment error callback implementation
    print("Payment Error: ${response.code.toString()} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet callback implementation
    print("External Wallet: ${response.walletName}");
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
          ConstString.recordPayment,
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  ConstString.total,
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 15,
                      fontFamily: AppFont.fontMedium,
                      color: AppColors.darkPrimaryColor),
                ),
              ),
              SizedBox(
                height: 100,
                width: 140,
                child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1)),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      enabled: true,
                      readOnly: false,
                      cursorColor: AppColors.paymentLine,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: AppColors.darkPrimaryColor,
                          fontFamily: AppFont.fontSemiBold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          prefix: Text(
                            "${userController.currencySymbol}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: AppColors.darkPrimaryColor,
                                    fontSize: 25),
                          ),
                          hintText: '${userController.currencySymbol}0000',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  color: AppColors.paymentLine,
                                  fontFamily: AppFont.fontMedium),
                          border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine)),
                          disabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine)),
                          focusedErrorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine)),
                          errorBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.paymentLine))),
                      controller: amountEditController,
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Spacer(),
                  Expanded(
                    child: Column(
                      children: [
                        MyProfileWidget(),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          ConstString.youPaid,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontSize: 13,
                                  fontFamily: AppFont.fontMedium,
                                  color: AppColors.darkPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: SvgPicture.asset(AppIcons.arrow_right_and)),
                  Expanded(
                    child: Column(
                      children: [
                        OtherProfileWidget(
                          otherUserId: widget.creditorUser.mobileNo ?? "",
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.creditorUser.name ?? '-',
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontSize: 13,
                                  fontFamily: AppFont.fontMedium,
                                  color: AppColors.darkPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: () async {
                    /*await groupController.addExpenseToGroup(
                        group: widget.groupData, expense: getExpense());*/

                    if (amount < 0) {
                      return;
                    }
                    _openCheckout(amount);
                    // await addExpense(context);
                    //TODO: Send Notification to paid expense amount

                    String title = '';
                    if (amount == widget.amountToPay) {
                      title =
                          '${groupController.userDataModel?.name} settled total share of ${userController.currencySymbol}${widget.amountToPay} in expenses in “${widget.groupData.name}”.';
                    } else {
                      title =
                          '${groupController.userDataModel?.name} partially paid ${userController.currencySymbol}${widget.amountToPay} total share in “${widget.groupData.name}”.';
                    }
                    // await NotificationService.sendMultipleNotifications(
                    //     senderId: '${groupController.userDataModel?.id}',
                    //     //customerId: groupController.currentUserId,
                    //     customerIdList: groupController.customerIdList,
                    //     groupId: widget.groupData.id!,
                    //     type: 'payment_paid',
                    //     title: title,
                    //     body: '',
                    //     tokens: groupController.fcmTokenList);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      fixedSize: const Size(200, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Text(
                    ConstString.pay,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.darkPrimaryColor,
                        fontFamily: AppFont.fontMedium),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _openCheckout(double amount) async {
    var options = {
      'key': 'rzp_test_ICcB8FjlCLGlLQ',
      'amount': num.parse(amount.toString()) * 100,
      'name': widget.creditorUser.name,
      'description': 'Settle Expense Amount',
      'prefill': {
        'contact': groupController.loggedInUser!.mobileNo!,
        'email': 'savaliyakevin171@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay.open(options);
      await addExpense(context);
    } catch (e) {
      print('Error: $e');
    }
  }

  double get amount => double.tryParse(amountEditController.text) ?? -1;

  Future<void> addExpense(BuildContext context) async {
    CollectionReference expenceRef =
        FirebaseFirestore.instance.collection("expenses");

    String groupId = widget.groupData.id!;
    String expenseId = expenceRef.doc().id;
    DocumentReference userExpensesDocRef = expenceRef.doc(groupId);
    String myMobileNo = groupController.loggedInUser!.mobileNo!;
    DocumentSnapshot snapshot = await userExpensesDocRef.get();

    Expense expense = Expense(
      expenseId: expenseId,
      title: 'settlement for ${widget.debtorUser.name}',
      amount: amount.roundToDouble(),
      payerId: GroupMember(user: groupController.loggedInUser!),
      behalfAddUser: GroupMember(user: groupController.loggedInUser!),
      createdAt: DateTime.now(),
      splitExpenseAt: DateTime.now(),
      groupId: groupId,
      splitMode: SplitMode.Amount.name.toString(),
      expenseType: "Settle",
      equality: [
        Equality(
          userId: widget.creditorUser.mobileNo!,
          status: "Paid",
          percentage: 100,
          amount: amount.roundToDouble(),
        ),
        Equality(
          userId: widget.debtorUser.mobileNo!,
          status: "Paid",
          percentage: 0,
          amount: 0,
        ),
      ],
    );

    if (!snapshot.exists) {
      await userExpensesDocRef.set({
        'expenses': [expense.toMap()]
      }).then((value) async {
        await saveAsAMessage(expense, groupId, context);
      });
    } else {
      await userExpensesDocRef.update({
        'expenses': FieldValue.arrayUnion([expense.toMap()])
      }).then((value) async {
        await saveAsAMessage(expense, groupId, context);
      });
    }
  }

  Future<void> saveAsAMessage(
      Expense expense, String groupId, BuildContext context) async {
    // MessageModel message = MessageModel(
    //     messageId: uuid.v1(),
    //     message: expense.title,
    //     sender: groupController.loggedInUser!.mobileNo,
    //     createdTime: DateTime.now(),
    //     isSeen: false,
    //     expenseId: expense.expenseId,
    //     msgType: "Settle");
    //
    // await groupController.sendMessage(message, groupId);
    // showInSnackBar(context, "Expense added successfully", isSuccess: true);
    Get.off(() => HomeScreen());
  }

// Future<void> addExpense(BuildContext context) async {
//   CollectionReference expenceRef =
//       FirebaseFirestore.instance.collection("expenses");
//
//   String groupId = widget.groupData.id!;
//   String expenseId = expenceRef.doc().id;
//   DocumentReference userExpensesDocRef = expenceRef.doc(groupId);
//
//   DocumentSnapshot snapshot = await userExpensesDocRef.get();
//
//   Expense expense = Expense(
//     expenseId: expenseId,
//     title: 'settlement for ${widget.debtorUser.name}',
//     amount: amount,
//     payerId: GroupMember(user: groupController.loggedInUser!),
//     behalfAddUser: GroupMember(user: groupController.loggedInUser!),
//     createdAt: DateTime.now(),
//     splitExpenseAt: DateTime.now(),
//     groupId: groupId,
//     splitMode: SplitMode.Amount.name.toString(),
//     equality: [
//       Equality(
//         userId: widget.creditorUser.mobileNo!,
//         status: "Paid",
//         percentage: 100,
//         amount: amount,
//       ),
//       Equality(
//         userId: widget.debtorUser.mobileNo!,
//         status: "Paid",
//         percentage: 0,
//         amount: 0,
//       ),
//     ],
//   );
//
//   if (!snapshot.exists) {
//     await userExpensesDocRef.set({
//       'expenses': [expense.toMap()]
//     }).then((value) async {
//       await saveAsAMessage(expense, groupId, context);
//     });
//   } else {
//     await userExpensesDocRef.update({
//       'expenses': FieldValue.arrayUnion([expense.toMap()])
//     }).then((value) async {
//       await saveAsAMessage(expense, groupId, context);
//     });
//   }
// }
//
// Future<void> saveAsAMessage(
//     Expense expense, String groupId, BuildContext context) async {
//   MessageModel message = MessageModel(
//       messageId: uuid.v1(),
//       message: expense.title,
//       sender: groupController.loggedInUser!.mobileNo,
//       createdTime: DateTime.now(),
//       isSeen: false,
//       expenseId: expense.expenseId);
//
//   await groupController.sendMessage(message, groupId);
//   showInSnackBar(context, "Expense added successfully", isSuccess: true);
//   Get.offAll(() => HomeScreen());
// }
}

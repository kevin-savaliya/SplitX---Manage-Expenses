// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/main.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';

// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
import 'package:split/model/message_model.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/utils.dart';

enum SplitMode { Equally, Amount, Percentage, Share }

enum AppContactPermissionStatus {
  initial,
  granted,
  denied,
  error,
  empty,
  assigned
}

class ExpenseController extends GetxController {
  CollectionReference expenceRef =
      FirebaseFirestore.instance.collection("expenses");

  Rx<GroupMember?> selectedPaidContact = Rx<GroupMember?>(null);
  Rx<GroupMember?> selectedPaidUser = Rx<GroupMember?>(null);

  DateTime? selectedDate;
  DateTime? selectedDateTime;
  RxString selectedFormateDate = "Select Date".obs;

  var mode = SplitMode.Equally.obs;
  RxString splitMode = "Equally".obs;

  // GroupController groupController = Get.find<GroupController>();

  TextEditingController expenseDescriptionController = TextEditingController();
  TextEditingController expenseAmountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  Map<String, TextEditingController> amountControllers = {};
  Map<String, TextEditingController> percentageControllers = {};

  var totalPositiveBalance = 0.0.obs;
  var totalNegativeBalance = 0.0.obs;

  Rx<Expense> expenseData = Expense().obs;

  var selectedUsers = <String, bool>{}.obs;
  var splitAmounts = <String, double>{}.obs;
  var userAmounts = <String, double>{}.obs;
  var userPercentages = <String, double>{}.obs;
  var userShares = <String, int>{}.obs;
  RxDouble remainingAmount = 0.0.obs;
  RxDouble remainingPercentage = 100.0.obs;

  var transactionsList = <UserTransaction>[].obs;

  final UserController userController = Get.find<UserController>();
  AppContactServices appContactServices = Get.put(AppContactServices());

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    resetState();
    initializeUserShares();
  }

  void setExpense(Expense? expense) {
    if (expense != null) {
      selectedDate = expense.createdAt;
      selectedDateTime = expense.createdAt;
      expenseDescriptionController.text = expense.title ?? "";
      expenseAmountController.text = expense.amount!.round().toString();
      selectedFormateDate.value =
          DateFormat('dd MMMM yyyy').format(selectedDate!);
      dateController.text = selectedFormateDate.value;
    } else {
      selectedDate = DateTime.now();
      selectedDateTime = DateTime.now();
      expenseDescriptionController.clear();
      expenseAmountController.clear();
      selectedFormateDate.value =
          DateFormat('dd MMMM yyyy').format(selectedDate!);
      dateController.text = selectedFormateDate.value;
    }
  }

  UserModel? findCorrespondingUserModel(
      ContactModel? contact, List<UserModel> memberModels) {
    if (contact == null) return null;

    String formattedContactNumber =
        calculateLast10Digits(contact.contactNumber ?? '');

    return memberModels.firstWhere(
      (user) {
        String formattedUserContactNumber =
            calculateLast10Digits(user.mobileNo!);
        return formattedUserContactNumber == formattedContactNumber;
      },
      orElse: () => UserModel(),
    );
  }

  UserModel? findCorrespondingUserModell(
      ContactModel? contact, List<UserModel> memberModels) {
    if (contact == null) return null;

    print("Selected contact mobileNo: ${contact.contactNumber}");
    for (var user in memberModels) {
      print("Checking user: ${user.mobileNo}");
      if (user.mobileNo == contact.contactNumber) {
        print("Match found: ${user.toString()}");
        return user;
      }
    }

    print("No match found");
    return null;
  }

  void selectContact(GroupMember? groupMember, List<GroupMember> memberModels) {
    if (groupMember != null) {
      selectedPaidContact.value = groupMember; // Storing the GroupMember

      selectedPaidUser.value = groupMember; // Storing just the UserModel

      print(selectedPaidUser
          .value?.user.mobileNo); // Printing the mobile number of the UserModel
    } else {
      selectedPaidContact.value = null;
      selectedPaidUser.value = null;
    }
  }

  void resetState() {
    userAmounts.clear();
    remainingPercentage.value = 100.0;
    // selectedDate = null;
  }

  void updateSplitMode(SplitMode newMode) {
    mode.value = newMode;
    splitMode.value = newMode.name;
    expenseData.value.splitMode = splitMode.toString();
  }

  void initializeUsers(List<String> userIds, double totalAmount) {
    final initialSelection = {for (var id in userIds) id: true};
    selectedUsers.assignAll(initialSelection);
    // log("Selected : $selectedUsers");
    recalculateSplits(totalAmount);
  }

  void toggleUserSelection(String userId) {
    selectedUsers[userId] = !(selectedUsers[userId] ?? false);
    recalculateSplits(expenseData.value.amount!);
    if (!(selectedUsers[userId] ?? false)) {
      userAmounts[userId] = 0;
      userPercentages[userId] = 0;
      userShares[userId] = 0;
    }
    updateRemainingAmount();
    updateRemainingPercentage();
    updateExpenseSplit();
  }

  void recalculateSplits(double totalAmount) {
    int selectedCount =
        selectedUsers.values.where((isSelected) => isSelected).length;
    double amountPerUser =
        (selectedCount != 0) ? totalAmount / selectedCount : 0;

    selectedUsers.forEach((userId, isSelected) {
      if (isSelected) {
        splitAmounts[userId] = amountPerUser;
      } else {
        splitAmounts.remove(userId);
      }
    });
  }

  void setUserAmount(String userId, double amount) {
    if (selectedUsers[userId] == true) {
      userAmounts[userId] = amount;
    }
    updateRemainingAmount();
  }

  double calculateTotalEnteredAmount() {
    return userAmounts.values.fold(0, (sum, amount) => sum + amount);
  }

  void updateRemainingAmount() {
    double totalExpenseAmount = expenseData.value.amount!;
    double totalEnteredAmount = calculateTotalEnteredAmount();

    double newRemainingAmount = totalExpenseAmount - totalEnteredAmount;

    if (newRemainingAmount >= 0) {
      remainingAmount.value = newRemainingAmount;
      updateExpenseSplit();
    } else {
      remainingAmount.value = 0.0;
      toast(message: "No amount remaining!");
    }
  }

  void setUserPercentage(String userId, double percentage) {
    userPercentages[userId] = percentage;
    updateRemainingPercentage();
    updateExpenseSplit();
  }

  void percentageSplit() {
    double totalPercentage = userPercentages.entries
        .where((entry) => selectedUsers[entry.key] == true)
        .fold(0, (sum, entry) => sum + (entry.value));

    double totalExpenseAmount = expenseData.value.amount!;

    if (totalPercentage == 100.0) {
      List<Equality> updatedEquality = userPercentages.entries
          .where((entry) => selectedUsers[entry.key] == true)
          .map((entry) {
        double amount = (entry.value / 100.0) * totalExpenseAmount;
        return Equality(
            userId: entry.key,
            status: (selectedPaidUser.value?.user.mobileNo == entry.key)
                ? "Paid"
                : "Unpaid",
            percentage: entry.value,
            amount: amount);
      }).toList();

      expenseData.update((exp) {
        exp?.equality = updatedEquality;
      });
      updatedEquality.forEach((element) {
        print("Percentage : ${element.amount}");
      });
    } else {
      // toast(message: "Percentage must be 100");
    }
  }

  void updateRemainingPercentage() {
    double totalPercentage =
        userPercentages.values.fold(0, (sum, p) => sum + p);
    double newRemainingpercentage = 100.0 - totalPercentage;

    if (newRemainingpercentage >= 0) {
      remainingPercentage.value = newRemainingpercentage;
      updateExpenseSplit();
    } else {
      remainingPercentage.value = 0.0;
      toast(message: "No percentage remaining!");
    }
  }

  void initializeUserShares() {
    for (var userId in selectedUsers.keys) {
      userShares[userId] = 1;
    }
    print("User Share");
  }

  double getUserAmount(String userId) {
    double totalExpenseAmount = expenseData.value.amount ?? 0.0;

    if (selectedUsers[userId] == true && userShares.containsKey(userId)) {
      int totalShares = userShares.values.fold(0, (sum, share) => sum + share);
      double amountPerShare = totalExpenseAmount / totalShares;
      return userShares[userId]! * amountPerShare;
    }
    return 0.0;
  }

  void updateUserShare(String userId, int newShare) {
    if (selectedUsers[userId] == true) {
      userShares[userId] = newShare;
      shareSplit();
    }
  }

  updateExpenseSplit() {
    if (expenseData.value.splitMode == SplitMode.Equally.name) {
      splitEqually();
    } else if (expenseData.value.splitMode == SplitMode.Amount.name) {
      splitByAmount();
    } else if (expenseData.value.splitMode == SplitMode.Percentage.name) {
      percentageSplit();
    } else if (expenseData.value.splitMode == SplitMode.Share.name) {
      shareSplit();
    } else {
      splitEqually();
      remainingAmount.value = 0.0;
    }
  }

  // void shareSplit() {
  //   int totalShares = userShares.values
  //       .where((share) => share > 0)
  //       .fold(0, (sum, share) => sum + share);
  //   double totalExpenseAmount = expenseData.value.amount!;
  //   if (totalShares == 0) return;
  //
  //   double amountPerShare = totalExpenseAmount / totalShares;
  //
  //   List<Equality> updatedEquality = userShares.entries
  //       .where((entry) => selectedUsers[entry.key] == true && entry.value > 0)
  //       .map((entry) => Equality(
  //             userId: entry.key,
  //             status: (selectedPaidUser.value?.mobileNo == entry.key)
  //                 ? "Paid"
  //                 : "Unpaid",
  //             amount: (entry.value * amountPerShare).toPrecision(0),
  //             percentage: (entry.value / totalShares).toPrecision(0) * 100,
  //           ))
  //       .toList();
  //
  //   expenseData.update((exp) => exp?.equality = updatedEquality);
  //   updatedEquality.forEach((element) {
  //     print("Share : ${element.amount}");
  //   });
  // }

  void shareSplit() {
    int totalShares = userShares.values
        .where((share) => share > 0)
        .fold(0, (sum, share) => sum + share);
    double totalExpenseAmount = expenseData.value.amount!;
    if (totalExpenseAmount == 0) return;

    double amountPerShare = totalExpenseAmount / totalShares;

    List<Equality> updatedEquality = userShares.entries
        .where((entry) => selectedUsers[entry.key] == true && entry.value > 0)
        .map((entry) => Equality(
              userId: entry.key,
              status: (selectedPaidUser.value?.user.mobileNo == entry.key)
                  ? "Paid"
                  : "Unpaid",
              amount: (entry.value * amountPerShare),
              percentage:
                  (entry.value / totalExpenseAmount * 10000).round().toDouble(),
            ))
        .toList();

    expenseData.update((exp) => exp?.equality = updatedEquality);
    updatedEquality.forEach((element) {
      print("User: ${element.userId}, Share Value: ${element.percentage}");
    });
  }

  void splitEqually() {
    print("Equally Split");
    List<Equality> updatedEquality = [];

    int selectedCount =
        selectedUsers.values.where((isSelected) => isSelected).length;

    if (selectedCount == 0) return;

    double percentagePerUser = 100.0 / selectedCount;

    selectedUsers.forEach((userId, isSelected) {
      if (isSelected) {
        double amount = splitAmounts[userId] ?? 0;
        updatedEquality.add(Equality(
            userId: userId,
            status: (selectedPaidUser.value?.user.mobileNo == userId)
                ? "Paid"
                : "Unpaid",
            percentage: percentagePerUser,
            amount: amount));
      }
    });

    expenseData.update((exp) {
      exp?.equality = updatedEquality;
    });
    updatedEquality.forEach((element) {
      print("Equally : ${element.amount}");
      userAmounts[element.userId] = element.amount;
    });
  }

  void splitByAmount() {
    print("Amount Split");
    List<Equality> updatedEquality = [];

    double totalAmount =
        userAmounts.values.fold(0, (sum, amount) => sum + amount);
    if (totalAmount == 0) return;

    selectedUsers.forEach((userId, isSelected) {
      if (isSelected && userAmounts.containsKey(userId)) {
        double userAmount = userAmounts[userId] ?? 0;
        double percentage =
            (totalAmount > 0) ? (userAmount / totalAmount) * 100 : 0;

        updatedEquality.add(Equality(
            userId: userId,
            status: (selectedPaidUser.value?.user.mobileNo == userId)
                ? "Paid"
                : "Unpaid",
            percentage: percentage,
            amount: userAmount));
      }
    });

    expenseData.update((exp) {
      exp?.equality = updatedEquality;
    });
    updatedEquality.forEach((element) {
      print("By Amount : ${element.amount}");
    });
  }

  bool validateData(BuildContext context) {
    if (expenseDescriptionController.text.trim().isEmpty) {
      showInSnackBar(context, "Please enter expense description",
          title: 'Required!', isSuccess: false);
      return false;
    } else if (expenseAmountController.text.trim().isEmpty) {
      showInSnackBar(context, "Please enter expense amount",
          title: 'Required!', isSuccess: false);
      return false;
    } else if (selectedPaidUser.value == null) {
      showInSnackBar(context, "Please select paid user",
          title: 'Required!', isSuccess: false);
      return false;
    } else if (selectedDate == null) {
      showInSnackBar(context, "Please select date",
          title: 'Required!', isSuccess: false);
      return false;
    }
    return true;
  }

  addFormDataToExpense(GroupDataModel selectedGroup) {
    expenseData.value.title = expenseDescriptionController.text.trim();
    expenseData.value.amount = double.parse(expenseAmountController.text);
    expenseData.value.groupDataModel = selectedGroup;
    expenseData.value.createdAt = selectedDate;
    print("DD : ${expenseData.value.createdAt}");
    expenseData.value.payerId = selectedPaidUser.value;
  }

  Future<void> addExpense(BuildContext context) async {
    GroupController groupController = Get.find<GroupController>();

    String groupId = expenseData.value.groupDataModel!.id!;
    String expenseId = expenceRef.doc().id;
    DocumentReference userExpensesDocRef = expenceRef.doc(groupId);

    DocumentSnapshot snapshot = await userExpensesDocRef.get();

    Expense expense = Expense(
        expenseId: expenseId,
        title: expenseData.value.title,
        amount: expenseData.value.amount,
        payerId: expenseData.value.payerId,
        behalfAddUser: GroupMember(user: groupController.loggedInUser!),
        createdAt: expenseData.value.createdAt,
        splitExpenseAt: DateTime.now(),
        groupId: groupId,
        splitMode: expenseData.value.splitMode,
        equality: expenseData.value.equality);

    if (!snapshot.exists) {
      await userExpensesDocRef.set({
        'expenses': [expense.toMap()]
      }).then((value) async {
        Get.back();
        Get.back();
        Get.back();
        Get.back();
        Get.back();

        MessageModel message = MessageModel(
            messageId: uuid.v1(),
            message: expense.title,
            sender: groupController.loggedInUser!.mobileNo,
            createdTime: DateTime.now(),
            isSeen: false,
            expenseId: expense.expenseId);

        await groupController.sendMessage(message, groupId);
        await AppStorage().incrementExpenseCount();
        showInSnackBar(context, "Expense added successfully", isSuccess: true);

        clearControl();
        dateController.clear();
      });
    } else {
      await userExpensesDocRef.update({
        'expenses': FieldValue.arrayUnion([expense.toMap()])
      }).then((value) async {
        Get.back();
        Get.back();
        Get.back();
        Get.back();
        Get.back();

        MessageModel message = MessageModel(
            messageId: uuid.v1(),
            message: expense.title,
            sender: groupController.loggedInUser!.mobileNo,
            createdTime: DateTime.now(),
            isSeen: false,
            expenseId: expense.expenseId);

        await groupController.sendMessage(message, groupId);
        await AppStorage().incrementExpenseCount();
        showInSnackBar(context, "Expense added successfully", isSuccess: true);

        clearControl();
        dateController.clear();
      });
    }
  }

  clearControl() {
    expenseData.value = Expense();
    selectedDate = null;
    expenseDescriptionController.clear();
    expenseAmountController.clear();
    selectedFormateDate.value = "";
    selectedPaidUser.value = null;
    selectedPaidContact.value = null;
    dateController.text = "";
    userShares.clear();
    userPercentages.clear();
    userAmounts.clear();
    splitAmounts.clear();
    selectedUsers.clear();
  }

  Future<void> editExpense(BuildContext context, String groupId,
      String expenseId, Expense updatedExpenseData) async {
    DocumentReference groupDocRef =
        FirebaseFirestore.instance.collection('expenses').doc(groupId);

    // try {
    DocumentSnapshot snapshot = await groupDocRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> expensesList = data['expenses'];

      int expenseIndex = expensesList
          .indexWhere((expense) => expense['expenseId'] == expenseId);

      if (expenseIndex != -1) {
        expensesList[expenseIndex] = updatedExpenseData.toMap();

        await groupDocRef.update({'expenses': expensesList});
        Get.back();
        Get.back();
        Get.back();
        Get.back();
        showInSnackBar(context, "Expense updated successfully",
            isSuccess: true);
        clearControl();
        dateController.clear();
      } else {
        showInSnackBar(context, "Expense not found", isSuccess: false);
      }
    } else {
      showInSnackBar(context, "Group not found", isSuccess: false);
    }
    // } catch (e) {
    //   showInSnackBar("Error updating expense: $e", isSuccess: false);
    // }
  }

  Future<Expense?> fetchExpense(String groupId, String expenseId) async {
    try {
      DocumentSnapshot docSnapshot = await expenceRef.doc(groupId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> docData =
            docSnapshot.data()! as Map<String, dynamic>;
        List<dynamic> expensesData = docData['expenses'];
        for (var expenseData in expensesData) {
          if (expenseData['expenseId'] == expenseId) {
            return Expense.fromMap(expenseData);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching expense: $e');
      return null;
    }
  }

  Future<Expense?> fetchSettleUpExpense(String groupId) async {
    try {
      DocumentSnapshot docSnapshot = await expenceRef.doc(groupId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> docData =
            docSnapshot.data()! as Map<String, dynamic>;
        List<dynamic> expensesData = docData['expenses'];
        for (var expenseData in expensesData) {
          // if (expenseData['expenseId'] == expenseId) {
          return Expense.fromMap(expenseData);
          // }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching expense: $e');
      return null;
    }
  }

  Future<void> deleteExpense(
      BuildContext context, String groupId, String expenseId) async {
    var groupDocRef = expenceRef.doc(groupId);

    try {
      var groupDocSnapshot = await groupDocRef.get();
      if (!groupDocSnapshot.exists) {
        throw Exception("Group document does not exist!");
      }

      var groupData = groupDocSnapshot.data() as Map<String, dynamic>;
      if (groupData.isEmpty || groupData['expenses'] == null) {
        throw Exception("Group data or expenses list is null!");
      }

      var expensesList = List<Map<String, dynamic>>.from(groupData['expenses']);

      expensesList.removeWhere((expense) => expense['expenseId'] == expenseId);

      await groupDocRef.update({'expenses': expensesList}).then((value) async {
        await deleteMessagesWithExpenseId(groupId, expenseId);
        Get.back();
        Get.back();
        showInSnackBar(context, "Expense deleted successfully!");
      });
    } catch (e) {
      print("Error deleting expense: $e");
    }
  }

  Future<void> deleteMessagesWithExpenseId(
      String groupId, String expenseId) async {
    var firestore = FirebaseFirestore.instance;
    var messagesRef = firestore
        .collection('conversation')
        .doc(groupId)
        .collection('messages');

    try {
      // Query messages with the specific expenseId
      var querySnapshot =
          await messagesRef.where('expenseId', isEqualTo: expenseId).get();

      // Iterate and delete each message
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Optionally, you can provide some feedback or update the UI after successful deletion
      print("All messages with expenseId $expenseId are deleted successfully.");
    } catch (e) {
      print("Error deleting messages: $e");
      // Handle any errors here, such as showing an error message to the user
    }
  }

  List<double> getAmountsForUsers(Expense expense, List<GroupMember> userData) {
    List<double> amounts = [];
    for (var user in userData) {
      double amount = 0.0;
      for (var equalityEntry in expense.equality!) {
        if (equalityEntry.userId == user.user.mobileNo) {
          amount = equalityEntry.amount;
          break;
        }
      }
      amounts.add(amount);
    }
    return amounts;
  }

  Stream<double> fetchTotalReceivableAmount(String userId) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String normalizedUserId = calculateLast10Digits(userId);

    return firestore.collection('expenses').snapshots().map((querySnapshot) {
      double totalReceivableAmount = 0.0;

      for (var groupDoc in querySnapshot.docs) {
        var data = groupDoc.data();
        if (groupDoc.exists && data.containsKey('expenses')) {
          List<dynamic> expensesList = data['expenses'];

          for (var expenseData in expensesList) {
            Expense expense =
                Expense.fromMap(expenseData as Map<String, dynamic>);

            if (expense.payerId?.user.mobileNo == normalizedUserId) {
              for (var equality in expense.equality!) {
                if (equality.userId != normalizedUserId) {
                  totalReceivableAmount += equality.amount;
                }
              }
            }
          }
        }
      }
      return totalReceivableAmount;
    });
  }

  Stream<double> fetchTotalGroupAmountForUser(String groupId, String userId) {
    String normalizedUserId = calculateLast10Digits(userId);

    return expenceRef.doc(groupId).snapshots().map((docSnapshot) {
      double balance = 0.0;

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> docData =
            docSnapshot.data()! as Map<String, dynamic>;

        if (docData.containsKey('expenses')) {
          List<dynamic> expensesData = docData['expenses'];

          for (var expenseData in expensesData) {
            Expense expense = Expense.fromMap(expenseData);

            // Add the total expense amount if the user is the payer
            if (expense.payerId!.user.mobileNo == normalizedUserId) {
              balance += expense.amount!;
            }

            // Subtract the user's share in each expense
            for (var equality in expense.equality!) {
              if (equality.userId.contains(normalizedUserId)) {
                balance -= equality.amount;
              }
            }
          }
        }
      }

      return balance;
    });
  }

  Stream<Map<String, double>> fetchBalancesStream(
      List<String> groupIds, String userId) {
    var controller = StreamController<Map<String, double>>();

    double totalPositiveBalance = 0.0;
    double totalNegativeBalance = 0.0;
    Map<String, double> groupBalances = {};

    void updateBalances() {
      totalPositiveBalance = 0.0;
      totalNegativeBalance = 0.0;

      groupBalances.forEach((groupId, balance) {
        if (balance > 0) {
          totalPositiveBalance += balance;
        } else if (balance < 0) {
          totalNegativeBalance += balance;
        }
      });

      controller.add(
          {'positive': totalPositiveBalance, 'negative': totalNegativeBalance});
    }

    for (String groupId in groupIds) {
      fetchTotalGroupAmountForUser(groupId, userId).listen((balance) {
        groupBalances[groupId] = balance;
        updateBalances();
      });
    }

    return controller.stream;
  }

  Stream<Map<String, double>> fetchGroupBalancesStream(
      String groupId, String userId) {
    var controller = StreamController<Map<String, double>>();

    double totalPositiveBalance = 0.0;
    double totalNegativeBalance = 0.0;
    Map<String, double> groupBalances = {};

    void updateBalances() {
      totalPositiveBalance = 0.0;
      totalNegativeBalance = 0.0;

      groupBalances.forEach((groupId, balance) {
        if (balance > 0) {
          totalPositiveBalance += balance;
        } else if (balance < 0) {
          totalNegativeBalance += balance;
        }
      });

      controller.add(
          {'positive': totalPositiveBalance, 'negative': totalNegativeBalance});
    }

    fetchTotalGroupAmountForUser(groupId, userId).listen((balance) {
      groupBalances[groupId] = balance;
      updateBalances();
    });

    return controller.stream;
  }

  Stream<double> fetchTotalAmountForUser(String userId) {
    String normalizedUserId = calculateLast10Digits(userId);

    return expenceRef.snapshots().map((snapshot) {
      double totalAmount = 0.0;

      // Iterate over each group document
      for (var doc in snapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
          if (docData.containsKey('expenses')) {
            List<dynamic> expensesData = docData['expenses'];

            // Process each expense in the group
            for (var expenseData in expensesData) {
              Expense expense = Expense.fromMap(expenseData);

              // If the user is not the payer, calculate their share
              if (expense.payerId!.user.mobileNo != normalizedUserId) {
                for (var equality in expense.equality!) {
                  if (equality.userId.contains(normalizedUserId)) {
                    totalAmount += equality.amount;
                  }
                }
              }
            }
          }
        }
      }

      return totalAmount;
    });
  }

  Stream<double> getSpentExpenseForGroup(String groupId) {
    return expenceRef.doc(groupId).snapshots().map((snapshot) {
      double total = 0.0;
      var data = snapshot.data();
      if (data != null) {
        var expenses =
            (data as Map<String, dynamic>)['expenses'] as List<dynamic>;
        for (var expense in expenses) {
          double amount = (expense['amount'] ?? 0.0).toDouble();
          total += amount;
        }
      } else {
        return total;
      }
      return total;
    });
  }

  List<ContactModel?> getContactDataByNumbers(List<String> contactNumbers) {
    final contactData = contactNumbers.map((numberToCheck) {
      final last10Digits = calculateLast10Digits(numberToCheck);

      final contact = appContactServices.appContacts.firstWhere(
        (c) => calculateLast10Digits(c.contactNumber!) == last10Digits,
        orElse: () => ContactModel(contactNumber: numberToCheck),
      );
      userController.fetchAppUser(last10Digits);
      return contact;
    }).toList();

    return contactData;
  }

  /*List<ContactModel?> getSettleUpContactDataByNumbers(
      List<String> contactNumbers,
      {String? excludeNumber}) {
    final contactData = contactNumbers
        .map((numberToCheck) {
          final last10Digits = calculateLast10Digits(numberToCheck);

          final contact =
              groupController.appContactServices.appContacts.firstWhere(
            (c) =>
                calculateLast10Digits(c.contactNumber!) == last10Digits &&
                (calculateLast10Digits(c.contactNumber!) !=
                    calculateLast10Digits(
                        groupController.loggedInUser!.mobileNo!)),
            orElse: () => ContactModel(contactNumber: numberToCheck),
          );
          return contact;
        })
        .where((contact) => (!calculateLast10Digits(contact.contactNumber ??
                groupController.loggedInUser!.mobileNo!)
            .contains(calculateLast10Digits(
                groupController.loggedInUser!.mobileNo!))))
        .toList();

    return contactData;
  }*/

  Future<List<Expense>> fetchExpenses(String groupId) async {
    try {
      DocumentSnapshot groupDoc = await expenceRef.doc(groupId).get();

      if (groupDoc.exists && groupDoc.data() != null) {
        var data = groupDoc.data() as Map<String, dynamic>;
        List<dynamic> expensesData = data['expenses'];
        List<Expense> expenses = expensesData
            .map((expenseData) => Expense.fromMap(expenseData))
            .toList();
        return expenses;
      } else {
        return [];
      }
    } catch (e) {
      // Handle any errors here
      print('Error fetching expenses: $e');
      return [];
    }
  }

  double calculateProgress(double spentAmount, double estimatedAmount) {
    if (estimatedAmount <= 0) return 0.0;

    double progress = spentAmount / estimatedAmount;

    if (progress > 1.0) {
      return 1.0;
    } else if (progress < 0.0) {
      return 0.0;
    } else {
      return progress;
    }
  }

  String calculateLast10Digits(String contactNumber) {
    final normalizedNumber = contactNumber.replaceAll(RegExp(r'[^\d]'), '');

    return normalizedNumber;
  }

  ///=======================================================================================
  /// Split Amount
  ///=======================================================================================

  List<UserTransaction> settleGroupExpenses(
      List<Expense> expenses, int totalUsers) {
    // Step 1: Calculate each user's total contribution for each expense in cents, including the payer user.
    Map<String, int> contributions = {};
    for (var expense in expenses) {
      if (expense.payerId!.user.mobileNo != null) {
        // Handle the case where payerId is null (optional, based on your requirements)
        continue;
      }

      for (var equality in expense.equality!) {
        var userId = equality.userId;
        var amountInCents = (equality.amount * 100).toInt(); // Convert to cents

        if (contributions.containsKey(userId)) {
          contributions[userId] = contributions[userId]! + amountInCents;
        } else {
          contributions[userId] = amountInCents;
        }

        // Deduct the contribution from the payer's balance
        contributions[expense.payerId!.user.mobileNo!] =
            contributions[expense.payerId!.user.mobileNo]! - amountInCents;
      }
    }

    // Step 2: Calculate the total group expenses in cents.
    int totalGroupExpensesInCents = (expenses
            .fold(0.0, (sum, expense) => sum + (expense.amount! * 100))
            .toInt())
        .toInt();

    // Step 3: Calculate the average expense per user in cents.
    int averageExpenseInCents =
        totalUsers != 0 ? totalGroupExpensesInCents ~/ totalUsers : 0;

    // Step 4: Calculate each user's balance in cents.
    Map<String, int> balances = {};
    for (var userId in contributions.keys) {
      balances[userId] = contributions[userId]! - averageExpenseInCents;
    }

    // Step 5: Determine who owes and who is owed.
    List<String> oweList = [];
    List<String> owedList = [];
    for (var userId in balances.keys) {
      if (balances[userId]! < 0) {
        oweList.add(userId);
      } else if (balances[userId]! > 0) {
        owedList.add(userId);
      }
    }

    // Step 6: Sort the lists to optimize transactions.
    oweList.sort((a, b) => balances[a]!.compareTo(balances[b]!));
    owedList.sort((a, b) => balances[b]!.compareTo(balances[a]!));

    // Step 7: Create transactions to settle balances in cents.
    List<UserTransaction> transactions = [];
    while (oweList.isNotEmpty && owedList.isNotEmpty) {
      var currentOwe = oweList.first;
      var currentOwed = owedList.first;

      int paymentInCents = balances[currentOwe]! < -balances[currentOwed]!
          ? balances[currentOwe]!
          : -balances[currentOwed]!;

      double payment = paymentInCents / 100.0;

      transactions.add(UserTransaction(
        debtorUserId: currentOwe,
        creditorUserId: currentOwed,
        amount: payment,
      ));

      balances[currentOwe] = (balances[currentOwe] ?? 0) + paymentInCents;
      balances[currentOwed] = (balances[currentOwed] ?? 0) + paymentInCents;

      if (balances[currentOwe]! == 0) {
        oweList.removeAt(0);
      }
      if (balances[currentOwed]! == 0) {
        owedList.removeAt(0);
      }
    }

    // Step 8: Split the remaining balances evenly among all group members.
    // int remainingBalanceInCents =
    //     balances.values.reduce((sum, balance) => sum + balance);
    //
    // int splitAmountInCents =
    //     totalUsers != 0 ? remainingBalanceInCents ~/ totalUsers : 0;

    // Step 9: Create transactions to split the remaining balances.
    // for (var userId in balances.keys) {
    //   double splitPayment = splitAmountInCents / 100.0;
    //   transactions.add(UserTransaction(userId, userId, splitPayment));
    // }

    return transactions;
  }

  List<UserTransaction> settleIndividualExpenses(List<Expense> expenses) {
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

    // Step 3: Generate transactions to settle up
    List<UserTransaction> transactions = [];

    contributions.forEach((userId, amount) {
      if (amount > fairShare) {
        transactions.add(UserTransaction(
            debtorUserId: userId,
            creditorUserId: 'group',
            amount: amount - fairShare));
      } else if (amount < fairShare) {
        transactions.add(UserTransaction(
            debtorUserId: 'group',
            creditorUserId: userId,
            amount: fairShare - amount));
      }
    });

    return transactions;
  }

  bool hasDistributedTotalAmount() {
    double totalAmount = expenseData.value.amount!;
    double totalEnteredAmount = userInputAmount();
    return totalAmount == totalEnteredAmount;
  }

  double userInputAmount() {
    double totalAmount = 0.0;
    if (expenseData.value.splitMode == SplitMode.Equally.name) {
      totalAmount = splitAmounts.values.fold(0, (sum, amount) => sum + amount);
    } else if (expenseData.value.splitMode == SplitMode.Amount.name) {
      totalAmount = userAmounts.values.fold(0, (sum, amount) => sum + amount);
    } else if (expenseData.value.splitMode == SplitMode.Percentage.name) {
      double total = expenseData.value.amount!;
      totalAmount = userPercentages.values
          .fold(0, (sum, percentage) => sum + (total * percentage / 100));
    } else if (expenseData.value.splitMode == SplitMode.Share.name) {
      double totalShares =
          userShares.values.fold(0, (sum, share) => sum + share);
      double shareValue =
          totalShares > 0 ? expenseData.value.amount! / totalShares : 0;
      totalAmount =
          userShares.values.fold(0, (sum, share) => sum + (shareValue * share));
    }
    return totalAmount;
  }

  ///=========================================================================================
  /// Generate PDF Invoice
  ///=========================================================================================

// Future<pw.Font> loadCustomFont() async {
//   final fontData = await rootBundle.load('asset/fonts/arial.ttf');
//   return pw.Font.ttf(fontData);
// }

// Future<File> generateInvoicePdf(GroupDataModel groupdata) async {
//   final pdf = pw.Document();
//
//   final image = await rootBundle.load(AppImages.split_logo_png);
//   final imageProvider = pw.MemoryImage(
//     image.buffer.asUint8List(),
//   );
//
//   final customFont = await loadCustomFont();
//
//   List<UserTransaction> transactions = [
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//     UserTransaction("Wade Warren", "Darrell Steward", 10000),
//   ];
//
//   pdf.addPage(
//     pw.MultiPage(
//       build: (context) => [
//         pw.Header(
//           padding: const pw.EdgeInsets.symmetric(vertical: 20),
//           level: 0,
//           child: pw.Image(imageProvider, height: 120, width: 120),
//         ),
//         pw.SizedBox(height: 25),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pw.CrossAxisAlignment.end,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Split Group Expenses:',
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold, fontSize: 17)),
//                 pw.SizedBox(height: 8),
//                 pw.Text('Group Name : ${groupdata.name}',
//                     style: const pw.TextStyle(fontSize: 16)),
//                 pw.Divider(
//                     height: 30, color: const PdfColor.fromInt(0xFFFFFFFF)),
//                 pw.Table.fromTextArray(
//                   columnWidths: {
//                     0: const pw.FixedColumnWidth(150),
//                     1: const pw.FixedColumnWidth(150),
//                     2: const pw.FixedColumnWidth(170),
//                   },
//                   headerStyle: pw.TextStyle(font: customFont),
//                   cellStyle: pw.TextStyle(font: customFont),
//                   border: pw.TableBorder.all(
//                     color: PdfColors.black,
//                     width: 1,
//                     style: pw.BorderStyle.solid,
//                   ),
//                   headers: ['From', 'To', 'Amount'],
//                   cellAlignments: {
//                     0: pw.Alignment.center,
//                     1: pw.Alignment.center,
//                     2: pw.Alignment.center,
//                   },
//                   data: transactions.map((transaction) {
//                     return [
//                       transaction.payer,
//                       transaction.receiver,
//                       '${userController.currencySymbol}${transaction.amount}',
//                     ];
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 30),
//         pw.Footer(
//           leading: pw.Align(
//             alignment: pw.Alignment.centerLeft,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Splitx',
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold, fontSize: 14)),
//                 pw.SizedBox(
//                   height: 4,
//                 ),
//                 pw.Text('We Look Forward to Serving You Again!',
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold, fontSize: 12)),
//               ],
//             ),
//           ),
//           trailing: pw.Image(imageProvider, height: 70, width: 70),
//         )
//       ],
//     ),
//   );
//
//   final String dir = (await getApplicationDocumentsDirectory()).path;
//   final String path = '$dir/Split_invoice.pdf';
//   final File file = File(path);
//   await file.writeAsBytes(await pdf.save());
//   return file;
// }
}

class UserBalance {
  String userId;
  double balance;

  UserBalance(this.userId, this.balance);
}

class UserTransaction {
  final String debtorUserId;
  final String creditorUserId;
  final double amount;

  UserTransaction({
    required this.debtorUserId,
    required this.creditorUserId,
    required this.amount,
  });
}

class PersonBalance {
  String person;
  double balance;

  PersonBalance(this.person, this.balance);
}

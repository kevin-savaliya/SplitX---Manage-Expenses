// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';

class ExpenseHistoryController extends GetxController {
  CollectionReference expensesRef =
      FirebaseFirestore.instance.collection("expenses");

  RxList<Expense> expenseData = <Expense>[].obs;

  // RxList<Expense> expenseGroupData = <Expense>[].obs;
  RxList<Expense> filteredExpenseData = <Expense>[].obs;

  // RxList<Expense> filteredGroupExpenseData = <Expense>[].obs;

  // Map<String, GroupDataModel> groupDataCache = {};

  RxList<String> groupIds = <String>[].obs;
  var allGroups = <GroupDataModel>[].obs;

  User? currentUser = FirebaseAuth.instance.currentUser;
  RxBool hasSearchEnabled = false.obs;
  RxBool hasGroupSearchEnabled = false.obs;

  CollectionReference groupRef =
      FirebaseFirestore.instance.collection("groups");

  GroupController groupController = Get.find<GroupController>();
  String? loggedInMobileNo;

  @override
  Future<void> onInit() async {
    super.onInit();
    loggedInMobileNo = groupController.loggedInUser?.mobileNo!;
    groupIds.value = await fetchUserGroupIdsByMobile(
        groupController.loggedInUser!.mobileNo!);
    // expenseData.value = await fetchExpensesByGroupIds(groupIds);
  }

  Future<List<Expense>> fetchExpensesByGroupId(String groupId) async {
    List<Expense> expenses = [];

    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(groupId)
          .get();

      if (groupDoc.exists) {
        var expensesData =
            groupDoc.get('expenses'); // Assuming 'expenses' is your field name

        if (expensesData != null) {
          List<dynamic> expensesList = expensesData as List<dynamic>;
          expenses = expensesList
              .map((expenseMap) =>
                  Expense.fromMap(expenseMap as Map<String, dynamic>))
              .toList();

          // Sort expenses by createdAt in descending order
          expenses.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        }
      }
    } catch (e) {
      print('Error fetching expenses for group $groupId: $e');
    }

    return expenses;
  }

  Future<List<Expense>> fetchExpensesByGroupIds(List<String> groupIds) async {
    List<Expense> allExpenses = [];

    try {
      for (String groupId in groupIds) {
        DocumentSnapshot groupDoc = await FirebaseFirestore.instance
            .collection('expenses')
            .doc(groupId)
            .get();

        if (groupDoc.exists) {
          var expensesData = groupDoc.get('expenses');

          if (expensesData != null) {
            List<dynamic> expensesList = expensesData as List<dynamic>;

            List<Expense> expenses = expensesList
                .map((expenseMap) =>
                    Expense.fromMap(expenseMap as Map<String, dynamic>))
                .toList();

            allExpenses.addAll(expenses);
          }
        }
      }

      allExpenses
          .sort((a, b) => b.splitExpenseAt!.compareTo(a.splitExpenseAt!));
      expenseData.clear();
      expenseData.addAll(allExpenses);
      filteredExpenseData.clear();
      filteredExpenseData.value.addAll(allExpenses);
    } catch (e) {
      print("Error Occurred: $e");
      return [];
    }

    return allExpenses;
  }

  void fetchAllGroups() {
    groupRef.snapshots().listen((snapshot) {
      allGroups.value = snapshot.docs
          .map((doc) =>
          GroupDataModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  GroupDataModel? getGroupData(String groupId) {
    return allGroups.firstWhere((group) => group.id == groupId,
        orElse: () => GroupDataModel());
  }

  Future<List<String>> fetchActiveGroupIdsForUser(
      String userMobileNumber) async {
    List<String> activeGroupIds = [];

    try {
      var groupsSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      for (var groupDoc in groupsSnapshot.docs) {
        var groupData =
            GroupDataModel.fromMap(groupDoc.data() as Map<String, dynamic>);

        bool isActiveMember = groupData.memberIds?.any((member) =>
                member.user.mobileNo == userMobileNumber &&
                member.status == 'active') ??
            false;

        if (isActiveMember) {
          activeGroupIds
              .add(groupDoc.id); // Assuming the document ID is the group ID
        }
      }
    } catch (e) {
      print('Error fetching active group IDs: $e');
    }

    return activeGroupIds;
  }

  Future<List<Expense>> fetchDashboardExpensesByGroupIds(
      List<String> groupIds) async {
    List<Expense> allExpenses = [];

    try {
      for (String groupId in groupIds) {
        DocumentSnapshot groupDoc = await FirebaseFirestore.instance
            .collection('expenses')
            .doc(groupId)
            .get();

        if (groupDoc.exists) {
          var expensesData = groupDoc.get('expenses');

          if (expensesData != null) {
            List<dynamic> expensesList = expensesData as List<dynamic>;

            List<Expense> expenses = expensesList
                .map((expenseMap) =>
                    Expense.fromMap(expenseMap as Map<String, dynamic>))
                .toList();

            allExpenses.addAll(expenses);
          }
        }
      }

      // Sort the expenses in descending order by splitExpenseAt
      allExpenses
          .sort((a, b) => b.splitExpenseAt!.compareTo(a.splitExpenseAt!));

      // Return the top 3 expenses
      return allExpenses.length > 10 ? allExpenses.sublist(0, 10) : allExpenses;
    } catch (e) {
      print(e);
      return [];
    }
  }

  String? getContactByPhoneNumber(String phoneNumber) {
    try {
      String sanitizedPhoneNumber =
          phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      return sanitizedPhoneNumber;
    } catch (e) {
      return null;
    }
  }

  Stream<GroupDataModel?> fetchGroupData(String groupId) {
    return groupRef.doc(groupId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<List<String>> fetchUserGroupIdsByMobile(String userMobileNo) async {
    String? normalizedUserId = getContactByPhoneNumber(userMobileNo);
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      List<String> userGroupIds = [];
      for (var doc in querySnapshot.docs) {
        var group = GroupDataModel.fromMap(doc.data() as Map<String, dynamic>);

        // Check if the user is a member with 'active' status
        bool isActiveMember = group.memberIds?.any((member) =>
                member.user.mobileNo == normalizedUserId &&
                member.status == 'active') ??
            false;

        if (isActiveMember) {
          userGroupIds
              .add(doc.id); // Add the group ID if the user is an active member
        }
      }

      groupIds.assignAll(userGroupIds);

      return userGroupIds;
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  // Future<List<String>> fetchUserGroupIdsByMobile(String userMobileNo) async {
  //   String? normalizedUserId = getContactByPhoneNumber(userMobileNo);
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('groups').get();
  //
  //     List<String> userGroupIds = [];
  //     for (var doc in querySnapshot.docs) {
  //       var group = GroupDataModel.fromMap(doc.data() as Map<String, dynamic>);
  //       if (isUserMember(group, normalizedUserId!)) {
  //         userGroupIds.add(doc.id);
  //       }
  //     }
  //
  //     return userGroupIds;
  //   } catch (e) {
  //     print("Error : $e");
  //     return [];
  //   }
  // }

  bool isUserMember(GroupDataModel group, String normalizedUserId) {
    return group.memberIds?.any((member) =>
            member.user.mobileNo != null &&
            member.user.mobileNo!.contains(normalizedUserId)) ??
        false;
  }

  void closeSearchExpense() {
    hasSearchEnabled.value = false;
    filteredExpenseData.value.clear();
    filteredExpenseData.value.addAll(expenseData.toList());
    update(["history", "toolbar"]);
  }

  void searchExpense(String query) {
    if (hasSearchEnabled.value == false) {
      hasSearchEnabled.value = true;
    }

    if (query.isEmpty) {
      filteredExpenseData.value.clear();
      filteredExpenseData.value.addAll(expenseData.toList());
      update(["history", "toolbar"]);
      return;
    }

    List<Expense> data = expenseData
        .toList()
        .where((expense) =>
            expense.title!.toLowerCase().contains(query.toLowerCase()) ||
            (expense.groupDataModel?.name ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    filteredExpenseData.value.clear();
    filteredExpenseData.value.addAll(data.toList());
    print("Filtered Data Length: ${filteredExpenseData.length}");

    update(["history", "toolbar"]);
    update();
  }
}

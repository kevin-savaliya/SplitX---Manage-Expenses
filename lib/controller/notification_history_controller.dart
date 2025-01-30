// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/notification_data.dart';
import 'package:uuid/uuid.dart';

class NotificationController extends GetxController {
  CollectionReference notificationsRef = FirebaseFirestore.instance.collection("notification");

  RxList<NotificationData> notificationList = <NotificationData>[].obs;
  RxList<GroupDataModel> userGroups = <GroupDataModel>[].obs;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final UserController userController = Get.find<UserController>();

  CollectionReference groupRef = FirebaseFirestore.instance.collection("groups");

  GroupController groupController = Get.find<GroupController>();
  String? loggedInMobileNo;
  late Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream;

  @override
  Future<void> onInit() async {
    super.onInit();
    getNotifications();
    print('userId ${currentUser?.uid}');
    notificationsStream = FirebaseFirestore.instance.collection('notifications').doc(FirebaseAuth.instance.currentUser?.uid).collection('notifications').snapshots();
    loggedInMobileNo = groupController.loggedInUser?.mobileNo!;
    if (loggedInMobileNo != null) {
      fetchUserGroupIdsByMobile(loggedInMobileNo!);
    }
  }


  getNotifications() async {
    FirebaseFirestore.instance
        .collection('notification')
        .orderBy('createdAt', descending: true)
        .where('customerId', arrayContains: '${currentUser?.uid}')
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          print('${value.docs}');
          NotificationData notificationData = NotificationData.fromJson(element.data());
          notificationList.add(notificationData);
          print('------notification length >${notificationList.length}');
        }
      },
    );
  }

  // Stream<GroupDataModel?> fetchGroupData(String groupId) {
  //   return groupRef.doc(groupId).snapshots().map((snapshot) {
  //     if (snapshot.exists) {
  //       return GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);
  //     }
  //     return null;
  //   });
  // }

  deleteNotifications(){
     FirebaseFirestore.instance.collection('notification').where('customerId', arrayContains: '${currentUser?.uid}').get().then((snapshot) {
       for (DocumentSnapshot ds in snapshot.docs) {
         print('------delete notification---->${snapshot.docs.length}');
         ds.reference.delete();
       }
     });
   }

  Future<List<Expense>> fetchExpensesByGroupIds(List<String> groupIds) async {
    List<Expense> allExpenses = [];

    try {
      for (String groupId in groupIds) {
        DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('expenses').doc(groupId).get();

        if (groupDoc.exists) {
          var expensesData = groupDoc.get('expenses');

          if (expensesData != null) {
            List<dynamic> expensesList = expensesData as List<dynamic>;

            List<Expense> expenses = expensesList.map((expenseMap) => Expense.fromMap(expenseMap as Map<String, dynamic>)).toList();

            allExpenses.addAll(expenses);
          }
        }
      }
    } catch (e) {
      print(e);
      return [];
    }

    return allExpenses;
  }

  Future<List<Expense>> fetchDashboardExpensesByGroupIds(List<String> groupIds) async {
    List<Expense> allExpenses = [];

    try {
      for (String groupId in groupIds) {
        if (allExpenses.length >= 3) {
          // If we already have 3 expenses, break out of the loop.
          break;
        }

        DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('expenses').doc(groupId).get();

        if (groupDoc.exists) {
          var expensesData = groupDoc.get('expenses');

          if (expensesData != null) {
            List<dynamic> expensesList = expensesData as List<dynamic>;

            List<Expense> expenses = expensesList.map((expenseMap) => Expense.fromMap(expenseMap as Map<String, dynamic>)).toList();

            // Add expenses to allExpenses but do not exceed 3 in total
            for (var expense in expenses) {
              if (allExpenses.length < 3) {
                allExpenses.add(expense);
              } else {
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
      return [];
    }

    return allExpenses;
  }

  String? getContactByPhoneNumber(String phoneNumber) {
    try {
      String sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      return sanitizedPhoneNumber;
    } catch (e) {
      return null;
    }
  }

  /*Stream<GroupDataModel?> fetchGroupData(String groupId) {
    return groupRef.doc(groupId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }*/

  Future<GroupDataModel?> fetchGroupData(String groupId) {
    return groupRef.doc(groupId).get().then((snapshot) {
      if (snapshot.exists) {
        return GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
    /*return groupRef.doc(groupId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });*/
  }

  Future<List<String>> fetchUserGroupIdsByMobile(String userMobileNo) async {
    String? normalizedUserId = getContactByPhoneNumber(userMobileNo);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('groups').get();
      List<String> userGroupIds = [];
      for (var doc in querySnapshot.docs) {
        var group = GroupDataModel.fromMap(doc.data() as Map<String, dynamic>);

        bool isMember = 
            group.memberIds?.any((member) => member.user.mobileNo == normalizedUserId) ?? false;

        if (isMember) {
          userGroupIds.add(doc.id);
          userGroups.add(group);
        }
      }

      return userGroupIds;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<GroupDataModel?> fetchUserGroupById(String groupId) async {
    int groupIndex = 0;
    if (groupIndex != -1) {
      return userGroups[groupIndex];
    } else {
      GroupDataModel? data = await fetchGroupData(groupId);
      return data;
    }
  }
  static String getUuid() {
    return const Uuid().v4();
  }

  Future<void> deleteNotification(int index) async {
    notificationList.removeAt(index);
    //return await FirebaseFirestore.instance.collection('notification').doc(getUuid()).update({'notification': notificationList});
  }
}

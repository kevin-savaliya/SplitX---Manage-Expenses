import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/country_pick_screen.dart';
import 'package:split/screen/phone_login_screen.dart';
import 'package:split/utils/app_storage.dart';

import '../utils/utils.dart';

class UserController extends GetxController {
  final AppStorage appStorage = AppStorage();

  List<ContactModel> storedContacts = <ContactModel>[].obs;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  RxList<UserModel> allAppUser = RxList<UserModel>();

  // final String uId = FirebaseAuth.instance.currentUser!.uid;
  Stream<QuerySnapshot>? dataSnapShot;

  Rx<UserModel> get user => _user;
  final Rx<UserModel> _user = UserModel.newUser().obs;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Rx<UserModel?> loggedInUser = Rx<UserModel?>(null);
  Rx<String>? userMobileNumber;

  RxString currencySymbol = "".obs;

  final InAppReview inAppReview = InAppReview.instance;

  @override
  Future<void> onInit() async {
    // Future.delayed(const Duration(seconds: 2)).then((value) {
    //   fetchContactList();
    // });
    super.onInit();
    await _fetchUser();
    currencySymbol.value =
        getCurrencySymbol(loggedInUser.value?.currencyCode ?? "INR");
  }

  Future<bool> showReview() async {
    try {
      final available = await inAppReview.isAvailable();
      if (available) {
        Future.delayed(const Duration(seconds: 2), () {
          inAppReview.requestReview();
        });
      } else {
        inAppReview.openStoreListing(appStoreId: 'com.split.expense');
      }
      return true;
    } catch (e) {
      print("Error during in-app review: $e");
      return false;
    }
  }

  // Future fetchAppUser(String mobileNo) {
  //   try {
  //     if (allAppUser.firstWhereOrNull((p0) => p0.mobileNo == mobileNo) !=
  //         null) {
  //       return Future.value(
  //           allAppUser.firstWhereOrNull((p0) => p0.mobileNo == mobileNo));
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   dataSnapShot =
  //       _usersCollection.where('mobileNo', isEqualTo: mobileNo).snapshots();
  //   return dataSnapShot!.forEach((element) {
  //     if (element.docs.isEmpty) {
  //       return;
  //     }
  //
  //     List<UserModel> data = element.docs
  //         .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
  //         .toList();
  //
  //     if (data.isNotEmpty &&
  //         allAppUser
  //             .where((p0) => p0.mobileNo == data.first.mobileNo)
  //             .isEmpty) {
  //       allAppUser.add(data.first);
  //       return;
  //     } else {
  //       return;
  //     }
  //   });
  // }

  Future<void> fetchAppUser(String mobileNo) async {
    try {
      _usersCollection
          .where('mobileNo', isEqualTo: mobileNo)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          UserModel userModel = UserModel.fromMap(
              snapshot.docs.first.data() as Map<String, dynamic>);
          int index =
              allAppUser.indexWhere((user) => user.mobileNo == mobileNo);
          if (index != -1) {
            allAppUser[index] = userModel;
          } else {
            allAppUser.add(userModel);
          }
          update(); // Notify listeners
        }
      });
    } catch (e) {
      print("Error Occurred in fetchAppUser: $e");
    }
  }

  UserModel? getUserData(String? mobileNo) {
    if (mobileNo == null) {
      return null;
    }
    try {
      UserModel? appUser = allAppUser
          .where((p0) =>
              p0.mobileNo?.replaceAll(RegExp(r'[^\d]'), '') ==
              mobileNo.replaceAll(RegExp(r'[^\d]'), ''))
          .first;
      log("App User : ${appUser.mobileNo}");
      return appUser;
    } catch (e) {
      fetchAppUser(mobileNo);
      return null;
    }
  }

  UserModel getUserDataAnyway(String mobileNo) {
    try {
      mobileNo == mobileNo.replaceAll(RegExp(r'[^\d]'), '');
      UserModel? appUser =
          allAppUser.where((p0) => p0.mobileNo == mobileNo).first;
      return appUser;
    } catch (e) {
      // print("Error Occured $mobileNo : $e");
      ContactModel? contact = storedContacts
          .firstWhereOrNull((element) => element.contactNumber == mobileNo);
      try {
        return UserModel(
            mobileNo: mobileNo, name: contact?.contactName ?? "Split User");
      } catch (e) {
        return UserModel(mobileNo: mobileNo, name: mobileNo);
      }
    }
  }

  Future<void> _fetchUser({
    void Function(UserModel? userModel)? onSuccess,
  }) async {
    try {
      final updatedUserData = await streamUser(currentUserId!).first;

      if (updatedUserData != null) {
        loggedInUser.value = updatedUserData;
        // currencySymbol.value =
        //     getCurrencySymbol(loggedInUser.value!.currencyCode ?? "INR");
        if (onSuccess != null) {
          onSuccess(updatedUserData);
        }
      } else {
        log("User data is null");
      }
    } catch (e) {
      log("Error Occured: ${e.toString()}");
    }
  }

  // fetch current logged in user detail using currentUser.uid from users collection from firestore database
  Future<void> fetchUser({
    void Function(UserModel userModel)? onSuccess,
  }) async {
    try {
      streamUser(currentUserId!).listen((updatedUserData) {
        loggedInUser.value = updatedUserData;
        if (onSuccess != null && updatedUserData != null) {
          onSuccess(updatedUserData);
        }
      });
    } catch (e) {
      log("Error Occured 1 : ${e.toString()}");
    }
  }

  Future<UserModel?> getLoggedInUserData() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) return null;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) return null;

    final DocumentSnapshot<Object?> userData =
        await _usersCollection.doc(userId).get();
    if (userData.exists) {
      return UserModel.fromMap(userData.data() as Map<String, dynamic>);
    }
    return null;
  }

  String getCurrencySymbol(String code) {
    return currencyCodeToSymbol[code] ?? code;
  }

  Stream<UserModel?> streamUser(String id) {
    return _usersCollection.doc(id).snapshots().map((documentSnapshot) {
      if (documentSnapshot.data() == null) {
        return null;
      }
      return UserModel.fromMap(
          documentSnapshot.data()! as Map<String, dynamic>);
    });
  }

  Stream<UserModel?> streamOtherUser(String id) {
    return _usersCollection
        .doc(id)
        .snapshots()
        .asyncMap((documentSnapshot) async {
      if (documentSnapshot.data() == null) {
        QuerySnapshot querySnapshot =
            await _usersCollection.where('mobileNo', isEqualTo: id).get();

        if (querySnapshot.docs.isEmpty) {
          return null;
        }
        fetchAppUser(id);
        return UserModel.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return UserModel.fromMap(
          documentSnapshot.data()! as Map<String, dynamic>);
    });
  }

  Future<void> fetchContactList() async {
    // bool isRegistered = Get.isRegistered<AppContactServices>();
    // if (isRegistered) {
    //   await Get.find<AppContactServices>().fetchAndStoreContacts();
    // } else {
    //   await Get.put(AppContactServices()).fetchAndStoreContacts();
    // }
    AppContactServices appContactServices = Get.find<AppContactServices>();
    if (appContactServices.appContacts.isNotEmpty) {
      storedContacts.clear();
      storedContacts.addAll(appContactServices.appContacts);
    }
  }

  String? getNameByPhoneNumber(String? mobileNo) {
    if (mobileNo == null) {
      return null;
    }
    if (loggedInUser.value?.mobileNo == mobileNo) {
      return "You";
    }
    if (storedContacts.isEmpty) {
      return null;
    }
    ContactModel? contactModel = storedContacts.firstWhereOrNull((element) =>
        element.contactNumber?.replaceAll(RegExp(r'[^\d]'), '') == mobileNo);
    if (contactModel != null) {
      return contactModel.contactName;
    } else {
      String? name = allAppUser
          .firstWhereOrNull((element) => element.mobileNo == mobileNo)
          ?.getName();
      if (name != null) {
        return name;
      }
    }
    // return "Deleted User";
    return mobileNo;
  }

  Future<void> deleteUserData(BuildContext context, String userMobile) async {
    // await removeUserFromGroups(userMobile)
    //     .then((value) => print("User Remove From Group"));
    await updateUserStatusInAllGroups(userMobile, 'deleted');
    await deleteUserFromFirestore(userMobile)
        .then((value) => print("User Data Deleted"));
    Get.back();
    showInSnackBar(context, "User Data Deleted Successfully");
    await Get.offAll(() => const CountryPickScreen());
  }

  String? getSplitNameByPhoneNumber(String? mobileNo) {
    if (mobileNo == null) {
      return null;
    }
    if (storedContacts.isEmpty) {
      return null;
    }
    ContactModel? contactModel = storedContacts.firstWhereOrNull((element) =>
    element.contactNumber?.replaceAll(RegExp(r'[^\d]'), '') == mobileNo);
    if (contactModel != null) {
      return contactModel.contactName;
    } else {
      String? name = allAppUser
          .firstWhereOrNull((element) => element.mobileNo == mobileNo)
          ?.getName();
      if (name != null) {
        return name;
      }
    }
    return mobileNo;
  }

  Future<String?> fetchUserProfilePicture(
      String mobileNumber) async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection
          .where('mobileNo', isEqualTo: mobileNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        UserModel user = UserModel.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);

        return user.profilePicture;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user profile picture: $e");
      return null;
    }
  }

  Future<void> deleteUserFromFirestore(String userMobileNumber) async {
    try {
      var usersCollection = FirebaseFirestore.instance.collection('users');

      // Query to find the user by mobile number
      var querySnapshot = await usersCollection
          .where('mobileNo', isEqualTo: userMobileNumber)
          .get();

      // Iterate through the query results and delete each user document
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      await deleteUserAccount();
    } catch (e) {
      print("Error Deleting User : $e");
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      print(FirebaseAuth.instance.currentUser!.uid);
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      print('Error deleting user: ${e.message}');
    }
  }

  Future<void> removeUserFromGroups(String userMobileNumber) async {
    try {
      var groupsSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      for (var groupDoc in groupsSnapshot.docs) {
        var groupData = GroupDataModel.fromMap(groupDoc.data());

        bool isMemberListUpdated = false;
        bool isAdminListUpdated = false;

        // Update memberIds if user is found
        var newMemberIds = groupData.memberIds
            ?.where((member) => member.user.mobileNo != userMobileNumber)
            .toList();
        if (newMemberIds?.length != groupData.memberIds?.length) {
          isMemberListUpdated = true;
        }

        // Update adminIds if user is found
        var newAdminIds = groupData.adminIds
            ?.where((admin) => admin.user.mobileNo != userMobileNumber)
            .toList();
        if (newAdminIds?.length != groupData.adminIds?.length) {
          isAdminListUpdated = true;
        }

        // Update the group document if changes were made
        if (isMemberListUpdated || isAdminListUpdated) {
          await groupDoc.reference.update({
            'memberIds': newMemberIds?.map((m) => m.toMap()).toList(),
            'adminIds': newAdminIds?.map((a) => a.toMap()).toList(),
          });
        }
      }
    } catch (e) {
      print('Error removing user from groups: $e');
    }
  }

  Future<void> updateUserStatusInAllGroups(
      String userMobileNumber, String newStatus) async {
    try {
      var groupsSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      for (var groupDoc in groupsSnapshot.docs) {
        var groupData = GroupDataModel.fromMap(groupDoc.data());
        bool isListUpdated = false;

        // Update status in memberIds if user is found
        groupData.memberIds?.forEach((member) {
          if (member.user.mobileNo == userMobileNumber) {
            member.status = newStatus;
            isListUpdated = true;
          }
        });

        // Update status in adminIds if user is found
        groupData.adminIds?.forEach((admin) {
          if (admin.user.mobileNo == userMobileNumber) {
            admin.status = newStatus;
            isListUpdated = true;
          }
        });

        // Update the group document if changes were made
        if (isListUpdated) {
          await groupDoc.reference.update({
            'memberIds': groupData.memberIds?.map((m) => m.toMap()).toList(),
            'adminIds': groupData.adminIds?.map((a) => a.toMap()).toList(),
          });
        }
      }
    } catch (e) {
      print('Error updating user status in groups: $e');
    }
  }
}

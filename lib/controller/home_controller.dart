import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';

class HomeController extends GetxController {
  RxInt pageIndex = 0.obs;

  AppStorage appStorage = AppStorage();

  User? get firebaseUser => FirebaseAuth.instance.currentUser;
  String currentUserid = FirebaseAuth.instance.currentUser!.uid;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  TextEditingController nameController = TextEditingController();

  Rx<UserModel?> loggedInUser = UserModel.newUser().obs;

  RxList<String> groupIds = <String>[].obs;

  String? userId;

  RxList<Contact> contacts = <Contact>[].obs;
  var selectedContacts = <Contact>{}.obs;
  String? loggedInMobileNo;

  // var filteredContacts = <ContactModel>[].obs;

  GroupController groupController = Get.put(GroupController());
  UserController userController = Get.find<UserController>();
  ExpenseController expenseController = Get.put(ExpenseController());
  // AppContactServices appContactServices = Get.find<AppContactServices>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchUserData();
    _fetchUser();
    fetchUser();
    loggedInMobileNo = loggedInUser.value!.mobileNo;
    groupIds.value = await fetchUserGroupIdsByMobile(
        getContactByPhoneNumber(loggedInMobileNo!)!);
    checkUserNameExistOrNot();
    // NotificationService.instance.sendTestNotification();
  }



  Future<void> fetchUserData() async {
    UserModel? user = await userController.getLoggedInUserData();
    if (user != null) {
      loggedInUser.value = user;
      update();
    }
  }

  Future<void> _fetchUser({
    void Function(UserModel? userModel)? onSuccess,
  }) async {
    try {
      streamUser(currentUserid).listen((updatedUserData) {
        loggedInUser.value = updatedUserData;
        if (onSuccess != null) {
          onSuccess(updatedUserData);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchUser({
    void Function(UserModel userModel)? onSuccess,
  }) async {
    try {
      streamUser(currentUserid).listen((updatedUserData) {
        loggedInUser.value = updatedUserData;
        if (onSuccess != null && updatedUserData != null) {
          onSuccess(updatedUserData);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateGroupIdsList() async {
    try {
      // Assuming loggedInMobileNo holds the mobile number of the logged-in user
      String? mobileNumber = loggedInMobileNo;

      if (mobileNumber != null && mobileNumber.isNotEmpty) {
        List<String> updatedGroupIds =
            await fetchUserGroupIdsByMobile(mobileNumber);
        groupIds.value = updatedGroupIds;
        update();
      }
    } catch (e) {
      print("Error updating group IDs: $e");
    }
  }

  checkUserNameExistOrNot() {
    if (firebaseUser != null) {
      _usersCollection
          .doc(currentUserid)
          .get()
          .then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          UserModel userModel =
              UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
          if (userModel.name == null ||
              userModel.name!.isEmpty ||
              userModel.name == " ") {
            log("Checked");
            showDialog(
              barrierDismissible: false,
              context: Get.context!,
              builder: (context) {
                return SimpleDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Enter Name",
                          style: Theme.of(Get.context!)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  fontFamily: AppFont.fontSemiBold,
                                  color: AppColors.darkPrimaryColor,
                                  fontSize: 15),
                        ),
                        GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.darkPrimaryColor,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      ConstString.name,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              fontFamily: AppFont.fontRegular,
                              fontSize: 13,
                              color: AppColors.darkPrimaryColor),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      height: 45,
                      child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: const TextScaler.linear(1)),
                          child: TextFormField(
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkPrimaryColor),
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: AppColors.txtGrey,
                            decoration: InputDecoration(
                              filled: true,
                              enabled: true,
                              fillColor: AppColors.decsGrey,
                              hintText: "Enter Your Name ",
                              prefixIcon: SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 13.5),
                                    child:
                                        SvgPicture.asset(AppIcons.profileIcon),
                                  )),
                              hintStyle: Theme.of(Get.context!)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontFamily: AppFont.fontRegular,
                                      fontSize: 14,
                                      color: AppColors.darkPrimaryColor),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.decsGrey,
                                    fixedSize: const Size(50, 42),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: Text(
                                  ConstString.NoDialogue,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        fontFamily: AppFont.fontMedium,
                                        color: AppColors.darkPrimaryColor,
                                      ),
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (nameController.text.isNotEmpty) {
                                    String name = nameController.text;
                                    saveName(context, name);
                                  } else {
                                    showInSnackBar(context, "Please Enter Name",
                                        title: "The Medic");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    fixedSize: const Size(50, 42),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: Text(
                                  ConstString.save,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        fontFamily: AppFont.fontMedium,
                                        color: AppColors.darkPrimaryColor,
                                      ),
                                )),
                          ),
                        ],
                      ),
                    )
                    //   ],
                    // )
                  ],
                );
              },
            );
          }
        } else {
          showInSnackBar(Get.context!, "User Not Exist");
        }
      });
    }
  }

  void saveName(BuildContext context, String name) {
    if (firebaseUser != null) {
      _usersCollection
          .doc(firebaseUser!.uid)
          .update({'name': name}).then((value) {
        loggedInUser.value = loggedInUser.value?.copyWith(name: name);
        Get.back();
        showInSnackBar(context, "Name Saved Successfully", isSuccess: true);
        nameController.clear();
      }).catchError((error) {
        print("Error : $error");
        nameController.clear();
      });
    }
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

  String? getContactByPhoneNumber(String phoneNumber) {
    try {
      String sanitizedPhoneNumber =
          phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      return sanitizedPhoneNumber;
    } catch (e) {
      return null;
    }
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

  List bottomActiveIconList = [
    AppIcons.home_fill,
    AppIcons.groupFillIcon,
    AppIcons.historyFill,
    AppIcons.profile_fill
  ];

  List bottomInActiveIconList = [
    AppIcons.homeEmpty,
    AppIcons.groupIcon,
    AppIcons.historyIcon,
    AppIcons.profileIcon
  ];

  List bottomLabelList = [
    ConstString.home,
    ConstString.group,
    ConstString.history,
    ConstString.profile,
  ];

  pageUpdateOnHomeScreen(int index, [String? userId]) {
    pageIndex.value = index;

    if (index == 3 && userId != null) {
      this.userId = userId;
    }

    update(['PageUpdate']);
    // update();
  }

  List<Color> itemColorList = [
    AppColors.item1,
    AppColors.item4,
    AppColors.item3,
    AppColors.item8,
    AppColors.item7,
    AppColors.item6,
    AppColors.item2,
    AppColors.item5
  ];
}

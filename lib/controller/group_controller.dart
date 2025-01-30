// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/UserDataModel.dart';
import 'package:split/model/chat_room.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/message_model.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/utils.dart';

class GroupController extends GetxController {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupBudgetController = TextEditingController();

  TextEditingController expenseDescriptionController = TextEditingController();
  TextEditingController expenseAmountController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  User? get firebaseUser => FirebaseAuth.instance.currentUser;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  ContactModel? contactModel;
  RxInt groupIndex = 0.obs;

  GroupDataModel? groupDataModel;
  RxList<Expense?> expenses = <Expense?>[].obs;

  var selectedContacts = <ContactModel>{}.obs;
  List<String> fcmTokenList = [];
  List<String> customerIdList = [];
  List<String> newGroupFcmTokenList = [];
  List<String> newGroupCustomerIdList = [];

  RxBool isLoadContact = false.obs;

  final ScrollController scrollController = ScrollController();

  late Future<bool> messagesSubcollectionExistFuture;

  var selectedGroup = Rx<GroupDataModel?>(null);

  String fcmTokan = '';
  String? customerId;

  var userSuggestions = <String?>[].obs;
  var isSuggestionMode = false.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchGroupController = TextEditingController();
  RxBool hasSearchEnabled = false.obs;
  RxBool hasGroupSearchEnabled = false.obs;
  var filteredContacts = <ContactModel>[].obs;
  var allGroups = <GroupDataModel>[].obs;
  var filteredGroups = <GroupDataModel>[].obs;

  AppStorage appStorage = AppStorage();

  UserController userController = Get.find<UserController>();
  UserModel? loggedInUser;
  UserDataModel? userDataModel;

  final FocusNode messageFocusNode = FocusNode();

  // final ScreenshotController screenshotController = ScreenshotController();
  // final ScreenshotController combinedScreenshotController =
  //     ScreenshotController();
  final GlobalKey offstageKey = GlobalKey();
  Uint8List? capturedScreenshotBytes;

  var isOffstageWidgetVisible = false.obs;

  RxBool isAddExpense = false.obs;

  CollectionReference groupRef =
      FirebaseFirestore.instance.collection('groups');
  CollectionReference expenseRef =
      FirebaseFirestore.instance.collection('expenses');
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  CollectionReference conversationRef =
      FirebaseFirestore.instance.collection('conversation');

  double? totalGroupAmount;
  StreamSubscription<double>? _amountSubscription;
  final ExpenseController expenseController = Get.put(ExpenseController());

  List<MessageModel>? messages;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<List<Expense?>>? _expenseSubscription;
  late AppContactServices appContactServices;
  List<String> expenseIds = [];

  @override
  Future<void> onInit() async {
    appContactServices = Get.put(AppContactServices());
    super.onInit();
    getUser();
    Future.delayed(const Duration(seconds: 5)).then((value) async {
      AppContactServices appContactServices = Get.put(AppContactServices());
      AppContactPermissionStatus permissionStatus =
          await appContactServices.fetchAndStoreContacts();
      if (permissionStatus == AppContactPermissionStatus.assigned) {
        filteredContacts.clear();
        filteredContacts.addAll(appContactServices.appContacts);
      }
    });
    await fetchUserData();
    loadGroups();
  }

  Expense? fetchExpenseForDisplay(String expenseId, List<Expense?> expenses) {
    return expenses.firstWhere(
      (expense) => expense?.expenseId == expenseId,
      orElse: () => null,
    );
  }

  getUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: currentUserId)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          print('${value.docs}');
          userDataModel = UserDataModel.fromJson(element.data());
          print('------user Data >${userDataModel.toString()}');
        }
      },
    );
  }

  getGroup() async {
    // var querySnapshot = await FirebaseFirestore.instance.collection('groups').where('id', isEqualTo: selectedGroup.value?.id).get();
    print('Test == ${selectedGroup.value?.id}');
    fcmTokenList.clear();
    customerIdList.clear();
    await FirebaseFirestore.instance
        .collection('groups')
        .where('id', isEqualTo: selectedGroup.value?.id)
        .get()
        .then(
      (value) {
        print('Test == ${value.docs}');
        // GroupDataModel group = GroupDataModel.fromMap(value.docs as Map<String, dynamic>);
        List<GroupDataModel> temp = value.docs
            .map((doc) =>
                GroupDataModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        for (var element in temp) {
          for (GroupMember member in element.memberIds!) {
            if (member.user.fcmToken != null) {
              fcmTokenList.add(member.user.fcmToken ?? "");
              customerIdList.add(member.user.id ?? "");
              print('------Group length >${fcmTokenList.length}');
              print('------Group Data >${fcmTokenList}');
            }
          }
        }
      },
    );
    print('--customerIdList->${customerIdList}');
    //fcmTokenList = [];
  }

  void selectGroup(GroupDataModel group) {
    selectedGroup.value = group;
    getGroup();
    update();
  }

  void _subscribeToTotalGroupAmount(String groupId) {
    // Replace with your actual group ID and user mobile number
    _amountSubscription = expenseController
        .fetchTotalGroupAmountForUser(
      groupId,
      loggedInUser!.mobileNo!,
    )
        .listen((amount) {
      totalGroupAmount = amount;
      update(); // Triggers a rebuild of GetBuilder widgets
    });
  }

  void fetchMessagesStream(String groupId) {
    _messagesSubscription = fetchMessages(groupId).listen((messageList) {
      messages = messageList;
      if (messages!.isNotEmpty) {
        for (var message in messages!) {
          if (message.expenseId != null && message.expenseId != "") {
            expenseIds.add(message.expenseId!);
          }
        }
      }
      update(['messages']);
    });
  }

  @override
  void onClose() {
    _amountSubscription?.cancel();
    _messagesSubscription?.cancel();
    _expenseSubscription?.cancel();
    super.onClose();
    scrollController.dispose();
  }

  void onUserSelected(String userName) {
    int atSymbolIndex = messageController.text.lastIndexOf('@');
    String newText =
        '${messageController.text.substring(0, atSymbolIndex)}@$userName ';
    messageController.text = newText;
    messageController.selection =
        TextSelection.collapsed(offset: newText.length);
    userSuggestions.clear();
    isSuggestionMode.value = false;
    update();
  }

  void suggestUsers(String text, GroupDataModel groupData) {
    int atIndex = text.lastIndexOf('@');
    if (atIndex != -1) {
      // Get the substring after the last '@'
      String query = text.substring(atIndex + 1);

      userSuggestions.value = groupData.memberIds
              ?.where((member) =>
                  member.user.mobileNo !=
                      loggedInUser!.mobileNo && // Exclude current user
                  (query.isEmpty ||
                      member.user.name!.toLowerCase().contains(
                          query.toLowerCase()))) // Filter based on query
              .map((member) => member.user.name)
              .toList() ??
          [];

      isSuggestionMode.value = userSuggestions.isNotEmpty;
    } else {
      userSuggestions.clear();
      isSuggestionMode.value = false;
    }
    // update();
  }

  void closeSearchExpense() {
    hasSearchEnabled.value = false;
    searchController.clear();
    filteredContacts.clear();
    filteredContacts.addAll(appContactServices.appContacts);
    update(["search", "toolbar"]);
  }

  void closeGroupSearchExpense() {
    hasGroupSearchEnabled.value = false;

    searchGroupController.clear();
    filteredGroups.assignAll(allGroups);
    update(['search', 'groupToolbar']);
  }

  void toggleSearch() {
    hasSearchEnabled.value = !hasSearchEnabled.value;
    if (!hasSearchEnabled.value) {
      searchController.clear();
      onSearchChanged('');
    }
    update();
  }

  void toggleGroupSearch() {
    hasGroupSearchEnabled.value = !hasGroupSearchEnabled.value;
    if (!hasGroupSearchEnabled.value) {
      searchGroupController.clear();
      onSearchChanged('');
    }
    update(["search", "groupToolbar"]);
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredContacts.clear();
      filteredContacts.addAll(appContactServices.appContacts);
    } else {
      filteredContacts.clear();
      filteredContacts.value = searchContacts(searchController.text);
    }
    update();
  }

  List<ContactModel> searchContacts(String query) {
    if (hasSearchEnabled.value == false) {
      hasSearchEnabled.value = true;
    }

    if (query.isEmpty) {
      return appContactServices.appContacts;
    }

    String searchQuery = query.toLowerCase().trim();
    return appContactServices.appContacts.where((contact) {
      return (contact.contactName?.toLowerCase().contains(searchQuery) ??
              false) ||
          (contact.contactNumber?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  loadGroups() async {
    fetchActiveGroupsForUser(loggedInUser!.mobileNo!).listen((groupList) {
      allGroups.assignAll(groupList);
      filteredGroups.assignAll(allGroups);
    });
  }

  void onSearchQueryChanged(String query) {
    if (query.isEmpty) {
      filteredGroups.assignAll(allGroups);
    } else {
      filteredGroups.value = allGroups.where((group) {
        return group.name!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update(['search', 'groupToolbar']);
  }

  Future<void> fetchUserData() async {
    UserModel? user = await userController.getLoggedInUserData();
    if (user != null) {
      loggedInUser = user;
      update();
    }
  }

  bool checkUserStatus(GroupDataModel group, String userMobileNo) {
    for (GroupMember member in group.memberIds!) {
      if (member.user.mobileNo == userMobileNo) {
        return member.status == 'active';
      }
    }
    return false;
  }

  void removeSelectGroup() {
    selectedGroup.value = null;
    update();
  }

  bool isGroupSelected(String groupId) {
    return selectedGroup.value?.id == groupId;
  }

  void refreshContacts() async {
    isLoadContact.value = true;
    try {
      await appStorage.clearUserContacts();
      loadContacts();
      isLoadContact.value = false;
    } catch (e) {
      print("Error while fetching contacts: $e");
    } finally {
      isLoadContact.value = false;
    }
    update(['search']);
  }

  Future<void> loadContacts() async {
    // AppContactServices appContactServices = Get.find<AppContactServices>();
    isLoadContact.value = true;
    await appContactServices.fetchAndStoreContacts(isFromSearch: true);
    filteredContacts.clear();
    if (appContactServices.appContacts.isNotEmpty) {
      filteredContacts.addAll(appContactServices.appContacts);
    }
    isLoadContact.value = false;
    update();
  }

  void contactSelection(
      ContactModel contact, List<ContactModel> groupContacts) {
    if (contact.contactNumber != null && contact.contactNumber!.isNotEmpty) {
      if (!contact.contactNumber!.contains("+")) {
        int? userCountryCode = loggedInUser!.countryCode;
        String normalizedContactNumber =
            "$userCountryCode${contact.contactNumber}";
        normalizedContactNumber =
            normalizedContactNumber.replaceAll(RegExp(r'[^\d]'), '');
        contact = contact.copyWith(contactNumber: normalizedContactNumber);
      }

      // Check if the contact is in the groupContacts list
      bool isInGroupContacts = groupContacts.isNotEmpty &&
          groupContacts.any((groupContact) =>
              groupContact.contactNumber == contact.contactNumber);

      // Add or remove from selectedContacts if the contact is not in groupContacts
      if (!isInGroupContacts) {
        if (selectedContacts.contains(contact)) {
          selectedContacts.remove(contact);
        } else {
          selectedContacts.add(contact);
        }
      }
    } else {
      addRemoveContactInList(contact);
    }

    update();
  }

  void addRemoveContactInList(ContactModel contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  void removeFromSelectedList(ContactModel contact) {
    selectedContacts.remove(contact);
    update();
  }

  bool validateData(BuildContext context) {
    if (groupNameController.text.trim().isEmpty) {
      showInSnackBar(context, "Please enter group name",
          title: 'Required!', isSuccess: false);
      return false;
    } else if (groupBudgetController.text.trim().isEmpty) {
      showInSnackBar(context, "Please enter group estimated budget",
          title: 'Required!', isSuccess: false);
      return false;
    }
    return true;
  }

  Future<void> createGroup(GroupDataModel group) async {
    await groupRef.doc(group.id).set(group.toMap()).then((value) async {
      ChatRoomModel chatRoom = ChatRoomModel(
          groupId: group.id,
          chatRoomTitle: group.name,
          memberIds: group.memberIds,
          isGroup: true,
          lastMessage: "");
      await createChatRoom(chatRoom);
    });
  }

  ContactModel convertGroupMemberToContactModel(GroupMember member) {
    return ContactModel(
      contactId: member.user.id,
      contactName: member.user.name,
      contactNumber: "+${member.user.mobileNo}",
    );
  }

  Future<String?> fetchUserMobileNumber(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await userRef.doc(userId).get();

      if (userSnapshot.exists) {
        final countryCode = userSnapshot['countryCode'] as int?;
        final mobileNo = userSnapshot['mobileNo'] as String?;
        return mobileNo;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user mobile number: $e');
      return null;
    }
  }

  Stream<List<String>> fetchGroupIds() {
    try {
      if (loggedInUser == null || loggedInUser!.mobileNo == null) {
        print('Logged in user or mobile number is null');
        return Stream.value([]);
      }

      String? userMobileNo = loggedInUser!.mobileNo;
      int? userCountryCode = loggedInUser!.countryCode;

      return groupRef.snapshots().map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) {
              // Retrieve the group document data
              Map<String, dynamic> groupData =
                  doc.data() as Map<String, dynamic>;

              // Convert the members list to a list of GroupMember
              List<GroupMember> memberIds = (groupData['memberIds']
                      as List<dynamic>)
                  .map((e) => GroupMember.fromMap(e as Map<String, dynamic>))
                  .toList();

              // Check if the user is a member of the group
              bool isUserMember = memberIds.any((groupMember) =>
                  groupMember.user.mobileNo == userMobileNo
                  // || groupMember.user.mobileNo ==
                  //         '$userCountryCode$userMobileNo'
                  &&
                  groupMember.status == 'active');

              return isUserMember ? doc.id : null;
            })
            .where((id) => id != null)
            .cast<String>()
            .toList();
      });
    } catch (e) {
      print('Error fetching group IDs: $e');
      return Stream.value([]);
    }
  }

  Future<List<GroupDataModel>> fetchActiveGroupsForUserFuture(
      String userMobileNumber) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('groups').get();

    return querySnapshot.docs
        .map(
            (doc) => GroupDataModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((group) {
      var isActiveMember = group.memberIds?.any((member) =>
              member.user.mobileNo == userMobileNumber &&
              member.status == 'active') ??
          false;
      return isActiveMember;
    }).toList();
  }

  Stream<List<GroupDataModel>> fetchActiveGroupsForUser(
      String userMobileNumber) {
    return FirebaseFirestore.instance
        .collection('groups')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          GroupDataModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((group) {
        var isActiveMember = group.memberIds?.any((member) =>
        member.user.mobileNo == userMobileNumber &&
            member.status == 'active') ??
            false;

        return isActiveMember;
      }).toList();
    });
  }

  Stream<List<GroupDataModel>> fetchGroups() {
    try {
      if (loggedInUser == null || loggedInUser!.mobileNo == null) {
        print('Logged in user or mobile number is null');
        return Stream.value([]);
      }

      String? userMobileNo = loggedInUser!.mobileNo;
      int? userContryCode = loggedInUser!.countryCode;

      // Modified query with orderBy
      return groupRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          GroupDataModel group =
              GroupDataModel.fromMap(doc.data() as Map<String, dynamic>);
          return group;
        }).where((group) {
          Set<String?> existingMemberIds =
              group.memberIds?.map((m) => m.user.mobileNo).toSet() ?? {};
          for (String existingMemberId in existingMemberIds.nonNulls.toList()) {
            userController.fetchAppUser(existingMemberId);
          }

          // Check if the user is part of the group's members
          return group.memberIds!.any((groupMember) =>
              groupMember.user.mobileNo == userMobileNo ||
              groupMember.user.mobileNo == '$userContryCode$userMobileNo');
        }).toList();
      });
    } catch (e) {
      print('Error fetching groups: $e');
      return Stream.value([]);
    }
  }

  fetchExpenseStream(List<String> expenseId, String groupId) {
    try {
      _expenseSubscription =
          fetchExpensesListStream(expenseIds, groupId).listen((expenseList) {
        expenses.value = expenseList;
      });
      update(['messages']);
    } catch (e) {
      print("Exception : $e");
    }
  }

  Stream<List<Expense?>> fetchExpensesListStream(
      List<String> expenseIds, String groupId) {
    var listStreamController = StreamController<List<Expense?>>.broadcast();
    List<Expense?> expenses = [];
    List<StreamSubscription<Expense?>> subscriptions = [];

    for (var expenseId in expenseIds) {
      var subscription =
          fetchExpenseStreamData(expenseId, groupId).listen((expense) {
        if (expense != null) {
          // Update or add the expense in the list
          int index =
              expenses.indexWhere((e) => e?.expenseId == expense.expenseId);
          if (index != -1) {
            expenses[index] = expense;
          } else {
            expenses.add(expense);
          }

          // Emit the updated list of expenses
          listStreamController.add(expenses);
        }
      });

      subscriptions.add(subscription);
    }

    // Handle closing of streams
    listStreamController.onCancel = () {
      for (var sub in subscriptions) {
        sub.cancel();
      }
    };

    return listStreamController.stream;
  }

  Stream<List<GroupDataModel>> fetchDashboardGroups() {
    try {
      if (loggedInUser == null || loggedInUser!.mobileNo == null) {
        print('Logged in user or mobile number is null');
        return Stream.value([]);
      }

      String? userMobileNo = loggedInUser!.mobileNo;
      int? userCountryCode = loggedInUser!.countryCode;

      return groupRef.snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          GroupDataModel group =
              GroupDataModel.fromMap(doc.data() as Map<String, dynamic>);
          return group;
        }).where((group) {
          Set<String?> existingMemberIds =
              group.memberIds?.map((m) => m.user.mobileNo).toSet() ?? {};
          for (String existingMemberId in existingMemberIds.nonNulls.toList()) {
            userController.fetchAppUser(existingMemberId);
          }

          // Check if the user is part of the group's members
          return group.memberIds!.any((groupMember) =>
              groupMember.user.mobileNo == userMobileNo ||
              groupMember.user.mobileNo == '$userCountryCode$userMobileNo');
        }) // Only take up to 2 items
            .toList();
      });
    } catch (e) {
      print('Error fetching groups: $e');
      return Stream.value([]);
    }
  }

  List<ContactModel?> getContactNamesByNumbers(List<String> contactNumbers) {
    final contactNames = contactNumbers.map((numberToCheck) {
      final last10Digits = calculateLast10Digits(numberToCheck);

      final contact = appContactServices.appContacts.firstWhere(
        (c) => calculateLast10Digits(c.contactNumber!) == last10Digits,
        orElse: () => ContactModel(contactNumber: numberToCheck),
      );

      return contact;
    }).toList();

    return contactNames;
  }

  String? getContactNameById(String phoneNumber) {
    final last10Digits = calculateLast10Digits(phoneNumber);

    final contact = appContactServices.appContacts.firstWhere(
      (c) => calculateLast10Digits(c.contactNumber!).contains(last10Digits),
      orElse: () =>
          ContactModel(contactId: '', contactName: '', contactNumber: ''),
    );

    return contact.contactName!.isNotEmpty ? contact.contactName : null;
  }

  String calculateLast10Digits(String contactNumber) {
    final normalizedNumber = contactNumber.replaceAll(RegExp(r'[^\d]'), '');

    return normalizedNumber;
  }

  GroupMember convertContactToGroupMember(ContactModel contact) {
    UserModel user = UserModel(
      id: '',
      name: contact.contactName,
      mobileNo: contact.contactNumber,
      createdAt: DateTime.now(),
    );

    return GroupMember(
      user: user,
      status: 'active',
    );
  }

  // Future<void> addMembersToGroup(
  //     String groupId, List<ContactModel> selectedContacts) async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   DocumentReference groupRef = firestore.collection('groups').doc(groupId);
  //
  //   List<GroupMember> newMembers = selectedContacts
  //       .map((contact) => convertContactToGroupMember(contact))
  //       .toList();
  //
  //   try {
  //     DocumentSnapshot groupSnapshot = await groupRef.get();
  //
  //     if (!groupSnapshot.exists) {
  //       throw Exception("Group not found");
  //     }
  //
  //     GroupDataModel group =
  //         GroupDataModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);
  //
  //     // Create a set of existing member IDs for quick lookup
  //     Set<String> existingMemberIds =
  //         group.memberIds?.map((m) => m.user.mobileNo!).toSet() ?? {};
  //
  //     // Filter out new members who are already in the group
  //     List<GroupMember> membersToAdd = newMembers
  //         .where((member) => !existingMemberIds.contains(member.user.mobileNo!))
  //         .toList();
  //
  //     if (membersToAdd.isNotEmpty) {
  //       List<GroupMember> updatedMembers = List.from(group.memberIds ?? [])
  //         ..addAll(membersToAdd);
  //       await groupRef.update(
  //           {'memberIds': updatedMembers.map((m) => m.toMap()).toList()});
  //     }
  //   } catch (error) {
  //     print("Failed to update group members: $error");
  //   }
  // }

  Future<void> addMembersToGroup(
      String groupId, List<ContactModel> selectedContacts) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference groupRef = firestore.collection('groups').doc(groupId);

    List<GroupMember> newMembers = selectedContacts
        .map((contact) => convertContactToGroupMember(contact))
        .toList();

    // Process the mobile numbers to remove the leading '+'
    newMembers = newMembers.map((member) {
      String mobileNo = member.user.mobileNo!;
      if (mobileNo.startsWith('+')) {
        mobileNo = mobileNo.substring(1); // Remove the leading '+'
      }
      return GroupMember(
        user: UserModel(
          // Copy other fields from the member's user object
          id: member.user.id,
          name: member.user.name,
          // ... other fields ...
          mobileNo: mobileNo, // Use the processed mobile number
        ),
        // ... other fields of GroupMember if there are any ...
      );
    }).toList();

    try {
      DocumentSnapshot groupSnapshot = await groupRef.get();

      if (!groupSnapshot.exists) {
        throw Exception("Group not found");
      }

      GroupDataModel group =
          GroupDataModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);

      Set<String> existingMemberIds =
          group.memberIds?.map((m) => m.user.mobileNo!).toSet() ?? {};

      List<GroupMember> membersToAdd = newMembers
          .where((member) => !existingMemberIds.contains(member.user.mobileNo!))
          .toList();

      if (membersToAdd.isNotEmpty) {
        List<GroupMember> updatedMembers = List.from(group.memberIds ?? [])
          ..addAll(membersToAdd);
        await groupRef.update(
            {'memberIds': updatedMembers.map((m) => m.toMap()).toList()});
      }
    } catch (error) {
      print("Failed to update group members: $error");
    }
  }

  Future<void> changeRemoveUserStatus(
      BuildContext context, String groupId, String mobileNo) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference groupRef =
        firestore.collection('groups').doc(groupId);

    try {
      DocumentSnapshot snapshot = await groupRef.get();

      if (!snapshot.exists) {
        throw Exception('Group not found!');
      }

      GroupDataModel group =
          GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);

      for (var member in group.memberIds!) {
        if (member.user.mobileNo == mobileNo) {
          member.status = 'left';
          break;
        }
      }

      await groupRef.update({
        'memberIds': group.memberIds?.map((m) => m.toMap()).toList()
      }).then((value) {
        Get.back();
        Get.back();
        showInSnackBar(context, "User removed from group successfully");
      });
    } catch (e) {
      print("Error changing member status: $e");
      throw e;
    }
  }

  Stream<String?> fetchUserStatusStream(String groupId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference groupRef =
        firestore.collection('groups').doc(groupId);

    return groupRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Group not found!');
      }

      GroupDataModel group =
          GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);

      for (var member in group.memberIds ?? []) {
        if (member.user.mobileNo == loggedInUser!.mobileNo) {
          return member.status; // Return the status of the found user
        }
      }

      return null; // User not found in group
    });
  }

  Future<void> deleteUserFromGroup(
      BuildContext context, String groupId, String mobileNo) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference groupRef =
        firestore.collection('groups').doc(groupId);

    try {
      DocumentSnapshot snapshot = await groupRef.get();

      if (!snapshot.exists) {
        throw Exception('Group not found!');
      }

      GroupDataModel group =
          GroupDataModel.fromMap(snapshot.data() as Map<String, dynamic>);

      // Find the user by mobile number
      GroupMember? userToDelete;
      for (var member in group.memberIds!) {
        if (member.user.mobileNo == mobileNo) {
          member.status = 'deleted';
          userToDelete = member;
          break;
        }
      }

      if (userToDelete != null) {
        // You can choose to remove the user from the group or not
        // group.memberIds?.remove(userToDelete);
      }

      await groupRef.update({
        'memberIds': group.memberIds?.map((m) => m.toMap()).toList()
      }).then((value) {
        Get.back();
        Get.back();
        showInSnackBar(context, "User group deleted successfully");
      });
    } catch (e) {
      print("Error changing member status: $e");
      throw e;
    }
  }

  Future<void> deleteGroupAndRelatedData(
      BuildContext context, String groupId) async {
    await groupRef.doc(groupId).delete();
    await expenseRef.doc(groupId).delete();
    var messagesSnapshot =
        await conversationRef.doc(groupId).collection('messages').get();
    for (var doc in messagesSnapshot.docs) {
      await conversationRef
          .doc(groupId)
          .collection('messages')
          .doc(doc.id)
          .delete();
    }
    await conversationRef.doc(groupId).delete();
    Get.back();
    Get.back();
    Get.back();
    showInSnackBar(context, "Group deleted successfully");
  }

  ///============================================================================================================
  /// GROUP CHAT METHODS
  ///============================================================================================================

  Future<void> createChatRoom(ChatRoomModel chatRoom) async {
    try {
      final chatRoomDocRef = conversationRef.doc(chatRoom.groupId);

      await chatRoomDocRef.set(chatRoom.toMap());
    } catch (e) {
      print('Error creating chat room: $e');
    }
  }

  Future<void> sendMessage(MessageModel message, String groupId) async {
    try {
      final messagesCollection =
          conversationRef.doc(groupId).collection('messages');

      await messagesCollection
          .doc(message.messageId)
          .set(message.toMap())
          .then((value) {
        messageController.clear();
        messageFocusNode.unfocus();
        updateLastMessage(groupId, message);
        groupRef
            .doc(groupId)
            .update({'lastUpdated': FieldValue.serverTimestamp()});
      });
    } catch (e) {
      print('Error sending message: $e');
    }
    if (message.message == "Hello👋") {
      initMessagesSubcollectionExistFuture(groupId);
    }
    update();
    update(['messages']);
  }

  Future<void> updateLastMessage(String groupId, MessageModel message) async {
    try {
      final chatRoomDocRef =
          FirebaseFirestore.instance.collection('conversation').doc(groupId);

      await chatRoomDocRef.update({
        'lastMessage': message.message,
      });
    } catch (e) {
      print('Error updating last message: $e');
    }
  }

  Stream<List<MessageModel>> fetchMessages(String groupId) {
    final messagesCollection =
        conversationRef.doc(groupId).collection('messages');

    return messagesCollection
        .orderBy('createdTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel.fromMap(data);
      }).toList();
    });
  }

  void messageSent() {
    update(); // Notify listeners that a message has been sent
  }

  void initMessagesSubcollectionExistFuture(String groupId) {
    messagesSubcollectionExistFuture = doesMessagesSubcollectionExist(groupId);
    _subscribeToTotalGroupAmount(groupId);
    fetchMessagesStream(groupId);
    fetchExpenseStream(expenseIds, groupId);
  }

  Future<bool> doesMessagesSubcollectionExist(String groupId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('conversation').doc(groupId);
      final messagesCollection = docRef.collection('messages');

      final snapshot = await messagesCollection.get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Expense?> fetchExpenseData(String expenseId, String groupId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot docSnapshot =
          await firestore.collection('expenses').doc(groupId).get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data is Map<String, dynamic>) {
          if (data.containsKey('expenses')) {
            List expensesData = data['expenses'];
            return findExpenseById(expensesData, expenseId);
          }
        }
      }
      return null;
    } catch (e) {
      // Handle errors, e.g., logging or returning a default value
      print("Error fetching expense data: $e");
      return null;
    }
  }

  Stream<Expense?> fetchExpenseStreamData(String expenseId, String groupId) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection('expenses')
        .doc(groupId)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('expenses')) {
        List expensesData = docSnapshot.data()!['expenses'];
        return findExpenseById(expensesData, expenseId);
      }
      return null;
    });
  }

  Expense? findExpenseById(List expensesData, String expenseId) {
    for (var expenseData in expensesData) {
      if (expenseData is Map<String, dynamic> &&
          expenseData['expenseId'] == expenseId) {
        return Expense.fromMap(expenseData);
      }
    }
    return null;
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a dd MMM yy');
    return formatter.format(dateTime);
  }

  Future addExpenseToGroup(
      {required GroupDataModel group, required Expense expense}) async {
    try {
      // mark expense Status as "Paid" (expense.equality) where my id is present
      for (var equality in expense.equality!) {
        if (equality.userId == loggedInUser!.mobileNo) {
          equality.status = 'Paid';
          equality.paymentDoneAt = DateTime.now();
        }
      }

      final groupDocRef = groupRef.doc(group.id);
      final expenseDocRef = expenseRef.doc(group.id);

      await groupDocRef.update({
        'expenses': FieldValue.arrayUnion([expense.toMap()])
      });

      await expenseDocRef.set({
        'expenses': FieldValue.arrayUnion([expense.toMap()])
      });
    } catch (e) {
      print('Error adding expense to group: $e');
    }
  }

  Future<void> captureAndShareList() async {
    // capturedScreenshotBytes = await screenshotController.capture();
    if (capturedScreenshotBytes == null) return;

    toggleOffstageWidgetVisibility(true);

    await Future.delayed(const Duration(seconds: 2));

    RenderObject? boundaryObject =
        offstageKey.currentContext?.findRenderObject();
    if (boundaryObject is RenderRepaintBoundary) {
      ui.Image image = await boundaryObject.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? finalScreenshot = byteData?.buffer.asUint8List();

      if (finalScreenshot != null) {
        await shareImage(finalScreenshot);
        toggleOffstageWidgetVisibility(false);
      }
    } else {
      print('Error: Offstage widget not rendered.');
    }
  }

  Future<bool> settleUpGroup(String groupId) async {
    bool hasUpdatedStatus = false;
    try {
      final groupDocRef = groupRef.doc(groupId);
      DocumentSnapshot groupSnapshot = await groupDocRef.get();

      if (!groupSnapshot.exists) {
        hasUpdatedStatus = false;
        throw Exception('Group not found!');
      }

      GroupDataModel group =
          GroupDataModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);

      for (var member in group.memberIds!) {
        if (member.user.mobileNo == loggedInUser!.mobileNo) {
          member.status = 'settled';
          hasUpdatedStatus = true;
        }
      }

      await groupDocRef.update(
          {'memberIds': group.memberIds?.map((m) => m.toMap()).toList()});
      return hasUpdatedStatus;
    } catch (e) {
      print('Error settling up group: $e');
      return hasUpdatedStatus;
    }
  }

  void toggleOffstageWidgetVisibility(bool isVisible) {
    isOffstageWidgetVisible.value = isVisible;
  }

  // Future<void> shareImage(Uint8List imageBytes) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final imagePath = File('${directory.path}/split.png');
  //   await imagePath.writeAsBytes(imageBytes);
  //   print("Image Path : $imagePath");
  //   await Share.shareFiles([imagePath.path], text: 'Group Split');
  // }

  Future<void> shareImage(Uint8List imageBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = File('${directory.path}/split.png');
      await imagePath.writeAsBytes(imageBytes);

      print("Image Path : ${imagePath.path}");

      if (await imagePath.exists()) {
        await Share.shareFiles([imagePath.path], text: 'Group Split');
      } else {
        print("Image file does not exist");
      }
    } catch (e) {
      print("Error sharing image: $e");
    }
  }

  Future<bool> isUserActiveInAllGroups(String userMobileNumber) async {
    try {
      var groupsSnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      for (var groupDoc in groupsSnapshot.docs) {
        var groupData = GroupDataModel.fromMap(groupDoc.data());

        // Check if the user is in memberIds with a status other than 'active'
        bool isInactiveInMembers = groupData.memberIds?.any((member) =>
                member.user.mobileNo == userMobileNumber &&
                member.status != 'active') ??
            false;

        // Check if the user is in adminIds with a status other than 'active'
        bool isInactiveInAdmins = groupData.adminIds?.any((admin) =>
                admin.user.mobileNo == userMobileNumber &&
                admin.status != 'active') ??
            false;

        // If the user is inactive in either members or admins, return false
        if (isInactiveInMembers || isInactiveInAdmins) {
          return false;
        }
      }

      // User is active in all groups
      return true;
    } catch (e) {
      print('Error checking user status in groups: $e');
      return false;
    }
  }
}

import 'dart:convert';

// import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';

class AppStorage {
  // ignore: prefer_function_declarations_over_variables
  final storageBox = () => GetStorage(StorageKey.kAppStorageKey);

  final InAppReview inAppReview = InAppReview.instance;

  Future<void> appLogout() async {
    await storageBox().remove(StorageKey.kIsBoardWatched);
    await storageBox().remove(StorageKey.kLoggedInUser);
    await storageBox().remove(StorageKey.kNotificationSettings);
    return;
  }

  dynamic read(String key) {
    return storageBox().read(key);
  }

  Future<void> write(String key, dynamic value) async {
    return await storageBox().write(key, value);
  }

  UserModel? getUserData() {
    String? loggedInUser = read(StorageKey.kLoggedInUser);
    if (loggedInUser == null) {
      return null;
    }
    UserModel userModel = UserModel.fromJson(loggedInUser);
    return userModel;
  }

  Future<void> setUserData(UserModel userModel) async {
    try {
      await write(StorageKey.kLoggedInUser, userModel.toJson());
    } catch (e) {
      print('Failed to write user data: $e');
    }
  }

  Future<void> setNotificationSettingData(
      Map<String, dynamic> notificationModel) async {
    await write(StorageKey.kNotificationSettings, notificationModel);
    return;
  }

  Map<String, dynamic>? getNotificationSettingData() {
    var data = read(StorageKey.kNotificationSettings);
    if (data == null) {
      return null;
    }
    return data;
  }

  bool getBool(String key) {
    return read(key) ?? false;
  }

  Future<void> setBool(String key, bool value) async {
    await write(key, value);
    return;
  }

  Future<void> initStorage() async {
    await GetStorage.init(StorageKey.kAppStorageKey);
  }

  bool isBoardWatched() {
    return getBool(StorageKey.kIsBoardWatched);
  }

  bool checkLoginAndUserData() {
    if (FirebaseAuth.instance.currentUser != null && getUserData() == null) {
      FirebaseAuth.instance.signOut();
      return false;
    }
    return FirebaseAuth.instance.currentUser != null &&
        getUserData() != null &&
        getUserData()?.name != null;
  }

  int getExpenseCount() {
    return read(StorageKey.kExpenseCount) ?? 0;
  }

  Future<void> incrementExpenseCount() async {
    int currentCount = getExpenseCount();
    print("Current Count : $currentCount");
    await write(StorageKey.kExpenseCount, currentCount + 1);

    if (currentCount + 1 == 2 && !getBool(StorageKey.kHasShownReview)) {
      // await showReview();
      await setBool(StorageKey.kHasShownReview, true);
    }
  }

  Future<void> setContacts(List<Contact> contacts) async {
    String serializedContacts =
        json.encode(contacts.map((contact) => contact).toList());
    await write(StorageKey.kContacts, serializedContacts);
  }

  Future<void> setUserContacts(List<ContactModel> contacts) async {
    // Convert each contact to a Map using toJson, then to a list
    List<Map<String, dynamic>> contactMaps =
        contacts.map((e) => e.toJson()).toList();

    // Convert the list of maps to a JSON string
    String contactsJson = json.encode(contactMaps);

    // Store the JSON string
    await write(StorageKey.kContacts, contactsJson);
  }

  Future<void> clearUserContacts() async {
    await storageBox().remove(StorageKey.kContacts);
  }

  List<ContactModel> getUserContacts() {
    final contactsJson = read(StorageKey.kContacts);
    if (contactsJson == null) {
      return [];
    }

    if (contactsJson is String) {
      final List<dynamic> parsedContacts = json.decode(contactsJson);
      return parsedContacts
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> setGroupData(GroupDataModel groupData) async {
    String jsonString = groupDataModelToJson(groupData);
    await write(StorageKey.kGroupData, jsonString);
  }

  String groupDataModelToJson(GroupDataModel data) {
    final mapData = data.toMap();
    return json.encode(mapData);
  }

  List<GroupDataModel>? getDashboardGroups() {
    try {
      String? groupsJson = read(StorageKey.kGroupData);
      if (groupsJson != null) {
        List<dynamic> groupList = json.decode(groupsJson);
        return groupList.map((e) => GroupDataModel.fromMap(e)).toList();
      }
      return null;
    } catch (e) {
      print("Get Data Error : $e");
    }
  }

  Future<void> setDashboardGroups(List<GroupDataModel> groups) async {
    try {
      List<Map<String, dynamic>> groupMaps =
          groups.map((e) => e.toMap()).toList();

      // Convert the list of maps to a JSON string
      String groupsJson = json.encode(groupMaps);

      // Store the JSON string
      await write(StorageKey.kGroupData, groupsJson);
    } catch (e) {
      print("Set Data Error : $e");
    }
  }

  Future<bool> showReview() async {
    print("Review Dialogue Show");
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
}

class StorageKey {
  static const String kAppStorageKey = 'AppStorageKey';
  static const String kLoggedInUser = 'LoggedInUser';
  static const String kNotificationSettings = 'notificationSetting';
  static const String kAppLanguage = 'appLanguage';
  static const String kIsBoardWatched = 'isBoardWatched';
  static const String kContacts = 'contacts';
  static const String kGroupData = 'groups';
  static const String kExpenseCount = 'expenseCount';
  static const String kHasShownReview = 'reviewShown';
}

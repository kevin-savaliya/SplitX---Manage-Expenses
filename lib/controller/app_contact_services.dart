// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/utils/app_storage.dart';

class AppContactServices extends GetxController {
  UserModel? loggedInUser;
  final AppStorage appStorage = AppStorage();

  RxList<ContactModel> appContacts = <ContactModel>[].obs;
  AppContactPermissionStatus contactPermissionStatus =
      AppContactPermissionStatus.initial;

  UserController userController = Get.put(UserController());

  @override
  void onInit() {
    super.onInit();
    loggedInUser = appStorage.getUserData();
    fetchAndStoreContacts();
  }

  Future<AppContactPermissionStatus> fetchAndStoreContacts(
      {bool isFromSearch = false}) async {
    try {
      if (contactPermissionStatus == AppContactPermissionStatus.assigned &&
          !isFromSearch) {
        return contactPermissionStatus;
      }
      final PermissionStatus permissionStatus = await getPermission();
      if (permissionStatus == PermissionStatus.granted) {
        Iterable<Contact> deviceContacts = await FlutterContacts.getContacts(
            withThumbnail: true,
            withProperties: true,
            withAccounts: true,
            withPhoto: true);
        // Iterable<Contact> deviceContacts =
        //     await ContactsService.getContacts(withThumbnails: false);
        int? userCountryCode = loggedInUser?.countryCode;

        if (deviceContacts.isNotEmpty) {
          List<ContactModel> newContactModels = deviceContacts
              .where((contact) => contact.phones.isNotEmpty ?? false)
              .mapMany((contact) {
            int? userCountryCode = loggedInUser?.countryCode;
            String? myMobileNo = getMobileNumber(loggedInUser?.mobileNo);

            return contact.phones.map((phone) {
              return ContactModel.fromDeviceContactWithPhone(
                  contact, phone.number.toString(), userCountryCode!);
            }).toList();
          }).toList();

          // Remove own contact
          String? myMobileNo = getMobileNumber(loggedInUser?.mobileNo);
          newContactModels.removeWhere((element) =>
              getMobileNumber(element.contactNumber) == myMobileNo);

          // Remove duplicates based on contact number
          newContactModels = newContactModels.toSet().toList();

          // Fetch stored contacts
          // List<ContactModel> storedContacts = appStorage.getUserContacts();

          // Compare and update if different
          // if (_areContactsDifferent(storedContacts, newContactModels)) {
          //   print("Changes Detected");
          await appStorage.setUserContacts(newContactModels);

          // appContacts.assignAll(newContactModels.whereType<ContactModel>());
          /*if (appContacts.isNotEmpty) {
            appContacts.clear();
          }
          appContacts.addAll(newContactModels);*/
          // }
          if (appContacts.isNotEmpty) {
            appContacts.clear();
          }
          appContacts.addAll(newContactModels);
          userController.storedContacts.addAll(appContacts);

          contactPermissionStatus = AppContactPermissionStatus.assigned;
          print("PStatus : $contactPermissionStatus");
          return contactPermissionStatus;
        } else {
          print("Device contacts are empty.");
          contactPermissionStatus = AppContactPermissionStatus.empty;
          print("PStatus : $contactPermissionStatus");
          return contactPermissionStatus;
        }
      } else {
        print("Contacts permission not granted.");
        contactPermissionStatus = AppContactPermissionStatus.denied;
        if (isFromSearch) {
          Get.snackbar(
            'Permission Denied',
            'Please allow contacts permission to search contacts.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.snackBarTheme.backgroundColor,
            colorText: Get.theme.snackBarTheme.actionTextColor,
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          ).show();
        }
        print("PStatus : $contactPermissionStatus");
        return contactPermissionStatus;
      }
    } catch (e) {
      print("Error fetching contacts: ${e.toString()}");
      contactPermissionStatus = AppContactPermissionStatus.error;
      print("PStatus : $contactPermissionStatus");
      return contactPermissionStatus;
    }
  }

  Future<bool> checkAndReturnUpdatedContacts() async {
    try {
      final PermissionStatus permissionStatus = await getPermission();
      if (permissionStatus == PermissionStatus.granted) {
        Iterable<Contact> deviceContacts = await FlutterContacts.getContacts(
            withThumbnail: true,
            withProperties: true,
            withAccounts: true,
            withPhoto: true);
        // Iterable<Contact> deviceContacts = await ContactsService.getContacts(
        //   withThumbnails: false,
        // );
        int? userCountryCode = loggedInUser?.countryCode;

        if (deviceContacts.isNotEmpty) {
          print("Device Contact : ${deviceContacts}");
          List<ContactModel> newContactModels = deviceContacts
              .where((contact) => contact.phones.isNotEmpty ?? false)
              .map((contact) =>
                  ContactModel.fromDeviceContact(contact, userCountryCode!))
              .toList();

          String? myMobileNo = getMobileNumber(loggedInUser?.mobileNo);
          newContactModels.removeWhere((element) =>
              getMobileNumber(element.contactNumber) == myMobileNo);

          // remove where duplicate any mobile number from contacts
          newContactModels.removeWhere((element) =>
              newContactModels
                  .where((e) =>
                      getMobileNumber(e.contactNumber) ==
                      getMobileNumber(element.contactNumber))
                  .length >
              1);

          // Fetch stored contacts
          List<ContactModel> storedContacts = appStorage.getUserContacts();

          // Compare and update if different
          if (_areContactsDifferent(storedContacts, newContactModels)) {
            print("Changes Detected");
            await appStorage.setUserContacts(newContactModels);

            if (appContacts.isNotEmpty) {
              appContacts.clear();
            }
            appContacts.addAll(newContactModels);
            update();
            return true;
          }
          return false;
        } else {
          print("Device contacts are empty.");
          return false;
        }
      } else {
        print("Contacts permission not granted.");
        return false;
      }
    } catch (e) {
      print("Error fetching contacts: ${e.toString()}");
      return false;
    }
  }

  String? getMobileNumber(String? myMobileNo) {
    myMobileNo = myMobileNo?.replaceAll(RegExp(r'[^\w\s]+'), '');
    if (myMobileNo != null && myMobileNo.length >= 10) {
      myMobileNo = myMobileNo.substring(myMobileNo.length - 10);
      myMobileNo = "${loggedInUser?.countryCode ?? 91}$myMobileNo";
    }
    return myMobileNo;
  }

  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.contacts.request();
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  bool _areContactsDifferent(
      List<ContactModel> storedContacts, List<ContactModel> newContacts) {
    if (storedContacts.length != newContacts.length) {
      // If the lengths are different, the lists are definitely different
      return true;
    }

    // Sort the lists to ensure order does not affect the comparison
    storedContacts
        .sort((a, b) => (a.contactName ?? '').compareTo((a.contactName ?? '')));
    newContacts
        .sort((a, b) => (a.contactName ?? '').compareTo((a.contactName ?? '')));

    // Iterate through the lists and compare each contact
    for (int i = 0; i < storedContacts.length; i++) {
      if (!_areSingleContactsEqual(storedContacts[i], newContacts[i])) {
        return true;
      }
    }

    // If no differences were found, the lists are the same
    return false;
  }

  bool _areSingleContactsEqual(ContactModel contact1, ContactModel contact2) {
    // Implement your logic to compare individual contacts here
    // For example, you might compare the ID, name, and other attributes
    return contact1.contactName == contact2.contactName &&
        contact1.contactNumber == contact2.contactNumber;
  }
}

import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';

// import 'package:contacts_service/contacts_service.dart';

class ContactModel {
  String? contactId;
  String? contactName;
  String? contactNumber;
  String? contactEmail;
  String? contactHobbies;
  String? contactBirthdate;
  String? contactImagePath;
  String? relationShip;

  ContactModel(
      {this.contactId,
      this.contactName,
      this.contactNumber,
      this.contactEmail,
      this.contactHobbies,
      this.contactBirthdate,
      this.relationShip,
      this.contactImagePath});

  ContactModel.fromJson(Map<String, dynamic> json) {
    contactId = json['contact_id'] ?? "";
    contactName = json['contact_name'];
    contactNumber = json['contact_number'];
    contactEmail = json['contact_email'];
    relationShip = json['relationShip'];
    contactHobbies = json['contact_hobbies'];
    contactBirthdate = json['contact_birthdate'];
    contactImagePath = json['contact_imagePath'];
  }

  factory ContactModel.fromDeviceContact(Contact contact, int countryCode) {
    String? contactNumber =
        contact.phones.isNotEmpty == true ? contact.phones.first.number : null;
    // Check if contactNumber count is greater than 10, then remove the country code
    if (contactNumber!.startsWith('+')) {
      String no = contactNumber.replaceFirst(countryCode.toString(), '');
      contactNumber = '+$countryCode$no';
    } else {
      contactNumber = '+$countryCode$contactNumber';
    }

    contactNumber = contactNumber.replaceAll(RegExp(r'[^\d]'), '');
    return ContactModel(
        contactId: contact.id,
        contactName: contact.displayName,
        contactNumber: '+$contactNumber',
        // contactEmail:
        //     contact.emails!.isNotEmpty ? contact.emails!.first.value : null,
        // contactBirthdate: contact.birthday!.toIso8601String(),
        contactImagePath:
            contact.photo != null ? base64Encode(contact.photo!) : null);
  }

  factory ContactModel.fromDeviceContactWithPhone(
      Contact contact, String phone, int countryCode) {
    String? contactNumber = phone;

    if (contactNumber.startsWith('+')) {
      String no = contactNumber.replaceFirst(countryCode.toString(), '');
      contactNumber = '+$countryCode$no';
    } else {
      contactNumber = '+$countryCode$contactNumber';
    }

    // Adjust or format the contact number based on your requirements
    contactNumber = contactNumber.replaceAll(RegExp(r'[^\d]'), '');

    return ContactModel(
      contactId: contact.id,
      contactName: contact.displayName,
      contactNumber: '+$contactNumber',
      contactEmail: contact.emails.isNotEmpty == true
          ? contact.emails.first.toString()
          : null,
      contactImagePath:
          contact.photo != null ? base64Encode(contact.photo!) : null,
          // contact.avatar != null ? base64Encode(contact.avatar!) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contact_id'] = contactId;
    data['contact_name'] = contactName;
    data['contact_number'] = contactNumber;
    data['contact_email'] = contactEmail;
    data['contact_hobbies'] = contactHobbies;
    data['contact_birthdate'] = contactBirthdate;
    data['relationShip'] = relationShip;
    data['contact_imagePath'] = contactImagePath;
    return data;
  }

  ContactModel copyWith({
    String? contactId,
    String? contactName,
    String? contactNumber,
    String? contactEmail,
    String? contactHobbies,
    String? contactBirthdate,
    String? contactImagePath,
    String? relationShip,
  }) {
    return ContactModel(
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      contactNumber: contactNumber ?? this.contactNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      contactHobbies: contactHobbies ?? this.contactHobbies,
      contactBirthdate: contactBirthdate ?? this.contactBirthdate,
      contactImagePath: contactImagePath ?? this.contactImagePath,
      relationShip: relationShip ?? this.relationShip,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel &&
          runtimeType == other.runtimeType &&
          contactId == other.contactId &&
          contactNumber == other.contactNumber;

  @override
  int get hashCode => contactId.hashCode ^ contactNumber.hashCode;
}

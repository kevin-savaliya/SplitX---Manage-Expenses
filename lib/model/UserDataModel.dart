import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataModel {
  String? id;
  String? name;
  String? gender;
  int? countryCode;
  String? currencyCode;
  String? mobileNo;
  String? email;
  String? profilePicture;
  String? avatarId;
  String? createdAt;
  String? fcmToken;
  bool? enablePushNotification;

  UserDataModel(
      { this.id,
        this.name,
        this.gender,
        this.countryCode,
        this.currencyCode,
        this.mobileNo,
        this.email,
        this.profilePicture,
        this.avatarId,
        this.createdAt,
        this.fcmToken,
        this.enablePushNotification});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gender = json['gender'];
    countryCode = json['countryCode'];
    currencyCode = json['currencyCode'];
    mobileNo = json['mobileNo'];
    email = json['email'];
    profilePicture = json['profilePicture'];
    avatarId = json['avatarId'];
    createdAt = json['createdAt'];
    fcmToken = json['fcmToken'];
    enablePushNotification = json['enablePushNotification'];
  }


  @override
  String toString() {
    return 'UserDataModel{id: $id, name: $name, gender: $gender, countryCode: $countryCode, currencyCode: $currencyCode, mobileNo: $mobileNo, email: $email, profilePicture: $profilePicture, avatarId: $avatarId, createdAt: $createdAt, fcmToken: $fcmToken, enablePushNotification: $enablePushNotification}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['countryCode'] = this.countryCode;
    data['currencyCode'] = this.currencyCode;
    data['mobileNo'] = this.mobileNo;
    data['email'] = this.email;
    data['profilePicture'] = this.profilePicture;
    data['avatarId'] = this.avatarId;
    data['createdAt'] = this.createdAt;
    data['fcmToken'] = this.fcmToken;
    data['enablePushNotification'] = this.enablePushNotification;
    return data;
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? gender;
  final int? countryCode;
  final String? currencyCode;
  final String? mobileNo;
  final String? email;
  final String? profilePicture;
  final String? avatarId;
  final DateTime? createdAt;
  final String? fcmToken;
  final bool? enablePushNotification;

  UserModel({
    this.id,
    this.name,
    this.gender,
    this.mobileNo,
    this.email,
    this.countryCode,
    this.currencyCode,
    this.profilePicture,
    this.avatarId,
    this.createdAt,
    this.fcmToken,
    this.enablePushNotification,
  });

  UserModel.newUser({
    this.mobileNo,
    this.id,
    this.name,
    this.gender,
    this.countryCode,
    this.currencyCode,
    this.email,
    this.profilePicture,
    this.avatarId,
    this.createdAt,
    this.fcmToken,
    this.enablePushNotification,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    int? countryCode,
    String? currencyCode,
    String? mobileNo,
    String? email,
    String? profilePicture,
    String? avatarId,
    DateTime? createdAt,
    String? fcmToken,
    bool? enablePushNotification,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      profilePicture: profilePicture ?? this.profilePicture,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      enablePushNotification:
      enablePushNotification ?? this.enablePushNotification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'id': id,
      'mobileNo': mobileNo,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'avatarId': avatarId,
      'gender': gender,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'fcmToken': fcmToken,
      'enablePushNotification': enablePushNotification,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      countryCode: map['countryCode'],
      currencyCode: map['currencyCode'],
      mobileNo: map['mobileNo'],
      email: map['email'],
      profilePicture: map['profilePicture'],
      avatarId: map['avatarId'],
      createdAt: _parseCreatedAt(map['createdAt']),
      fcmToken: map['fcmToken'],
      enablePushNotification: map['enablePushNotification'],
    );
  }

  static DateTime? _parseCreatedAt(dynamic createdAt) {
    if (createdAt is String) {
      return DateTime.tryParse(createdAt)?.toLocal();
    } else if (createdAt is Timestamp) {
      return createdAt.toDate();
    }
    return null;
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mobileNo == other.mobileNo;

  @override
  int get hashCode => id.hashCode ^ mobileNo.hashCode;

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      countryCode: map['countryCode'],
      currencyCode: map['currencyCode'],
      mobileNo: map['mobileNo'],
      email: map['email'],
      profilePicture: map['profilePicture'],
      avatarId: map['avatarId'],
      createdAt: map['createdAt'].toDate(),
      fcmToken: map['fcmToken'],
      enablePushNotification: map['enablePushNotification'],
    );
  }



  String firstChar() {
    return (getName()[0]).toUpperCase();
  }

  String getName() {
    return name ?? mobileNo ?? email ?? 'Unknown';
  }
}

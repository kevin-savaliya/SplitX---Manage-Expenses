import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split/model/usermodel.dart';

class NotificationData {
  String? notificationId;
  String? title;
  String? payerId;
  String? createdAt;
  String? groupId;
  String? tripId;
  String? type;
  String? description;
  String? senderId;
  List<dynamic>? customerId;

  NotificationData({
    this.notificationId,
    this.title,
    this.payerId,
    this.createdAt,
    this.groupId,
    this.type,
    this.tripId,
    this.description,
    this.customerId,
    this.senderId,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    notificationId = json['notificationId'];
    title = json['title'];
    payerId = json['payerId'];
    createdAt = json['createdAt'];
    groupId = json['groupId'];
    tripId = json['tripId'];
    type = json['type'];
    createdAt = json['createdAt'];
    description = json['description'];
    senderId = json['senderId'];
    customerId = json['customerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notificationId'] = notificationId;
    data['title'] = title;
    data['payerId'] = payerId;
    data['createdAt'] = createdAt;
    data['groupId'] = groupId;
    data['tripId'] = tripId;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['description'] = description;
    data['senderId'] = senderId;
    data['customerId'] = customerId;

    return data;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? sender;
  String? message;
  String? image;
  bool? isSeen;
  DateTime? createdTime;
  String? expenseId;
  String? msgType;

  MessageModel({
    this.messageId,
    this.sender,
    this.message,
    this.image,
    this.isSeen,
    this.createdTime,
    this.expenseId,
    this.msgType,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    sender = map['sender'];
    message = map['message'];
    image = map['image'];
    isSeen = map['isSeen'];
    final timestamp = map['createdTime'] as Timestamp?;
    createdTime = timestamp?.toDate();
    expenseId = map['expenseId'];
    msgType = map['msgType'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['sender'] = sender;
    data['message'] = message;
    data['image'] = image;
    data['isSeen'] = isSeen;
    data['createdTime'] = createdTime;
    data['expenseId'] = expenseId;
    data['msgType'] = msgType;
    return data;
  }
}

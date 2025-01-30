import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/usermodel.dart';

class Expense {
  String? expenseId;
  String? title;
  double? amount;
  GroupMember? payerId;
  GroupMember? behalfAddUser;
  DateTime? createdAt;
  DateTime? splitExpenseAt;
  String? groupId;
  String? tripId;
  String? splitMode;
  double? percentage;
  String? expenseType;
  List<Equality>? equality;
  GroupDataModel? groupDataModel;

  Expense(
      {this.expenseId,
      this.title,
      this.amount,
      this.payerId,
      this.behalfAddUser,
      this.createdAt,
      this.splitExpenseAt,
      this.groupId,
      this.tripId,
      this.splitMode,
      this.percentage,
        this.expenseType,
      this.equality,
      this.groupDataModel});

  // factory Expense.fromMap(Map<String, dynamic> doc) {
  //   return Expense(
  //     expenseId: doc['expenseId'],
  //     title: doc['title'],
  //     // amount: doc['amount'],
  //     amount: doc['amount'] is int
  //         ? (doc['amount'] as int).toDouble()
  //         : doc['amount'],
  //     payerId:
  //         doc['payerId'] != null ? UserModel.fromMap(doc['payerId']) : null,
  //     createdAt: DateTime.parse(doc['createdAt']),
  //     groupId: doc['groupId'],
  //     tripId: doc['tripId'],
  //     splitMode: doc['splitMode'],
  //     // percentage: doc['percentage'],
  //     percentage: doc['percentage'] is int
  //         ? (doc['percentage'] as int).toDouble()
  //         : doc['percentage'],
  //     equality: List<Equality>.from(
  //         doc['equality'].map((item) => Equality.fromMap(item))),
  //     groupDataModel: doc['groupDataModel'],
  //   );
  // }

  factory Expense.fromMap(Map<String, dynamic> doc) {
    return Expense(
      expenseId: doc['expenseId'],
      title: doc['title'],
      amount: doc['amount'] is int
          ? (doc['amount'] as int).toDouble()
          : doc['amount'],
      payerId: _parseGroupMember(doc['payerId']),
      behalfAddUser: _parseGroupMember(doc['behalfAddUser']),
      createdAt: DateTime.parse(doc['createdAt']),
      splitExpenseAt: DateTime.parse(doc['splitExpenseAt']),
      groupId: doc['groupId'],
      tripId: doc['tripId'],
      splitMode: doc['splitMode'],
      percentage: doc['percentage'] is int
          ? (doc['percentage'] as int).toDouble()
          : doc['percentage'],
      expenseType: doc['expenseType'],
      equality: doc['equality'] != null
          ? List<Equality>.from(
              doc['equality'].map((item) => Equality.fromMap(item)))
          : [],
      groupDataModel: doc['groupDataModel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'title': title,
      'amount': amount,
      'payerId': payerId?.toMap(),
      'behalfAddUser': behalfAddUser?.toMap(),
      'createdAt': createdAt!.toIso8601String(),
      'splitExpenseAt': splitExpenseAt!.toIso8601String(),
      'groupId': groupId,
      'tripId': tripId,
      'splitMode': splitMode,
      'percentage': percentage,
      'expenseType': expenseType,
      'equality': equality!.map((e) => e.toMap()).toList(),
      // 'groupDataModel': groupDataModel!.toMap()
    };
  }

  static GroupMember? _parseGroupMember(dynamic data) {
    if (data != null && data is Map<String, dynamic>) {
      return GroupMember.fromMap(data);
    }
    return null;
  }
}

class Equality {
  String userId;
  String? userName;
  DateTime? paymentDoneAt;
  String? status;
  double percentage;
  double amount;

  Equality({
    required this.userId,
    this.userName,
    required this.status,
    this.paymentDoneAt,
    required this.percentage,
    required this.amount,
  });

  factory Equality.fromMap(Map<String, dynamic> map) {
    return Equality(
      userId: map['userId'],
      userName: map['userName'],
      paymentDoneAt: map['paymentDoneAt'] != null
          ? DateTime.parse(map['paymentDoneAt'])
          : null,
      status: map['status'],
      percentage: map['percentage'] is int
          ? (map['percentage'] as int).toDouble()
          : map['percentage'],
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'paymentDoneAt': paymentDoneAt?.toIso8601String(),
      'status': status,
      'percentage': percentage,
      'amount': amount,
    }..removeWhere((key, value) => value == null);
  }
}

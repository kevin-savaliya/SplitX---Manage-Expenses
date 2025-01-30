import 'package:split/model/usermodel.dart';

class GroupMember {
  UserModel user;
  String status; // 'active', 'left', etc.
  double debitAmount = 0;
  double creditAmount = 0;

  GroupMember({required this.user, this.status = 'active'});

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'status': status,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    UserModel? user;
    if (map['user'] != null && map['user'] is Map<String, dynamic>) {
      user = UserModel.fromMap(map['user']);
    }
    return GroupMember(
      user: user ?? UserModel(), // Provide a default UserModel if needed
      status: map['status'] ?? 'active',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMember &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          status == other.status;

  // Override the hashCode method to ensure consistent hashing based on user and status
  @override
  int get hashCode => user.hashCode ^ status.hashCode;

  String firstChar() {
    return (user.getName()[0] ?? '-').toUpperCase();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/usermodel.dart';

class GroupDataModel {
  String? id;
  final String? name;
  final String? description;
  final String? budget;
  final String? groupProfile;
  final List<GroupMember>? memberIds;
  final List<GroupMember>? adminIds;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  GroupDataModel({
    this.id,
    this.name,
    this.description,
    this.budget,
    this.groupProfile,
    this.memberIds,
    this.adminIds,
    this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'budget': budget,
      'groupProfile': groupProfile,
      'memberIds': memberIds?.map((user) => user.toMap()).toList(),
      'adminIds': adminIds?.map((user) => user.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  GroupDataModel copyWith({
    String? id,
    String? name,
    String? description,
    String? budget,
    String? groupProfile,
    List<GroupMember>? memberIds,
    List<GroupMember>? adminIds,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return GroupDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      groupProfile: groupProfile ?? this.groupProfile,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory GroupDataModel.fromMap(Map<String, dynamic> map) {
    return GroupDataModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      budget: map['budget'] ?? '',
      groupProfile: map['groupProfile'] ?? '',
      memberIds: map['memberIds'] != null
          ? (map['memberIds'] as List)
              .map(
                  (dynamic e) => GroupMember.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      adminIds: map['adminIds'] != null
          ? (map['adminIds'] as List)
              .map(
                  (dynamic e) => GroupMember.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: _parseDateTime(map['createdAt']),
      lastUpdated: _parseDateTime(map['lastUpdated']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value);  // Parse from ISO 8601 string
    }

    throw ArgumentError('Cannot parse DateTime from $value');
  }
@override
  String toString() {
    // TODO: implement toString
    return name.toString();
  }
}

import 'package:split/model/group_members.dart';
import 'package:split/model/usermodel.dart';

class ChatRoomModel {
  String? groupId;
  String? chatRoomTitle;
  List<GroupMember>? memberIds;
  bool? isGroup;
  String? lastMessage;

  ChatRoomModel({
    this.groupId,
    this.chatRoomTitle,
    this.memberIds,
    this.isGroup,
    this.lastMessage,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    groupId = map['groupId'];
    chatRoomTitle = map['chatRoomTitle'];
    memberIds = map['memberIds'] != null
        ? (map['memberIds'] as List)
            .map((dynamic e) => GroupMember.fromMap(e as Map<String, dynamic>))
            .toList()
        : [];
    isGroup = map['isGroup'];
    lastMessage = map['lastMessage'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupId'] = groupId;
    data['chatRoomTitle'] = chatRoomTitle;
    data['memberIds'] = memberIds?.map((user) => user.toMap()).toList();
    data['isGroup'] = isGroup;
    data['lastMessage'] = lastMessage;
    return data;
  }
}

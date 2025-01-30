import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/usermodel.dart';

class HorizontalAvtarWidgets extends StatefulWidget {
  final double height;
  final List<UserModel?>? userDataList;
  final List<String?>? userMobileList;

  HorizontalAvtarWidgets({
    Key? key,
    required this.height,
    this.userDataList,
    this.userMobileList,
  }) : super(key: key) {
    // Validate that only one of userDataList or imageUrlList is provided
    if ((userDataList == null && userMobileList == null) ||
        (userDataList != null && userMobileList != null)) {
      throw ArgumentError(
          "Exactly one of 'userDataList' or 'imageUrlList' should be provided.");
    }
  }

  @override
  State<HorizontalAvtarWidgets> createState() => _HorizontalAvtarWidgetsState();
}

class _HorizontalAvtarWidgetsState extends State<HorizontalAvtarWidgets> {
  final UserController userController = Get.find<UserController>();
  List<UserModel> userList = <UserModel>[];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int itemCount = widget.userDataList?.length ?? widget.mobileList?.length ?? 0;
    int itemCount = userList.length;

    return SizedBox(
      width: (18 * itemCount).toDouble() + 10,
      height: widget.height,
      child: Stack(
        children: List.generate(itemCount, (index) {
          return Positioned(
            left: index == 0 ? 0 : (18 * index).toDouble(),
            child: ImageWidget(
              // getItemImageUrl(index),
              userList[index].profilePicture ?? '',
              widget.height,
              widget.height,
              userName: userController
                      .getNameByPhoneNumber(userList[index].mobileNo) ??
                  userList[index].name ??
                  '',
            ),
          );
        }),
      ),
    );
  }

  String getItemImageUrl(int index) {
    if (widget.userDataList != null) {
      if (index < widget.userDataList!.length) {
        return widget.userDataList![index]?.profilePicture ?? '';
      }
    } else if (widget.userMobileList != null) {
      if (index < widget.userMobileList!.length) {
        return widget.userMobileList?[index] ?? '';
      }
    }
    return '';
  }

  Future fetchData() async {
    List<bool> done = [false, false];
    if (widget.userDataList?.isNotEmpty ?? false) {
      for (var i = 0; i < (widget.userDataList?.length ?? 0); i++) {
        if (widget.userDataList?[i]?.mobileNo != null) {
          var result = await userController
              .fetchAppUser(widget.userDataList?[i]?.mobileNo ?? '');
          var value = userController
              .getUserData(widget.userDataList?[i]?.mobileNo ?? '');
          if (value != null) {
            userList.add(value);
            setState(() {});
          }
        }
      }
    }
    if (done[0] && done[1]) {
      return Future.value();
    }
    done[0] = true;

    if (widget.userMobileList?.isNotEmpty ?? false) {
      for (var i = 0; i < (widget.userMobileList?.length ?? 0); i++) {
        if (widget.userMobileList?[i] != null) {
          var result = await userController
              .fetchAppUser(widget.userMobileList?[i] ?? '');
          var value =
              userController.getUserData(widget.userMobileList?[i] ?? '');
          if (value != null) {
            userList.add(value);
            setState(() {});
          }
        }
      }
    }
    if (done[0] && done[1]) {
      return Future.value();
    }
    done[1] = true;
  }
}

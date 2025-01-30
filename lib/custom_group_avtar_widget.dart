import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/assets.dart';

class CustomGroupAvtarWidget extends StatefulWidget {
  final Size size;
  final List<UserModel?>? userDataList;
  final List<String?>? userMobileList;

  CustomGroupAvtarWidget({
    Key? key,
    required this.size,
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
  State<CustomGroupAvtarWidget> createState() => _CustomGroupAvtarWidgetState();
}

class _CustomGroupAvtarWidgetState extends State<CustomGroupAvtarWidget> {
  final UserController userController = Get.find<UserController>();
  List<UserModel> userList = <UserModel>[];

  @override
  void initState() {
    fetchData().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int itemCount = widget.userDataList?.length ?? widget.userMobileList?.length ?? 0;

    return SizedBox(
      height: size.height / 2,
      width: size.width / 2,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: (userList.isNotEmpty)
                ? firstUserData.avatarId == null || firstUserData.avatarId == ""
                    ? ImageWidget(
                        // getItemImageUrl(2),
                        firstUserData.profilePicture ?? '',
                        size.height / 3,
                        size.width / 3,
                        userName: userController
                                .getNameByPhoneNumber(firstUserData.mobileNo) ??
                            firstUserData.name ??
                            '-',
                      )
                    : ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                            height: size.height / 3,
                            width: size.width / 3,
                            color: AppColors.darkPrimaryColor,
                            child: Image.asset(
                                AppImages.avtar(firstUserData.avatarId ?? ''))),
                      )
                : ImageWidget(
                    '',
                    size.height / 3,
                    size.width / 3,
                    userName: '-',
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: (userList.length >= 2)
                ? secondUserData.avatarId == null ||
                        secondUserData.avatarId == ""
                    ? ImageWidget(
                        // getItemImageUrl(1),
                        secondUserData.profilePicture ?? '',
                        size.height / 3,
                        size.width / 3,
                        userName: userController.getNameByPhoneNumber(
                                secondUserData.mobileNo) ??
                            secondUserData.name ??
                            '-',
                      )
                    : ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                            height: size.height / 3,
                            width: size.width / 3,
                            color: AppColors.darkPrimaryColor,
                            child: Image.asset(AppImages.avtar(
                                secondUserData.avatarId ?? ''))),
                      )
                : ImageWidget(
                    '',
                    size.height / 3,
                    size.width / 3,
                    userName: '-',
                  ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: (userList.length >= 3)
                ? thirdUserData.avatarId == null || thirdUserData.avatarId == ""
                    ? ImageWidget(
                        // getItemImageUrl(2),
                        thirdUserData.profilePicture ?? '',
                        size.height / 4,
                        size.width / 4,
                        userName: userController
                                .getNameByPhoneNumber(thirdUserData.mobileNo) ??
                            thirdUserData.name ??
                            '-',
                      )
                    : ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                            height: size.height / 4,
                            width: size.width / 4,
                            color: AppColors.darkPrimaryColor,
                            child: Image.asset(
                                AppImages.avtar(thirdUserData.avatarId ?? ''))),
                      )
                : ImageWidget(
                    '',
                    size.height / 4,
                    size.width / 4,
                    userName: '-',
                  ),
          )
        ],
      ),
    );
  }

  UserModel get thirdUserData => userList[2];

  UserModel get secondUserData => userList[1];

  UserModel get firstUserData => userList[0];

  String getItemImageUrl(int index) {
    if (widget.userDataList != null) {
      if (index < widget.userDataList!.length) {
        String? imageUrl = widget.userDataList![index]?.profilePicture;
        // Check if the imageUrl is empty or null, and provide a default URL if needed
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        } else {
          // Provide a default image URL if the user's profile picture is not available
          return '';
        }
      }
    } else if (widget.userMobileList != null) {
      if (index < widget.userMobileList!.length) {
        String? imageUrl = widget.userMobileList?[index];
        // Check if the imageUrl is empty or null, and provide a default URL if needed
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        } else {
          // Provide a default image URL if the URL is not available
          return '';
        }
      }
    }
    // Provide a default image URL if no valid URL is available
    return '';
  }

  /*Container ImageWidget(String imageUrl, double height, double width,
      {String? userName}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: EdgeInsets.all(width / 15),
      child: ClipOval(
        child: CachedNetworkImage(
          height: height,
          width: width,
          imageUrl: imageUrl,
          errorWidget: (context, url, error) => Container(
            color: randomLightColor(),
            child: userName != null
                ? Center(
                    child: Text(
                      userName[0],
                      style: TextStyle(
                        fontSize: width / 1.5,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person_2,
                    color: Colors.white,
                    size: width / 1.5,
                  ),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SizedBox(
            height: height,
            width: width,
            child: Center(
                child: LoadingIndicator(
              colors: [AppColors.primaryColor],
              indicatorType: Indicator.ballScale,
              strokeWidth: 1,
            )),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }*/

  Size get size => widget.size;

  Future fetchData() async {
    List<bool> done = [false, false];
    if (widget.userDataList?.isNotEmpty ?? false) {
      for (var i = 0; i < (widget.userDataList?.length ?? 0); i++) {
        if (widget.userDataList?[i]?.mobileNo != null) {
          await userController
              .fetchAppUser(widget.userDataList?[i]?.mobileNo ?? '');
          var value = userController
              .getUserData(widget.userDataList?[i]?.mobileNo ?? '');
          if (value != null) {
            userList.add(value);
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
          await userController.fetchAppUser(widget.userMobileList?[i] ?? '');
          var value =
              userController.getUserData(widget.userMobileList?[i] ?? '');
          if (value != null) {
            userList.add(value);
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

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final String? userName;
  final double height;
  final double width;
  final bool shouldShowUserName;
  final UserModel? userData;

  const ImageWidget(
    this.imageUrl,
    this.height,
    this.width, {
    super.key,
    this.userName,
    this.userData,
    this.shouldShowUserName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: EdgeInsets.all(width / 15),
      child: ClipOval(
        child: hasAvtar()
            ? getAvtarImage()
            : CachedNetworkImage(
                height: height,
                width: width,
                imageUrl: getImageUrl() ?? '',
                key: UniqueKey(),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.black,
                  // color: getAvatarColor(userName ?? '?'), // randomLightColor(),
                  child: ((userName != null &&
                              userName!.isNotEmpty &&
                              userName != 'null') ||
                          shouldShowUserName)
                      ? ClipOval(
                          child: Container(
                              height: 40,
                              width: 40,
                              color: AppColors.darkPrimaryColor,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      SvgPicture.asset(AppImages.split_logo))))
                      // ? Center(
                      //     child: Text(
                      //       getUserChar(),
                      //       style: TextStyle(
                      //         fontSize: getUserChar().length == 1
                      //             ? (width / 1.5)
                      //             : (width / 7),
                      //         color: Colors.white,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   )
                      :
                      // Image.asset(_randomImage())
                      Icon(
                          Icons.person_2,
                          color: Colors.white,
                          size: width / 1.5,
                        ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  height: height,
                  width: width,
                  child: Center(
                      child: LoadingIndicator(
                    colors: [AppColors.primaryColor],
                    indicatorType: Indicator.ballScale,
                    strokeWidth: 1,
                  )),
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  String getImageUrl() {
    if (userData?.profilePicture != null &&
        userData!.profilePicture!.isNotEmpty) {
      return userData?.profilePicture ?? '';
    }
    return imageUrl;
  }

  String getUserChar() {
    if (userName != null && userName!.isNotEmpty && userName != 'null') {
      return userName![0];
    }
    return 'SplitX';
  }

  Color getAvatarColor(String username) {
    // Simple hash function to generate an integer from the username
    int hash = 1;
    for (int i = 1; i < username.length; i++) {
      hash = username.codeUnitAt(i) + ((hash << 4) - hash);
    }

    // Generate a color based on the hash
    final random = Random(hash);
    return Color.fromRGBO(
        random.nextInt(256), random.nextInt(1), random.nextInt(256), 1.0);
  }

  Color randomLightColor() {
    List<Color> colorList = [
      const Color(0xffD4FE1B),
      const Color(0xff63BF94),
      const Color(0xffCC9CD9),
      const Color(0xffC901E9),
      const Color(0xffF55555),
      const Color(0xffFCCF31),
      const Color(0xff01BAEF),
      const Color(0xff20BF55),
      const Color(0xff7367F0),
      const Color(0xffCE9FFC),
      const Color(0xFF6CDC06),
      const Color(0xFF6154FE),
      const Color(0xFFF2522E),
      const Color(0xFF5CCD15),
      const Color(0xFF1E7D55),
      const Color(0xFFF2522E)
    ];

    Random random = Random();
    int index = random.nextInt(colorList.length);
    return colorList[index];
  }

  bool hasAvtar() {
    return userData?.avatarId != null && (userData?.avatarId ?? '').isNotEmpty;
  }

  Widget getAvtarImage() {
    return ClipOval(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
          height: 40,
          width: 40,
          color: AppColors.darkPrimaryColor,
          child: Image.asset(AppImages.avtar(userData?.avatarId ?? ''))),
    );
  }
}

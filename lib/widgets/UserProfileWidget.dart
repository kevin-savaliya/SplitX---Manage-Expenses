import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/assets.dart';

class UserProfileWidget extends StatefulWidget {
  final UserModel? userData;
  final String? mobileNo;
  final String? name;
  final Size size;

  const UserProfileWidget({
    super.key,
    this.userData,
    this.mobileNo,
    this.name,
    required this.size,
  });

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  final UserController userController = Get.find<UserController>();

  UserModel? userData;

  @override
  void initState() {
    userData = widget.userData;
    if (userData == null) {
      UserModel? userModel = userController.getUserData(widget.mobileNo ?? '');
      if (userModel == null) {
        userData =
            UserModel.newUser(mobileNo: widget.mobileNo, name: widget.name);
      } else {
        userData = userModel;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (userData != null) {
      if (userData?.avatarId != null && userData!.avatarId != "") {
        return Container(
          height: widget.size.height,
          width: widget.size.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Image.asset(
            AppImages.avtar(userData?.avatarId ?? ''),
            height: widget.size.height,
            width: widget.size.width,
            fit: BoxFit.cover,
          ),
        );
      }
      return ImageWidget(
        userData?.profilePicture ?? '',
        widget.size.height,
        widget.size.width,
        userName: userData?.name ?? '-',
        userData: userData,
      );
    }
    return ClipOval(
        child: Container(
            height: widget.size.height,
            width: widget.size.width,
            color: AppColors.darkPrimaryColor,
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(AppImages.split_logo))));
  }
}

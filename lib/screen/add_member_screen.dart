// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/add_contact_screen.dart';
import 'package:split/screen/create_new_group.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/UserProfileWidget.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class AddMemberScreen extends StatefulWidget {
  List<ContactModel>? groupContacts;
  GroupDataModel? groupData;

  AddMemberScreen({super.key, this.groupContacts, this.groupData}) {
    final GroupController controller = Get.find<GroupController>();
    if (groupContacts != null) {
      controller.selectedContacts.value =
          Set<ContactModel>.from(groupContacts!.toList());
      controller.filteredContacts.value.addAll(groupContacts!);
    }
  }

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen>
    with WidgetsBindingObserver {
  final GroupController controller = Get.find<GroupController>();
  List<ContactModel> storedContacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    controller.appContactServices
        .checkAndReturnUpdatedContacts()
        .then((hasUpdate) {
      if (hasUpdate) {
        controller.refreshContacts();
        controller.update(['search']);
      }
    });
  }

  Widget userChip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Chip(
        backgroundColor: AppColors.decsGrey, // Custom color for user's chip
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.decsGrey),
            borderRadius: BorderRadius.circular(30)),
        labelStyle: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: AppColors.white),
        label: Text(
          "You",
          textScaler: const TextScaler.linear(1),
          style:
              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupController>(
      init: GroupController(),
      builder: (controller) {
        return WillPopScope(
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              elevation: 1,
              shadowColor: AppColors.decsGrey.withOpacity(0.5),
              excludeHeaderSemantics: true,
              backgroundColor: AppColors.white,
              centerTitle: false,
              leading: Obx(
                () => !controller.hasSearchEnabled.value
                    ? GestureDetector(
                        onTap: () {
                          Get.back();
                          controller.selectedContacts.clear();
                          controller.closeSearchExpense();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: SvgPicture.asset(
                            AppIcons.back_icon,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 15),
                        child: SizedBox(
                          height: 10,
                          width: 10,
                          child: SvgPicture.asset(
                            AppIcons.searchIcon,
                            height: 10,
                          ),
                        ),
                      ),
              ),
              titleSpacing: -10,
              // automaticallyImplyLeading: !controller.hasSearchEnabled.value,
              title: GetBuilder<GroupController>(
                id: "toolbar",
                init: GroupController(),
                builder: (controller) {
                  return controller.hasSearchEnabled.value
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            height: 50,
                            child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: const TextScaler.linear(1)),
                                child: TextField(
                                  controller: controller.searchController,
                                  autofocus: true,
                                  onChanged: (value) {
                                    controller.onSearchChanged(value);
                                  },
                                  cursorColor: AppColors.txtGrey,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontRegular),
                                  decoration: InputDecoration(
                                    hintText: ConstString.search_members,
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontFamily: AppFont.fontMedium,
                                          fontSize: 15,
                                        ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        controller.closeSearchExpense();
                                      },
                                      child: Icon(
                                        Icons.close_outlined,
                                        color: AppColors.darkPrimaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                )),
                          ),
                        )
                      : Text(
                          ConstString.addGroupMember,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontFamily: AppFont.fontSemiBold,
                                  fontSize: 16),
                        );
                },
              ),
              actions: [
                GetBuilder<GroupController>(
                    id: "toolbar",
                    builder: (controller) {
                      return controller.hasSearchEnabled.value
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                controller.toggleSearch();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SvgPicture.asset(AppIcons.searchIcon),
                              ),
                            );
                    })
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: controller.selectedContacts.isNotEmpty
                ? ElevatedButton(
                    onPressed: () {
                      //controller.selectGroup(widget.groupData!);
                      print('----fcm---->${controller.fcmTokenList.length}');
                      if (widget.groupData != null) {
                        controller
                            .addMembersToGroup(widget.groupData!.id!,
                                controller.selectedContacts.value.toList())
                            .then((value) async {
                          Get.back();
                          Get.back();
                          Get.back();
                          showInSnackBar(
                              context, "Group Member added successfully!",
                              isSuccess: true);

                          controller.selectedContacts.clear();
                          print('-------->add_group_member');


                          // await NotificationService.sendMultipleNotifications(
                          //     customerIdList: controller.customerIdList,
                          //     senderId: '${controller.userDataModel?.id}',
                          //     groupId: widget.groupData!.id!,
                          //     type: 'add_group_member',
                          //     title:
                          //         '${controller.userDataModel?.name} added new member to the group “${widget.groupData?.name}”.',
                          //     body: '',
                          //     tokens: controller.fcmTokenList);

                          controller.fcmTokenList.clear();
                          controller.customerIdList.clear();
                          print('${controller.fcmTokenList.length}');


                          //TODO: Send Notification of Add Member in Group
                     });
                      } else {
                        Get.to(() => CreateNewGroup(
                              selectedContact: controller.selectedContacts,
                            ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        fixedSize: const Size(200, 50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: Text(
                      "Add ${controller.selectedContacts.length} Peoples",
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(
                              color: AppColors.darkPrimaryColor,
                              fontFamily: AppFont.fontMedium),
                    ))
                : const SizedBox(),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: controller.selectedContacts.length > 3 ? 130 : 80,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              alignment: WrapAlignment.start,
                              children: [
                                userChip(context),
                                ...controller.selectedContacts
                                    .map((selectedContact) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Chip(
                                            backgroundColor: AppColors.decsGrey,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: AppColors.decsGrey),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    color: AppColors.white),
                                            deleteIconColor:
                                                AppColors.darkPrimaryColor,
                                            label: Text(
                                              "${selectedContact.contactName}",
                                              textScaler:
                                                  const TextScaler.linear(1),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(fontSize: 13),
                                            ),
                                            onDeleted: () {
                                              controller.removeFromSelectedList(
                                                  selectedContact);
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  controller.selectedContacts.isNotEmpty
                      ? Divider(
                          thickness: 1,
                          color: AppColors.txtGrey.withOpacity(0.2),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ConstString.fromContact,
                          textScaler: const TextScaler.linear(1),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontFamily: AppFont.fontSemiBold,
                                  fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.refreshContacts();
                          },
                          child: Icon(
                            Icons.sync,
                            color: AppColors.darkPrimaryColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListTile(
                      onTap: () {
                        Get.to(() => const AddContactScreen());
                      },
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.phoneGrey.withOpacity(0.5)),
                        height: 44,
                        width: 44,
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: SvgPicture.asset(
                            AppIcons.addContact,
                            color: AppColors.darkPrimaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        ConstString.addPeople,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 15,
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontMedium),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: AppColors.txtGrey.withOpacity(0.2),
                    height: 5,
                  ),
                  Obx(() => contactDataWidget(context)),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          onWillPop: () async {
            Get.back();
            controller.selectedContacts.clear();
            return true;
          },
        );
      },
    );
  }

  Widget contactDataWidget(BuildContext context) {
    return GetBuilder<GroupController>(
      id: 'search',
      init: GroupController(),
      builder: (controller) {
        var displayContacts = controller.filteredContacts;

        if (controller.isLoadContact.value) {
          return const ContactShimmer(itemCount: 10);
        }

        if (controller.appContactServices.contactPermissionStatus ==
            AppContactPermissionStatus.denied) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.black.withOpacity(0.7),
                      size: 40,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        ConstString.noContacts,
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 16,
                                fontFamily: AppFont.fontMedium),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () async {
                            openAppSettings();
                          },
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              backgroundColor: AppColors.primaryColor,
                              fixedSize: const Size(130, 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Text(
                            ConstString.setting,
                            textScaler: const TextScaler.linear(1),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: AppColors.darkPrimaryColor,
                                    fontFamily: AppFont.fontMedium),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (displayContacts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      color: Colors.black.withOpacity(0.7),
                      size: 40,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        ConstString.emptyContacts,
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 16,
                                fontFamily: AppFont.fontMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return displayContacts.isNotEmpty
            ? ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    color: AppColors.txtGrey.withOpacity(0.2),
                    height: 0,
                  );
                },
                itemCount: displayContacts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ContactModel contact = displayContacts[index];
                  // bool isSelected =
                  //     controller.selectedContacts.contains(contact);
                  bool isSelected = controller.selectedContacts.any(
                      (selectedContact) =>
                          selectedContact.contactNumber ==
                          contact.contactNumber);
                  String displayName = contact.contactName ?? "No Name";
                  UserModel? userData = controller.userController.getUserData(
                      contact.contactNumber?.replaceAll(RegExp(r'[^\d]'), ''));
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListTile(
                      onTap: () {
                        controller.contactSelection(
                            contact, widget.groupContacts ?? []);
                      },
                      horizontalTitleGap: 10,
                      contentPadding: EdgeInsets.zero,
                      leading: userData != null
                          ? UserProfileWidget(
                              size: const Size(40, 40),
                              userData: userData,
                            )
                          : CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppColors.phoneGrey.withOpacity(0.5),
                              child: Text(
                                contact.contactName != null
                                    ? String.fromCharCodes(
                                            contact.contactName!.runes.take(1))
                                        .toUpperCase()
                                    : "?",
                                textScaler: const TextScaler.linear(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: AppColors.white,
                                        fontFamily: AppFont.fontSemiBold,
                                        fontSize: 20),
                              ),
                            ),
                      title: Text(
                        displayName,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 14,
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontMedium),
                      ),
                      subtitle: Text(
                        contact.contactNumber != null &&
                                contact.contactNumber!.isNotEmpty
                            ? contact.contactNumber ?? "No phone number"
                            : "No phone number",
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 13,
                            color: AppColors.darkPrimaryColor,
                            fontFamily: AppFont.fontRegular),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          isSelected ? AppIcons.checkFill : AppIcons.emptyCheck,
                          color: AppColors.darkPrimaryColor,
                          height: 18,
                        ),
                      ),
                    ),
                  );
                },
              )
            : const ContactShimmer(itemCount: 10);
      },
    );
  }
}

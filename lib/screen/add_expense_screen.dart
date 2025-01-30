import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/screen/add_expense_form.dart';
import 'package:split/screen/add_member_screen.dart';
import 'package:split/screen/group_details.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/widgets/shimmer_widgets.dart';

class AddExpenseScreen extends StatefulWidget {
  bool? isExpense;

  AddExpenseScreen({super.key, this.isExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final GroupController controller = Get.put(GroupController());
  List<GroupDataModel>? groups;
  bool isLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadGroups();
  }

  loadGroups() async {
    groups = await controller.filteredGroups;
    // groups = await controller
    //     .fetchActiveGroupsForUserFuture(controller.loggedInUser!.mobileNo!);
    isLoad = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 1,
        shadowColor: AppColors.decsGrey.withOpacity(0.5),
        backgroundColor: AppColors.white,
        centerTitle: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SvgPicture.asset(
              AppIcons.back_icon,
            ),
          ),
        ),
        titleSpacing: -10,
        title: GetBuilder<GroupController>(
          id: 'groupToolbar',
          init: GroupController(),
          builder: (controller) {
            return controller.hasGroupSearchEnabled.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      height: 50,
                      child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: const TextScaler.linear(1)),
                          child: TextField(
                            controller: controller.searchGroupController,
                            autofocus: true,
                            onChanged: (value) {
                              controller.onSearchQueryChanged(value);
                              controller.update(['search', 'groupToolbar']);
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
                                  controller.closeGroupSearchExpense();
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
                    ConstString.addExpense,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontFamily: AppFont.fontSemiBold, fontSize: 16),
                  );
          },
        ),
        actions: [
          GetBuilder<GroupController>(
              id: "groupToolbar",
              builder: (controller) {
                return controller.hasGroupSearchEnabled.value
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          controller.toggleGroupSearch();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: SvgPicture.asset(AppIcons.searchIcon),
                        ),
                      );
              })
        ],
      ),
      body: expenseWidget(context),
    );
  }

  Widget expenseWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => AddMemberScreen());
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.darkPrimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.primaryColor),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    SvgPicture.asset(AppIcons.add_fill),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      ConstString.addNewGroup,
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.darkPrimaryColor,
                          fontFamily: AppFont.fontMedium),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GetBuilder<GroupController>(
              id: 'search',
              init: GroupController(),
              builder: (controller) {
                return isLoad
                    ? groups!.length > 0 && groups!.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groups!.length,
                            itemBuilder: (context, index) {
                              bool isSelected =
                                  controller.selectedGroup.value?.id ==
                                      groups![index].id;
                              List<GroupMember> memberIds =
                                  groups![index].memberIds!;
                              GroupDataModel group = groups![index];
                              List<ContactModel?> groupMembers =
                                  controller.getContactNamesByNumbers(memberIds
                                      .where((element) =>
                                          element.user.mobileNo != null)
                                      .map((e) => e.user.mobileNo!)
                                      .toList());
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.darkPrimaryColor,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: ListTile(
                                    onTap: () {
                                      if (widget.isExpense!) {
                                        controller.selectGroup(groups![index]);
                                        Get.to(() => ExpenseForm(
                                              selectedGroup: groups![index],
                                            ));
                                      } else {
                                        Get.to(() => GroupDetails(
                                              groupData: groups![index],
                                            ));
                                      }
                                    },
                                    selected: isSelected,
                                    horizontalTitleGap: 10,
                                    leading: groups![index].groupProfile !=
                                                null &&
                                            groups![index]
                                                .groupProfile!
                                                .isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              height: 45,
                                              width: 45,
                                              imageUrl: groups![index]
                                                      .groupProfile! ??
                                                  '',
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      const SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Center(
                                                    child:
                                                        CupertinoActivityIndicator()),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: AppColors.darkPrimaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SvgPicture.asset(
                                                  AppImages.split_logo),
                                            ),
                                          ),
                                    title: Text(
                                      "${groups![index].name}",
                                      textScaler: const TextScaler.linear(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontSemiBold,
                                              color:
                                                  AppColors.darkPrimaryColor),
                                    ),
                                    subtitle: SizedBox(
                                      height: 20,
                                      child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Text(
                                              getUserName(
                                                  group, index, controller),
                                              textScaler:
                                                  const TextScaler.linear(1),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .darkPrimaryColor),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Text(
                                              " • ",
                                              textScaler:
                                                  const TextScaler.linear(1),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .darkPrimaryColor),
                                            );
                                          },
                                          itemCount: groups![index]
                                                      .memberIds!
                                                      .length >=
                                                  4
                                              ? 3
                                              : groups![index]
                                                  .memberIds!
                                                  .length),
                                    ),
                                    // trailing: SvgPicture.asset(
                                    //   isSelected
                                    //       ? AppIcons.checkFill
                                    //       : AppIcons.emptyCheck,
                                    //   height: 18,
                                    // ),
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox(
                            height: 500,
                            child: SafeArea(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.intro2,
                                  height: 100,
                                  width: double.infinity,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  ConstString.noData,
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: AppColors.darkPrimaryColor,
                                          fontFamily: AppFont.fontSemiBold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  ConstString.noDataSentance,
                                  textScaler: const TextScaler.linear(1),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          height: 1.4,
                                          fontSize: 13,
                                          color: AppColors.blackText,
                                          fontFamily: AppFont.fontRegular),
                                ),
                              ],
                            )),
                          )
                    : GroupsShimmer(itemCount: 10);
                // return StreamBuilder(
                //   stream: controller.fetchActiveGroupsForUser(
                //       controller.loggedInUser!.mobileNo!),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const GroupsShimmer(itemCount: 10);
                //     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                //       List<GroupDataModel> groups = snapshot.data!;
                //       return ListView.builder(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemCount: groups.length,
                //         itemBuilder: (context, index) {
                //           bool isSelected =
                //               controller.selectedGroup.value?.id ==
                //                   groups[index].id;
                //           List<GroupMember> memberIds =
                //               groups[index].memberIds!;
                //           GroupDataModel group = groups[index];
                //           List<ContactModel?> groupMembers =
                //               controller.getContactNamesByNumbers(memberIds
                //                   .where((element) =>
                //                       element.user.mobileNo != null)
                //                   .map((e) => e.user.mobileNo!)
                //                   .toList());
                //           return Container(
                //             margin: const EdgeInsets.only(bottom: 10),
                //             decoration: BoxDecoration(
                //                 border: Border.all(
                //                     color: AppColors.darkPrimaryColor,
                //                     width: 1),
                //                 borderRadius: BorderRadius.circular(15)),
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(vertical: 7),
                //               child: ListTile(
                //                 onTap: () {
                //                   controller.selectGroup(groups[index]);
                //                 },
                //                 selected: isSelected,
                //                 horizontalTitleGap: 10,
                //                 leading: groups[index].groupProfile != null &&
                //                         groups[index].groupProfile!.isNotEmpty
                //                     ? ClipOval(
                //                         child: CachedNetworkImage(
                //                           height: 45,
                //                           width: 45,
                //                           imageUrl: groups[index].groupProfile!,
                //                           errorWidget: (context, url, error) =>
                //                               const Icon(Icons.error),
                //                           progressIndicatorBuilder: (context,
                //                                   url, downloadProgress) =>
                //                               const SizedBox(
                //                             width: 30,
                //                             height: 30,
                //                             child: Center(
                //                                 child:
                //                                     CupertinoActivityIndicator()),
                //                           ),
                //                           fit: BoxFit.cover,
                //                         ),
                //                       )
                //                     : CustomGroupAvtarWidget(
                //                         size: const Size(80, 80),
                //                         userMobileList: groups[index]
                //                             .memberIds!
                //                             .map((e) => e.user.mobileNo)
                //                             .toList(),
                //                       ),
                //                 title: Text(
                //                   "${groups[index].name}",
                //                   textScaler: const TextScaler.linear(1),
                //                   style: Theme.of(context)
                //                       .textTheme
                //                       .titleMedium!
                //                       .copyWith(
                //                           fontSize: 16,
                //                           fontFamily: AppFont.fontSemiBold,
                //                           color: AppColors.darkPrimaryColor),
                //                 ),
                //                 subtitle: SizedBox(
                //                   height: 20,
                //                   child: ListView.separated(
                //                       scrollDirection: Axis.horizontal,
                //                       itemBuilder: (context, index) {
                //                         return Text(
                //                           getUserName(group, index, controller),
                //                           textScaler:
                //                               const TextScaler.linear(1),
                //                           style: Theme.of(context)
                //                               .textTheme
                //                               .titleMedium!
                //                               .copyWith(
                //                                   fontSize: 13,
                //                                   color: AppColors
                //                                       .darkPrimaryColor),
                //                         );
                //                       },
                //                       separatorBuilder: (context, index) {
                //                         return Text(
                //                           " • ",
                //                           textScaler:
                //                               const TextScaler.linear(1),
                //                           style: Theme.of(context)
                //                               .textTheme
                //                               .titleMedium!
                //                               .copyWith(
                //                                   fontSize: 13,
                //                                   color: AppColors
                //                                       .darkPrimaryColor),
                //                         );
                //                       },
                //                       itemCount:
                //                           groups[index].memberIds!.length >= 4
                //                               ? 3
                //                               : groups[index]
                //                                   .memberIds!
                //                                   .length),
                //                 ),
                //                 trailing: SvgPicture.asset(
                //                   isSelected
                //                       ? AppIcons.checkFill
                //                       : AppIcons.emptyCheck,
                //                   height: 18,
                //                 ),
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     } else {
                //       return SizedBox(
                //         height: 500,
                //         child: SafeArea(
                //             child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               AppImages.intro2,
                //               height: 100,
                //               width: double.infinity,
                //             ),
                //             const SizedBox(
                //               height: 30,
                //             ),
                //             Text(
                //               ConstString.noData,
                //               textScaler: const TextScaler.linear(1),
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .titleMedium!
                //                   .copyWith(
                //                       color: AppColors.darkPrimaryColor,
                //                       fontFamily: AppFont.fontSemiBold),
                //             ),
                //             const SizedBox(
                //               height: 10,
                //             ),
                //             Text(
                //               ConstString.noDataSentance,
                //               textScaler: const TextScaler.linear(1),
                //               textAlign: TextAlign.center,
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .titleMedium!
                //                   .copyWith(
                //                       height: 1.4,
                //                       fontSize: 13,
                //                       color: AppColors.blackText,
                //                       fontFamily: AppFont.fontRegular),
                //             ),
                //           ],
                //         )),
                //       );
                //     }
                //   },
                // );
              },
            ),
            const SizedBox(
              height: 30,
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       if (controller.selectedGroup.value != null) {
            //         if (controller.checkUserStatus(
            //             controller.selectedGroup.value!,
            //             controller.loggedInUser!.mobileNo!)) {
            //           Get.to(() => ExpenseForm(
            //                 selectedGroup: controller.selectedGroup.value,
            //               ));
            //         } else {
            //           showInSnackBar(context,
            //               "You can't add expense.You are not in group!");
            //         }
            //       } else {
            //         showInSnackBar(context, "Please select any group");
            //       }
            //     },
            //     style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.primaryColor,
            //         fixedSize: const Size(200, 50),
            //         elevation: 0,
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(30))),
            //     child: Text(
            //       ConstString.next,
            //       textScaler: const TextScaler.linear(1),
            //       style: Theme.of(context).textTheme.displayMedium!.copyWith(
            //           color: AppColors.darkPrimaryColor,
            //           fontFamily: AppFont.fontMedium),
            //     ))
          ],
        ),
      ),
    );
  }

  String getUserName(
      GroupDataModel group, int index, GroupController controller) {
    /*return group.memberIds![index].user.mobileNo !=
            controller.loggedInUser!.mobileNo
        ? group.memberIds![index].user.name!.split(" ").first
        : "You";*/
    return controller.userController
            .getNameByPhoneNumber(group.memberIds![index].user.mobileNo) ??
        group.memberIds![index].user.name ??
        "Split User";
  }
}

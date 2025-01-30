import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/screen/add_member_screen.dart';
import 'package:split/screen/group_details.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

class ViewAllGroups extends StatelessWidget {
  ViewAllGroups({super.key});

  final GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 1,
        shadowColor: AppColors.decsGrey.withOpacity(0.5),
        backgroundColor: AppColors.white,
        centerTitle: false,
        leading: Obx(
          () => !controller.hasGroupSearchEnabled.value
              ? GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SvgPicture.asset(
                      AppIcons.back_icon,
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
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
                    ConstString.allGroups,
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
      body: viewGroupWidget(context),
    );
  }

  Widget viewGroupWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                /*if (controller.appContactServices.appContacts.isEmpty) {
                  showProgressDialogue(context);
                  return;
                }*/
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
                return controller.filteredGroups.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredGroups.length,
                        itemBuilder: (context, index) {
                          List<GroupDataModel> groups =
                              controller.filteredGroups;
                          List<GroupMember> memberIds =
                              groups[index].memberIds ?? [];
                          GroupDataModel group = groups[index];
                          List<ContactModel?> groupMembers =
                              controller.getContactNamesByNumbers(memberIds
                                  .where((element) =>
                                      element.user.mobileNo != null)
                                  .map((e) => e.user.mobileNo!)
                                  .toList());
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => GroupDetails(
                                    groupData: groups[index],
                                  ));
                              // Get.to(() => GroupSetting(
                              //       groupData: groups[index],
                              //     ));
                            },
                            child: Container(
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
                                  horizontalTitleGap: 10,
                                  leading: groups[index].groupProfile != null &&
                                          groups[index].groupProfile!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            height: 45,
                                            width: 45,
                                            imageUrl:
                                                groups[index].groupProfile!,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Center(
                                                  child: LoadingIndicator(
                                                colors: [
                                                  AppColors.primaryColor
                                                ],
                                                indicatorType:
                                                    Indicator.ballScale,
                                                strokeWidth: 1,
                                              )),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CustomGroupAvtarWidget(
                                          size: Size(80, 80),
                                          userMobileList: groups[index]
                                              .memberIds!
                                              .map((e) => e.user.mobileNo)
                                              .toList(),
                                        ),
                                  title: Text(
                                    "${groups[index].name}",
                                    textScaler: const TextScaler.linear(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            fontFamily: AppFont.fontSemiBold,
                                            color: AppColors.darkPrimaryColor),
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
                                        itemCount: groupMembers.length >= 4
                                            ? 3
                                            : groupMembers.length),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            height: 400,
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
                                  height: 10,
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
                              ],
                            ),
                          ),
                        ),
                      );
              },
            )
            // StreamBuilder(
            //   stream: controller.fetchGroups(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const GroupsShimmer(itemCount: 10);
            //     } else if (snapshot.hasError) {
            //       return Text(
            //         "Error : ${snapshot.error}",
            //         style: Theme.of(context).textTheme.titleMedium,
            //       );
            //     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //       List<GroupDataModel> groups = snapshot.data!;
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         physics: const NeverScrollableScrollPhysics(),
            //         itemCount: groups.length,
            //         itemBuilder: (context, index) {
            //           List<UserModel> memberIds = groups[index].memberIds ?? [];
            //           GroupDataModel group = groups[index];
            //           List<ContactModel?> groupMembers =
            //               controller.getContactNamesByNumbers(memberIds
            //                   .where((element) => element.mobileNo != null)
            //                   .map((e) => e.mobileNo!)
            //                   .toList());
            //           return GestureDetector(
            //             onTap: () {
            //               Get.to(() => GroupSetting(
            //                     groupData: groups[index],
            //                   ));
            //             },
            //             child: Container(
            //               margin: const EdgeInsets.only(bottom: 10),
            //               decoration: BoxDecoration(
            //                   border: Border.all(
            //                       color: AppColors.darkPrimaryColor, width: 1),
            //                   borderRadius: BorderRadius.circular(15)),
            //               child: Padding(
            //                 padding: const EdgeInsets.symmetric(vertical: 7),
            //                 child: ListTile(
            //                   horizontalTitleGap: 10,
            //                   leading: groups[index].groupProfile != null &&
            //                           groups[index].groupProfile!.isNotEmpty
            //                       ? ClipOval(
            //                           child: CachedNetworkImage(
            //                             height: 45,
            //                             width: 45,
            //                             imageUrl: groups[index].groupProfile!,
            //                             errorWidget: (context, url, error) =>
            //                                 const Icon(Icons.error),
            //                             progressIndicatorBuilder:
            //                                 (context, url, downloadProgress) =>
            //                                     SizedBox(
            //                               width: 30,
            //                               height: 30,
            //                               child: Center(
            //                                   child: LoadingIndicator(
            //                                 colors: [AppColors.primaryColor],
            //                                 indicatorType: Indicator.ballScale,
            //                                 strokeWidth: 1,
            //                               )),
            //                             ),
            //                             fit: BoxFit.cover,
            //                           ),
            //                         )
            //                       : CustomGroupAvtarWidget(
            //                           size: Size(80, 80),
            //                           imageUrlList: groups[index]
            //                               .memberIds!
            //                               .map((e) => e.profilePicture)
            //                               .toList(),
            //                         ),
            //                   title: Text(
            //                     "${groups[index].name}",
            //                     style: Theme.of(context)
            //                         .textTheme
            //                         .titleMedium!
            //                         .copyWith(
            //                             fontSize: 16,
            //                             fontFamily: AppFont.fontSemiBold,
            //                             color: AppColors.darkPrimaryColor),
            //                   ),
            //                   subtitle: SizedBox(
            //                     height: 20,
            //                     child: ListView.separated(
            //                         scrollDirection: Axis.horizontal,
            //                         itemBuilder: (context, index) {
            //                           return Text(
            //                             group.memberIds![index].mobileNo !=
            //                                     controller
            //                                         .loggedInUser!.mobileNo
            //                                 ? group.memberIds![index].name!
            //                                     .split(" ")
            //                                     .first
            //                                 : "You",
            //                             style: Theme.of(context)
            //                                 .textTheme
            //                                 .titleMedium!
            //                                 .copyWith(
            //                                     fontSize: 13,
            //                                     color:
            //                                         AppColors.darkPrimaryColor),
            //                           );
            //                         },
            //                         separatorBuilder: (context, index) {
            //                           return Text(
            //                             " • ",
            //                             style: Theme.of(context)
            //                                 .textTheme
            //                                 .titleMedium!
            //                                 .copyWith(
            //                                     fontSize: 13,
            //                                     color:
            //                                         AppColors.darkPrimaryColor),
            //                           );
            //                         },
            //                         itemCount: groupMembers.length >= 4
            //                             ? 3
            //                             : groupMembers.length),
            //                   ),
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
            // )
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

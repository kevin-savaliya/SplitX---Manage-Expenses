import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:split/controller/notification_history_controller.dart';
import 'package:split/model/group_data.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

import '../controller/group_controller.dart';

final GroupController groupController = Get.find<GroupController>();

class NotificationScreen extends GetWidget<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationController>(
      init: NotificationController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
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
              title: Text(
                ConstString.notification,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
              ),
            ),
            // body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            //   stream: FirebaseFirestore.instance
            //       .collection('notifications')
            //       .doc(FirebaseAuth.instance.currentUser?.uid)
            //       .snapshots(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Column(
            //         children: [
            //           Center(
            //               child: CupertinoActivityIndicator(
            //             color: AppColors.primaryColor,
            //             animating: true,
            //             radius: 24,
            //           )),
            //         ],
            //       );
            //     }
            //
            //     // If there are no notifications, display a message
            //     // if () {
            //     //   return const Center(
            //     //     child: Text('No notifications available.'),
            //     //   );
            //     // }
            //
            //     return ListView.separated(
            //       physics: const BouncingScrollPhysics(),
            //       itemCount: snapshot.data?.get('notifications').length ?? 0,
            //       separatorBuilder: (context, index) {
            //         return Divider(
            //           height: 0,
            //           thickness: 1,
            //           indent: 1,
            //           endIndent: 1,
            //           color: AppColors.lineGrey,
            //         );
            //       },
            //       itemBuilder: (context, index) {
            //         return Slidable(
            //           key: UniqueKey(),
            //           endActionPane: ActionPane(
            //             motion: const DrawerMotion(),
            //             extentRatio: 0.18,
            //             dismissible: DismissiblePane(
            //               onDismissed: () async {
            //                 await controller.deleteNotification(index);
            //               },
            //               dismissThreshold: 0.8,
            //             ),
            //             children: [
            //               SlidableAction(
            //                 onPressed: (context) async {
            //                   await controller.deleteNotification(index);
            //                 },
            //                 backgroundColor: AppColors.debit,
            //                 flex: 1,
            //                 foregroundColor: Colors.white,
            //                 icon: CupertinoIcons.delete_simple,
            //               ),
            //             ],
            //           ),
            //           child: Padding(
            //             padding:
            //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            //             child: Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SizedBox(
            //                     height: 45,
            //                     width: 45,
            //                     child: Stack(
            //                       children: [
            //                         Positioned(
            //                           top: 0,
            //                           left: 0,
            //                           child: Container(
            //                             height: 45,
            //                             width: 45,
            //                             decoration: BoxDecoration(
            //                                 color: AppColors.white,
            //                                 borderRadius: BorderRadius.circular(100)),
            //                             /*child: UserProfileWidget(
            //                               size: const Size(40, 40),
            //                               userData: controller
            //                                       .userController.allAppUser[
            //                                   Random().nextInt(controller
            //                                       .userController
            //                                       .allAppUser
            //                                       .length)], // FIXME: change logic
            //                             ),*/
            //                           ),
            //                         ),
            //                         Positioned(
            //                           bottom: 0,
            //                           right: 0,
            //                           child: Container(
            //                             height: 22,
            //                             width: 22,
            //                             padding: const EdgeInsets.all(0.7),
            //                             decoration: BoxDecoration(
            //                                 color: AppColors.white,
            //                                 borderRadius: BorderRadius.circular(100)),
            //                             /*child: UserProfileWidget(
            //                               size: const Size(22, 22),
            //                               userData: controller
            //                                       .userController.allAppUser[
            //                                   Random().nextInt(controller
            //                                       .userController
            //                                       .allAppUser
            //                                       .length)], // FIXME: change logic
            //                             ),*/
            //                           ),
            //                         ),
            //                       ],
            //                     )),
            //                 const SizedBox(width: 10),
            //                 Expanded(
            //                     child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     RichText(
            //                         text: TextSpan(
            //                             children: getTitleContents(context))),
            //                     const SizedBox(height: 5),
            //                     Text(
            //                       getTimeOfNotification(DateTime.now()),
            //                       textScaler: const TextScaler.linear(1),
            //                       style: Theme.of(context)
            //                           .textTheme
            //                           .titleSmall!
            //                           .copyWith(
            //                             fontSize: 11,
            //                             color: AppColors.txtnotify,
            //                             fontFamily: AppFont.fontRegular,
            //                           ),
            //                     ),
            //                   ],
            //                 )),
            //               ],
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   },
            // ),
            body: (controller.notificationList.isEmpty)
                ? Center(
                    child: Text(
                      'No notification available',
                      textScaler: const TextScaler.linear(1),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontFamily: AppFont.fontBold, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.getNotifications(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.separated(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.notificationList.length,
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 0,
                                  thickness: 1,
                                  indent: 1,
                                  endIndent: 1,
                                  color: AppColors.lineGrey,
                                );
                              },
                              itemBuilder: (context, index) {
                                return notificationItemWidget(
                                    controller, index, context);
                              })
                        ],
                      ),
                    ),
                  ));
      },
    );
    // body: Column(
    //   children: [
    //     ListView.separated(
    //       shrinkWrap: true,
    //       physics: const BouncingScrollPhysics(),
    //       itemCount: 5,
    //       separatorBuilder: (context, index) {
    //         return Divider(
    //           height: 0,
    //           thickness: 1,
    //           indent: 1,
    //           endIndent: 1,
    //           color: AppColors.lineGrey,
    //         );
    //       },
    //       itemBuilder: (context, index) {
    //         return Slidable(
    //           key: UniqueKey(),
    //           endActionPane: ActionPane(
    //             motion: const DrawerMotion(),
    //             extentRatio: 0.18,
    //             dismissible: DismissiblePane(
    //               onDismissed: () async {
    //                 //await controller.deleteNotification(index);
    //               },
    //               dismissThreshold: 0.8,
    //             ),
    //             children: [
    //               SlidableAction(
    //                 onPressed: (context) async {
    //                   // await controller.deleteNotification(index);
    //                 },
    //                 backgroundColor: AppColors.debit,
    //                 flex: 1,
    //                 foregroundColor: Colors.white,
    //                 icon: CupertinoIcons.delete_simple,
    //               ),
    //             ],
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 SizedBox(
    //                     height: 45,
    //                     width: 45,
    //                     child: Stack(
    //                       children: [
    //                         Positioned(
    //                           top: 0,
    //                           left: 0,
    //                           child: Container(
    //                               height: 45,
    //                               width: 45,
    //                               decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(100)),
    //                               child: CircleAvatar(
    //                                 backgroundColor: AppColors.listColor5,
    //                               )),
    //                         ),
    //                         Positioned(
    //                           bottom: 0,
    //                           right: 0,
    //                           child: Container(
    //                             height: 22,
    //                             width: 22,
    //                             padding: const EdgeInsets.all(0.7),
    //                             decoration:
    //                                 BoxDecoration(color: AppColors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 1)),
    //                             child: CircleAvatar(
    //                               backgroundColor: AppColors.listColor3,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     )),
    //                 const SizedBox(width: 10),
    //                 Expanded(
    //                     child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     RichText(text: TextSpan(children: getTitleContents(context))),
    //                     const SizedBox(height: 5),
    //                     Text(
    //                       getTimeOfNotification(DateTime.now()),
    //                       textScaler: const TextScaler.linear(1),
    //                       style: Theme.of(context).textTheme.titleSmall!.copyWith(
    //                             fontSize: 11,
    //                             color: AppColors.txtnotify,
    //                             fontFamily: AppFont.fontRegular,
    //                           ),
    //                     ),
    //                   ],
    //                 )),
    //               ],
    //             ),
    //           ),
    //         );
    //       },
    //     )
    //   ],
    // ),
  }

  Slidable notificationItemWidget(
      NotificationController controller, int index, BuildContext context) {
    return Slidable(
      enabled: false,
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.18,
        dismissible: DismissiblePane(
          onDismissed: () async {
            // await controller
            //     .deleteNotification(index);
          },
          dismissThreshold: 0.8,
        ),
        children: [
          // SlidableAction(
          //   onPressed: (context) async {
          //     await controller
          //         .deleteNotification(index);
          //   },
          //   backgroundColor: AppColors.debit,
          //   flex: 1,
          //   foregroundColor: Colors.white,
          //   icon: CupertinoIcons.delete_simple,
          // ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 45,
                width: 45,
                child: Stack(
                  children: [
                    groupController.userDataModel!.profilePicture != null
                        ? Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(100)),
                                child: CircleAvatar(
                                  //backgroundColor: AppColors.listColor5,
                                  backgroundImage: NetworkImage(
                                      '${groupController.userDataModel!.profilePicture}'),
                                )),
                          )
                        : Positioned(
                            top: 0,
                            left: 0,
                            child: ClipOval(
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    color: AppColors.darkPrimaryColor,
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SvgPicture.asset(
                                            AppImages.split_logo)))),
                          ),
                    FutureBuilder(
                      future: controller.fetchGroupData(
                          controller.notificationList[index].groupId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CupertinoActivityIndicator());
                        } else if (snapshot.hasData) {
                          GroupDataModel group = snapshot.data!;
                          return group.groupProfile!.isNotEmpty
                              ? Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.lineGrey,
                                            width: 1)),
                                    child: ClipOval(
                                        child: Image.network(
                                      group.groupProfile!,
                                      fit: BoxFit.cover,
                                    )),
                                  ),
                                )
                              : Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                        color: AppColors.darkPrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.lineGrey,
                                            width: 1)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        AppImages.split_logo,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                        } else {
                          return Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                  color: AppColors.darkPrimaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.lineGrey, width: 1)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SvgPicture.asset(
                                  AppImages.split_logo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "${controller.notificationList[index].description}",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 14,
                          color: AppColors.black,
                          fontFamily: AppFont.fontMedium)),
                  // TextSpan(
                  //     text: " John Doe\n",
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .titleMedium!
                  //         .copyWith(fontSize: 14, color: AppColors.black, fontFamily: AppFont.fontSemiBold)),
                  // TextSpan(
                  //     text: "${controller.notificationList[index].description}",
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .titleMedium!
                  //         .copyWith(fontSize: 14, color: AppColors.black, fontFamily: AppFont.fontRegular)),
                  // TextSpan(
                  //     text: "Medic",
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .titleMedium!
                  //         .copyWith(fontSize: 14, color: AppColors.black, fontFamily: AppFont.fontSemiBold)),
                ])),
                const SizedBox(height: 5),
                Text(
                  getTimeOfNotification(DateTime.parse(
                      controller.notificationList[index].createdAt.toString())),
                  textScaler: const TextScaler.linear(1),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 11,
                        color: AppColors.txtnotify,
                        fontFamily: AppFont.fontRegular,
                      ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> getTitleContents(BuildContext context, int index) {
    List<TextSpan> data = [
      TextSpan(
          text: "${controller.notificationList[0].title}",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.black,
              fontFamily: AppFont.fontSemiBold)),
      TextSpan(
          text: "John Doe",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.black,
              fontFamily: AppFont.fontSemiBold)),
      TextSpan(
          text: " has added you to ",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.black,
              fontFamily: AppFont.fontRegular)),
      TextSpan(
          text: "Medic",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.black,
              fontFamily: AppFont.fontSemiBold)),
    ];
    if (Random().nextBool()) {
      data.add(TextSpan(
          text: " group",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.black,
              fontFamily: AppFont.fontRegular)));
    }
    return data;
  }

  String getTimeOfNotification(DateTime time) {
    return "${DateFormat.d().format(time)} ${DateFormat.MMM().format(time)}, ${DateFormat.y().format(time)} ${DateFormat.jm().format(time)}";
  }
}

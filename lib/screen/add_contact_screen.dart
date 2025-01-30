import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          ConstString.addNewContact,
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
        ),
      ),
      body: contactWidget(context),
    );
  }

  Widget contactWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ConstString.name,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    // controller: controller.addController,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.txtGrey, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SvgPicture.asset(AppIcons.profileIcon),
                        ),
                        hintText: "Enter Name",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20)),
                  )),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ConstString.phoneNumber,
              textScaler: const TextScaler.linear(1),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    // controller: controller.addController,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.txtGrey, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: SvgPicture.asset(AppIcons.phoneIcon),
                        ),
                        hintText: "Enter Phone Number",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20)),
                  )),
            ),
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () async {
                await FirebaseDynamicsLinking().createDynamicLink();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  fixedSize: const Size(200, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                ConstString.invite,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
              )),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class FirebaseDynamicsLinking {
  Future<void> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://splitx.page.link',
      link: Uri.parse('https://splitx.page.link/invite'),
      androidParameters: const AndroidParameters(
        packageName: 'com.split.expense',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.split.expense',
        minimumVersion: '0',
        appStoreId: '6476020838',
      ),
      socialMetaTagParameters: const SocialMetaTagParameters(
        title: 'Invite',
        description: 'Invite your friend',
      ),
    );

    final ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    final Uri shortUrl = dynamicLink.shortUrl;
    print(shortUrl);

    Share.share('Hey, join me on SplitX! Here is the invite link: $shortUrl');
  }
}

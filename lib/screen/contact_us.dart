import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late final WebViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..loadRequest(Uri.parse('https://splitx.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        titleSpacing: 0,
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
        title: Text(
          "Contact Us",
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.darkPrimaryColor,
              fontSize: 17,
              fontFamily: AppFont.fontMedium),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

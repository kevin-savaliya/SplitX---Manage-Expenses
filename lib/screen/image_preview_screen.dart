import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/assets.dart';

class ImagePreviewScreen extends StatelessWidget {
  String? image;

  ImagePreviewScreen({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 1,
        shadowColor: AppColors.decsGrey.withOpacity(0.5),
        backgroundColor: AppColors.white,
        centerTitle: false,
        leading: GestureDetector(behavior: HitTestBehavior.opaque,
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: image!,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                width: 30,
                height: 30,
                child: Center(
                    child: LoadingIndicator(
                  colors: [AppColors.primaryColor],
                  indicatorType: Indicator.ballScale,
                  strokeWidth: 1,
                )),
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

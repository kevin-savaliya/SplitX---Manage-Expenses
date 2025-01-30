import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';

class ContactShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const ContactShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300]!,
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ));
  }
}

class HistoryListShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const HistoryListShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              child: Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300]!,
                    borderRadius: BorderRadius.circular(15)),
              ),
            );
          },
        ));
  }
}

class HeaderNameWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const HeaderNameWidgetShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "SplitX User",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: AppFont.fontSemiBold),
            )
          ],
        ));
  }
}

class NameWidgetShimmer extends StatelessWidget {
  NameWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Text(
          "SplitX User",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold),
        ));
  }
}

class NumberWidgetShimmer extends StatelessWidget {
  NumberWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Text(
          "000 000 000",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppFont.fontSemiBold),
        ));
  }
}

class DividerWidgetShimmer extends StatelessWidget {
  DividerWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.grey),
        ));
  }
}

class GroupDataShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const GroupDataShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Colors.black)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(radius: 24),
                        horizontalTitleGap: 20,
                        title: Text(
                          "Split",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontFamily: AppFont.fontSemiBold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}

class GroupsShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const GroupsShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300]!,
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ));
  }
}

class DashboardGroupsShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const DashboardGroupsShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
              child: CircleAvatar(
                radius: 35,
              ),
            );
          },
        ));
  }
}

class ExpenseWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const ExpenseWidgetShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }
}

class NativeAdsWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const NativeAdsWidgetShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 345,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            radius: 12,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Ads Loading",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.darkPrimaryColor,
                fontFamily: AppFont.fontMedium),
          )
        ],
      ),
    );
    // return Shimmer.fromColors(
    //     baseColor: Colors.grey[100]!,
    //     highlightColor: Colors.grey[50]!,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 10),
    //       child: Container(
    //         height: 345,
    //         width: double.infinity,
    //         decoration: BoxDecoration(
    //             color: Colors.grey[300]!,
    //             borderRadius: BorderRadius.circular(12)),
    //       ),
    //     ));
  }
}

class BannerAdsWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const BannerAdsWidgetShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 60,
        child: Column(
          children: [
            CupertinoActivityIndicator(
              radius: 12,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Ads Loading",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.darkPrimaryColor,
                  fontFamily: AppFont.fontMedium),
            )
          ],
        ),
      ),
    );
    // return SizedBox(height: 100,child: Lottie.asset("asset/ads_loader.json"));
    // return Shimmer.fromColors(
    //     baseColor: Colors.grey[100]!,
    //     highlightColor: Colors.grey[50]!,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 10),
    //       child: Container(
    //         height: 60,
    //         width: double.infinity,
    //         decoration: BoxDecoration(
    //             color: Colors.grey[300]!,
    //             borderRadius: BorderRadius.circular(12)),
    //         child: Center(
    //             child: Text(
    //           "ADS Loading",
    //           style: Theme.of(context)
    //               .textTheme
    //               .titleMedium!
    //               .copyWith(color: AppColors.white),
    //         )),
    //       ),
    //     ));
  }
}

class DashboardGroupWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const DashboardGroupWidgetShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 180,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.grey[200]!,
              borderRadius: BorderRadius.circular(12)),
        ));
  }
}

class HomeLoadWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const HomeLoadWidgetShimmer(
      {super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const HistoryWidgetShimmer(itemCount: 1),
              Container(
                height: 180,
                width: 320,
                decoration: BoxDecoration(
                    color: Colors.grey[200]!,
                    borderRadius: BorderRadius.circular(12)),
              ),
              const HistoryWidgetShimmer(itemCount: 1),
              const HistoryWidgetShimmer(itemCount: 1),
              const HistoryWidgetShimmer(itemCount: 1),
              const HistoryWidgetShimmer(itemCount: 1),
            ],
          ),
        ));
  }
}

class HistoryWidgetShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const HistoryWidgetShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[200]!,
                borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }
}

class ChatMessageShimmer extends StatelessWidget {
  final int? itemCount;
  final double? height;

  const ChatMessageShimmer({super.key, required this.itemCount, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 15,
          itemBuilder: (context, index) {
            return Align(
              alignment:
                  index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Container(
                  height: 35,
                  width: index % 2 == 1 ? 100 : 150,
                  decoration: BoxDecoration(
                      color: Colors.grey[100]!,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            );
          },
        ));
  }
}

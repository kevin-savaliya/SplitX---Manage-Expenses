import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/screen/phone_login_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';

class CountryPickScreen extends StatefulWidget {
  const CountryPickScreen({super.key});

  @override
  State<CountryPickScreen> createState() => _CountryPickScreenState();
}

class _CountryPickScreenState extends State<CountryPickScreen> {
  Country? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.white,
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ConstString.chooseCountry,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 18, fontFamily: AppFont.fontSemiBold)),
                const SizedBox(
                  height: 10,
                ),
                Text(ConstString.countrySentance,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(color: AppColors.dark, height: 1.3)),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    showCountryCodePicker(context, controller);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.decsGrey),
                    child: selectedCountry != null
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  "${selectedCountry?.flagEmoji}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontFamily: AppFont.fontRegular,
                                          fontSize: 18,
                                          color: AppColors.darkPrimaryColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${selectedCountry?.name}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontFamily: AppFont.fontRegular,
                                          fontSize: 15,
                                          color: AppColors.darkPrimaryColor),
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  AppIcons.arrow_down,
                                  height: 8,
                                )
                              ],
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Select Country",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        letterSpacing: 1,
                                        fontFamily: AppFont.fontRegular,
                                        fontSize: 15,
                                        color: AppColors.darkPrimaryColor),
                              ),
                              SvgPicture.asset(
                                AppIcons.arrow_down,
                                height: 8,
                              )
                            ],
                          ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () {
                        if (selectedCountry != null) {
                          Get.to(() => PhoneLoginScreen(
                                countryCode: selectedCountry!.phoneCode,
                                countryFlag: selectedCountry!.flagEmoji,
                              ));
                        } else {
                          showInSnackBar(
                              context, "Please select your country!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          fixedSize: const Size(200, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text(
                        ConstString.btnContinue,
                        textScaler: const TextScaler.linear(1),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                color: AppColors.darkPrimaryColor,
                                fontFamily: AppFont.fontMedium),
                      )),
                )
              ],
            ),
          )),
        );
      },
    );
  }

  void showCountryCodePicker(BuildContext context, AuthController controller) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          searchTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.darkPrimaryColor,
              fontFamily: AppFont.fontMedium),
          inputDecoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIcon: const Icon(CupertinoIcons.search, size: 22),
            hintText: "Search Country",
            filled: true,
            fillColor: AppColors.decsGrey,
            hintStyle: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: AppColors.txtGrey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.white)),
          ),
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              fontFamily: AppFont.fontRegular,
              color: AppColors.darkPrimaryColor)),
      onSelect: (value) {
        selectedCountry = value;
        print("Country : $selectedCountry");
        setState(() {});
      },
    );
  }
}

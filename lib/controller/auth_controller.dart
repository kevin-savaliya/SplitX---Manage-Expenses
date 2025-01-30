import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:split/controller/user_repository.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/country_pick_screen.dart';
import 'package:split/screen/homescreen.dart';
import 'package:split/screen/otp_verify.dart';
import 'package:split/screen/phone_login_screen.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/controller_ids.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/app_dialogue.dart';

class AuthController extends GetxController {
  TextEditingController otpController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // RxString countryCode = "+91".obs;  //assign
  RxString verificationId = "".obs;
  RxString verificationid = "".obs;
  RxInt start = 30.obs;
  bool isLoading = false;
  RxBool isOtpSent = false.obs;
  RxBool resendButton = true.obs;

  var otpAttempts = 0.obs;

  AppStorage appStorage = AppStorage();

  var selectedCountry = Rx<Country?>(null);
  var selectedCountryCode = '+91'.obs;
  var selectedCurrency = 'INR'.obs;

  Rx<UserGender> selectedGender = UserGender.male.obs;

  Timer? timer;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const continueButtonId = 'continueButtonId';

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
    update([continueButtonId]);
  }

  String getPhoneNumber() {
    if (selectedCountryCode.isEmpty) {
      return '';
    }
    String mPhoneNumber = phoneNumberController.text.trim();
    return (selectedCountryCode + mPhoneNumber).replaceAll('+', '');
  }

  Future<void> actionVerifyPhone(BuildContext context,
      {required bool isLogin}) async {
    update([AuthController.continueButtonId]);
    FocusManager.instance.primaryFocus?.unfocus();

    await verifyPhoneNumber(context, isLogin: isLogin);

    update([AuthController.continueButtonId]);
  }

  Future<void> verifyPhoneNumber(BuildContext context,
      {bool second = false, bool isLogin = false}) async {
    isOtpSent = true.obs;
    update([continueButtonId]);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+${getPhoneNumber()}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          isOtpSent = false.obs;
          update([continueButtonId]);
          return _auth.signInWithCredential(credential).then((value) {
            showInSnackBar(context, ConstString.successLogin, isSuccess: true);
            return;
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          isOtpSent = false.obs;
          update([continueButtonId]);

          log("Verification error : ${exception.message}");
          isLoading = false;
          update([ControllerIds.verifyButtonKey]);
          authException(context, exception);
        },
        codeSent:
            (String currentVerificationId, int? forceResendingToken) async {
          verificationId.value = currentVerificationId;
          isOtpSent = false.obs;
          update([continueButtonId]);
          log("$verificationId otp is sent ");

          showInSnackBar(context, ConstString.otpSent, isSuccess: true);

          start.value = 30;
          if (timer?.isActive != true) {
            startTimer();
          }

          if (!second) {
            Get.to(() => OtpVerifyScreen(
                phoneNumber: getPhoneNumber(),
                verificationId: verificationId.value));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isOtpSent = false.obs;
          update([continueButtonId]);

          verificationid = verificationId.obs;
        },
      );
    } catch (e) {
      log("------verify number with otp sent-----$e");
    }
  }

  RxInt startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start.value == 0) {
          timer.cancel();
          resendButton = false.obs;
        } else {
          start.value != 0 ? start-- : null;
          update(['timer']);
        }
      },
    );
    return start;
  }

  Future<void> verifyOtp(BuildContext context, User? user, String OTP) async {
    if (otpController.text.isEmpty) {
      showInSnackBar(
        context,
        ConstString.enterOtp,
        title: ConstString.enterOtpMessage,
      );
      return;
    }
    isLoading = true;
    update([ControllerIds.verifyButtonKey]);
    try {
      showProgressDialogue(context);
      final UserCredential result;
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId.value, smsCode: OTP);

      if (user != null) {
        if (user.phoneNumber == null) {
          result = await user.linkWithCredential(phoneAuthCredential);
          log('data to check 1 ${getPhoneNumber()}');
        } else {
          result = await _auth.signInWithCredential(phoneAuthCredential);
          log(ConstString.successLogin);
        }
        isLoading = false;
        update([ControllerIds.verifyButtonKey]);
      } else {
        result = await _auth.signInWithCredential(phoneAuthCredential);
        isLoading = false;
        update([ControllerIds.verifyButtonKey]);
      }
      isLoading = true;
      update([ControllerIds.verifyButtonKey]);
      if (result.additionalUserInfo?.isNewUser ?? false) {
        log('data to check 2 ${getPhoneNumber()}');
        var gotUser = await _createUserInUserCollection(result,
            displayName: /*getUserName()*/ "");
        await appStorage.setUserData(gotUser);
        await NotificationService.instance.getTokenAndUpdateCurrentUser();
        await Get.offAll(() => HomeScreen());
        isLoading = false;
        otpAttempts.value = 0;
        update([ControllerIds.verifyButtonKey]);
      } else {
        var gotUser = await _createUserInUserCollection(result,
            displayName: "" /*getUserName()*/);
        isLoading = false;
        update([ControllerIds.verifyButtonKey]);

        await appStorage.setUserData(gotUser);
        await NotificationService.instance.getTokenAndUpdateCurrentUser();
        await Get.offAll(() => HomeScreen());
        otpAttempts.value = 0;
      }
      isLoading = false;
      update([ControllerIds.verifyButtonKey]);
    } on FirebaseAuthException catch (e) {
      Get.back();
      authException(context, e);
      isLoading = false;
      update([ControllerIds.verifyButtonKey]);
    } catch (e) {
      Get.back();
      isLoading = false;
      update([ControllerIds.verifyButtonKey]);
    }
  }

  /*String getUserName() {
    List<String> names = [];
    // return first and last name with joined string with single space  - firstNameController lastNameController
    names.add(firstNameController.text.trim());
    names.add(lastNameController.text.trim());
    return names.join(" ");
  }*/

  Future<UserModel> _createUserInUserCollection(
    UserCredential credentials, {
    String? displayName,
  }) async {
    late UserModel userModel;
    bool isUserExist =
        await UserRepository.instance.isUserExist(credentials.user!.uid);

    if (!isUserExist) {
      // List<String> name = getFirstLastName(credentials);
      String? fcmToken = await _firebaseMessaging.getToken();
      String? _mobileNo = phoneNumberController.text.trim().replaceAll('+', '');
      int _countryCode = int.parse(selectedCountryCode.replaceAll('+', ''));
      userModel = UserModel.newUser(
          id: credentials.user?.uid,
          // name: firstNameController.text.trim(),
          name: "",
          profilePicture: credentials.user?.photoURL,
          countryCode: _countryCode,
          currencyCode: selectedCurrency.value,
          mobileNo: _mobileNo.toString(),
          gender: selectedGender.value.name,
          createdAt: DateTime.now(),
          fcmToken: fcmToken,
          enablePushNotification: true);
      await UserRepository.instance.createNewUser(userModel);
    } else {
      userModel =
          await UserRepository.instance.fetchUser(credentials.user!.uid);
    }
    return userModel;
  }

  /*List<String> getFirstLastName(UserCredential credentials) {
    return [firstNameController.text.trim(), lastNameController.text.trim()];
  }*/

  void authException(BuildContext context, FirebaseAuthException e) {
    switch (e.code) {
      case ConstString.invalidVerificationCode:
        return showInSnackBar(context, ConstString.invalidVerificationMessage);
      case ConstString.invalidPhoneNumber:
        return showInSnackBar(
          context,
          ConstString.invalidPhoneFormat,
          title: ConstString.invalidPhoneMessage,
        );
      case ConstString.networkRequestFailed:
        return showInSnackBar(context, ConstString.checkNetworkConnection);
      case ConstString.userDisabled:
        return showInSnackBar(context, ConstString.accountDisabled);
      case ConstString.sessionExpired:
        return showInSnackBar(context, ConstString.sessionExpiredMessage);
      case ConstString.quotaExceed:
        return showInSnackBar(context, ConstString.quotaExceedMessage);
      case ConstString.tooManyRequest:
        return showInSnackBar(context, ConstString.tooManyRequestMessage);
      case ConstString.captchaCheckFailed:
        return showInSnackBar(context, ConstString.captchaFailedMessage);
      case ConstString.missingPhoneNumber:
        return showInSnackBar(context, ConstString.missingPhoneNumberMessage);
      default:
        return showInSnackBar(context, e.message);
    }
  }

  List<String> getNameFromEmail(String email) {
    List<String> parts = email.split('@');

    if (parts.length != 2) {
      return ['-', ''];
    }

    String username = parts[0];

    List<String> nameParts = username.split('.');

    if (nameParts.isEmpty) {
      return [
        capitalizeFirstLetter(username),
        generateRandomNumbers(),
      ];
    }

    String firstName = capitalizeFirstLetter(nameParts[0]);
    String lastName =
        nameParts.length > 1 ? capitalizeFirstLetter(nameParts.last) : '';

    return [firstName, lastName];
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }

  String generateRandomNumbers() {
    math.Random random = math.Random();
    return '${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}';
  }

  static Future<void> signOut() async {
    await NotificationService.instance.reGenerateFCMToken();
    AppStorage appStorage = AppStorage();
    appStorage.appLogout();
    await FirebaseAuth.instance.signOut();
    await Get.offAll(() => CountryPickScreen());
  }

  void openCountryPickerDialog(String countryCode) {
    var foundCountry = countryList.firstWhere(
            (country) => country.phoneCode == countryCode,
        orElse: null);
    if (foundCountry != null) {
      selectedCountry.value = foundCountry;
      selectedCountryCode.value = "+${foundCountry.phoneCode}";
      selectedCurrency.value = foundCountry.currencyCode ?? 'INR';
    }
  }
}

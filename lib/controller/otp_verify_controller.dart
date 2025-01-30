import 'dart:async';
import 'dart:developer';

import 'package:country_currency_pickers/country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/controller/user_repository.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/homescreen.dart';
import 'package:split/screen/otp_verify.dart';
import 'package:split/services/notification/notification_service.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/controller_ids.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';
import 'package:split/widgets/app_dialogue.dart';

class OPTVerifyController extends GetxController {
  TextEditingController otpController = TextEditingController();

  final String phoneNumber;

  OPTVerifyController(
      {required this.phoneNumber, required this.verificationId});

  RxString countryCode = "+91".obs;
  String verificationId = "";
  RxInt start = 30.obs;
  RxBool isOtpLoading = false.obs;
  RxBool isOtpSent = false.obs;
  RxBool resendButton = true.obs;

  var otpAttempts = 0.obs;

  AppStorage appStorage = AppStorage();

  var selectedCountry = Rx<Country?>(null);
  var selectedCountryCode = '+91'.obs;
  var selectedCurrency = 'INR'.obs;

  Rx<UserGender> selectedGender = UserGender.male.obs;

  User? user;
  Timer? timer;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthController authController = Get.find<AuthController>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
    update();
  }

  String getPhoneNumber() {
    if (countryCode.isEmpty) {
      return '';
    }
    String mPhoneNumber = phoneNumber.trim();
    return (countryCode + mPhoneNumber).replaceAll('+', '');
  }

  Future<void> actionVerifyPhone(BuildContext context,
      {required bool isLogin}) async {
    update();
    FocusManager.instance.primaryFocus?.unfocus();

    await verifyPhoneNumber(context, isLogin: isLogin);

    update();
  }

  Future<void> verifyPhoneNumber(BuildContext context,
      {bool second = false, bool isLogin = false}) async {
    isOtpSent = true.obs;
    update();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+${getPhoneNumber()}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          isOtpSent = false.obs;
          update();
          return _auth.signInWithCredential(credential).then((value) {
            showInSnackBar(context, ConstString.successLogin, isSuccess: true);
            return;
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          isOtpSent = false.obs;
          update();

          log("Verification error : ${exception.message}");
          // isLoading = false;
          update([ControllerIds.verifyButtonKey]);
          authException(context, exception);
        },
        codeSent:
            (String currentVerificationId, int? forceResendingToken) async {
          verificationId = currentVerificationId;
          isOtpSent = false.obs;
          update();
          log("$verificationId otp is sent ");

          showInSnackBar(context, ConstString.otpSent, isSuccess: true);

          start.value = 30;
          if (timer?.isActive != true) {
            startTimer();
          }

          if (!second) {
            Get.to(() => OtpVerifyScreen(
                phoneNumber: getPhoneNumber(), verificationId: verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isOtpSent = false.obs;
          update();

          this.verificationId = verificationId;
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

  Future<void> verifyOtp(BuildContext context, String OTP) async {
    if (otpController.text.isEmpty) {
      showInSnackBar(
        context,
        ConstString.enterOtp,
        title: ConstString.enterOtpMessage,
      );
      return;
    }
    isOtpLoading.value = true;
    update([ControllerIds.verifyButtonKey]);
    try {
      // showProgressDialogue(context);
      final UserCredential result;
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: OTP);

      result = await _auth.signInWithCredential(phoneAuthCredential);
      isOtpLoading.value = false;
      update([ControllerIds.verifyButtonKey]);

      isOtpLoading.value = true;
      update([ControllerIds.verifyButtonKey]);
      if (result.additionalUserInfo?.isNewUser ?? false) {
        log('data to check 2 ${getPhoneNumber()}');
        var gotUser = await _createUserInUserCollection(result,
            displayName: "" /*getUserName()*/);
        await appStorage.setUserData(gotUser);
        await NotificationService.instance.getTokenAndUpdateCurrentUser();
        await Get.offAll(() => HomeScreen());
        isOtpLoading.value = true;
        otpAttempts.value = 0;
        update([ControllerIds.verifyButtonKey]);
      } else {
        var gotUser = await _createUserInUserCollection(result,
            displayName: "" /*getUserName()*/);
        isOtpLoading.value = true;
        update([ControllerIds.verifyButtonKey]);

        await appStorage.setUserData(gotUser);
        await NotificationService.instance.getTokenAndUpdateCurrentUser();
        await Get.offAll(() => HomeScreen());
        otpAttempts.value = 0;
      }
      isOtpLoading.value = true;
      update([ControllerIds.verifyButtonKey]);
    } on FirebaseAuthException catch (e) {
      // Get.back();
      authException(context, e);
      isOtpLoading.value = false;
      update([ControllerIds.verifyButtonKey]);
    } catch (e) {
      // Get.back();
      isOtpLoading.value = false;
      update([ControllerIds.verifyButtonKey]);
    }
  }

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
      String? _mobileNo = phoneNumber.trim().replaceAll('+', '');
      int _countryCode =
          int.parse(authController.selectedCountryCode.replaceAll('+', ''));
      userModel = UserModel.newUser(
          id: credentials.user?.uid,
          // name: phoneNumber.trim(),
          name: "",
          profilePicture: credentials.user?.photoURL,
          countryCode: _countryCode,
          currencyCode: authController.selectedCurrency.value,
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
}

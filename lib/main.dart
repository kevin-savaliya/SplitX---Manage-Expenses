import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:split/controller/app_contact_services.dart';
import 'package:split/controller/auth_controller.dart';
import 'package:split/controller/expense_history_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/notification_history_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/firebase_options.dart';
import 'package:split/screen/splash_screen.dart';
import 'package:split/services/api_service.dart';
import 'package:split/theme/colors.dart';
import 'package:split/theme/colors_theme.dart';
import 'package:split/utils/app_storage.dart';
import 'package:split/utils/network_dependency.dart';
import 'package:uuid/uuid.dart';

import 'services/notification/notification_service.dart';

var uuid = const Uuid();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Permission.notification.isDenied.then((value) {
  //   if (value) {
  //     Permission.notification.request();
  //   }
  // });
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // final PendingDynamicLinkData? initialLink =
  //     await FirebaseDynamicLinks.instance.getInitialLink();
  //
  // // NotificationService.instance.start();
  //
  // await AppStorage().initStorage();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.black,
  //   statusBarColor: Colors.transparent,
  //   statusBarBrightness: Brightness.dark,
  //   statusBarIconBrightness: Brightness.dark,
  //   systemNavigationBarDividerColor: AppColors.lightGrey,
  //   systemNavigationBarIconBrightness: Brightness.light,
  // ));
  //
  // NetworkDependency.init();
  runApp(const MyApp());
}

Stream<ConnectivityResult> connectivityStream =
    Connectivity().onConnectivityChanged;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GetMaterialApp(
              key: navigatorKey,
              debugShowCheckedModeBanner: false,
              enableLog: true,
              initialRoute: '/',
              useInheritedMediaQuery: true,
              title: 'SplitX',
              theme: ThemeColor.mThemeData(context),
              darkTheme: ThemeColor.mThemeData(context, isDark: true),
              defaultTransition: Transition.cupertino,
              opaqueRoute: Get.isOpaqueRouteDefault,
              popGesture: Get.isPopGestureEnable,
              transitionDuration: const Duration(milliseconds: 500),
              defaultGlobalState: true,
              initialBinding: GlobalBindings(),
              themeMode: ThemeMode.light,
              home: const testApi()),
        );
      },
    );
  }
}

class testApi extends StatefulWidget {
  const testApi({super.key});

  @override
  State<testApi> createState() => _testApiState();
}

class _testApiState extends State<testApi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ApiService.signin();
        },
      ),
    );
  }
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => ExpenseHistoryController(), fenix: true);
    Get.put(() => UserController(), permanent: true);
    Get.put(() => AppContactServices(), permanent: true);
    Get.lazyPut(() => GroupController(), fenix: true);
  }
}

class NetworkErrorDialog extends StatelessWidget {
  const NetworkErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('No Internet Connection'),
      content:
          const Text('Please check your network connection and try again.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

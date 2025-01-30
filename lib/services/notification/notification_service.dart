import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:split/model/notification_data.dart';
import 'package:uuid/uuid.dart';

import 'notification_bloc.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
}

class NotificationService {
  final _random = Random();

  static String getUuid() {
    return const Uuid().v4();
  }

  static Future<String> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  static String serverKey =
      "AAAApQQyPQg:APA91bHaa4wUQ5yCSXyB7rmIMJtwqqqBiHdg8bf01_UDqp0a9794EMXUM9OXQ8LEI79w4pvRna-52ujOW3I5JEMoSP3xVd6wikwwpoOPWH055vIeHO4XURBaEnD8yynJQGB-L75mFRnv";

  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;
  bool _started = false;
  final List<Function> _onMessageCallbacks = [];
  String? _deviceToken;

  String? get deviceToken => _deviceToken;

  // ********************************************************* //
  // YOU HAVE TO CALL THIS FROM SOMEWHERE (May be main widget)
  // ********************************************************* //

  initInfo() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      AndroidInitializationSettings initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (payload) {});
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage(
          (message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
      }
    });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   log("::::::::::::onMessageOpenedApp:::::::::::::::::");
    //   if (message.notification != null) {
    //     log(message.notification.toString());
    //     if (message.data['type'] == "chat") {
    //       await FireStoreUtils.getUserProfile(
    //           message.data['senderId'] == FireStoreUtils.getCurrentUid() ? message.data['receiverId'] : message.data['senderId'])
    //           .then((value) async {
    //         if (value != null) {
    //           CustomerModel customerModel = value;
    //           Get.toNamed(Routes.CHAT_SCREEN, arguments: {"receiverCustomerModel": customerModel});
    //         } else {
    //           await FireStoreUtils.getHandymanProfile(
    //               message.data['senderId'] == FireStoreUtils.getCurrentUid() ? message.data['receiverId'] : message.data['senderId'])
    //               .then((value) {
    //             HandymanModel handymanModel = value!;
    //             Get.toNamed(Routes.CHAT_SCREEN, arguments: {"receiverHandymanModel": handymanModel});
    //           });
    //         }
    //       });
    //     } else if (message.data['type'] == "order") {
    //       BookingModel? bookingModel = await FireStoreUtils.getBooking(message.data['bookingId']);
    //       Get.toNamed(Routes.BOOKING_DETAIL_SCREEN, arguments: {"bookingModel": bookingModel});
    //     }
    //   }
    // });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("QuicklAI");
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        '0',
        'goRide-customer',
        description: 'Show QuickLAI Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: 'your channel Description',
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker');
      DarwinNotificationDetails darwinNotificationDetails =
          const DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(
          android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  //
  // void start() {
  //   if (!_started) {
  //     _integrateNotification();
  //     _refreshToken();
  //     _started = true;
  //   }
  // }
  //
  // void _integrateNotification() {
  //   _registerNotification();
  //   _initializeLocalNotification();
  // }
  //
  // Future<void> _registerNotification() async {
  //   _firebaseMessaging.requestPermission();
  //   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     log('A new onMessageOpenedApp event was published!');
  //     Map<String, dynamic> msg = {
  //       'data': message.data,
  //     };
  //     _performActionOnNotification(msg);
  //   });
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     log('Got a message whilst in the foreground!');
  //     if (message.notification != null) {
  //       if (Platform.isAndroid) {
  //         _showNotification(message);
  //       }
  //       log('Message also contained a notification: ${message.notification?.toMap()}');
  //     }
  //   });
  //
  //   _firebaseMessaging.onTokenRefresh.listen(_tokenRefresh, onError: _tokenRefreshFailure);
  // }
  //
  // void _showNotification(RemoteMessage message) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'SplitX',
  //     'New Notification',
  //     priority: Priority.high,
  //     ticker: body(message),
  //     importance: Importance.max,
  //     showWhen: true,
  //     enableVibration: true,
  //     playSound: true,
  //     enableLights: true,
  //     visibility: NotificationVisibility.public,
  //     icon: '@mipmap/ic_launcher',
  //   );
  //   DarwinNotificationDetails iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  //   NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //
  //   //Logger.write("message.bodyLocArgs = ${message.bodyLocArgs}");
  //   await _flutterLocalNotificationsPlugin.show(
  //     _random.nextInt(1000000),
  //     title(message),
  //     body(message),
  //     platformChannelSpecifics,
  //     payload: json.encode(
  //       message.data,
  //     ),
  //   );
  // }
  //
  // String title(RemoteMessage message) => message.notification?.title ?? "Medic";
  //
  // String body(RemoteMessage message) => message.notification?.body ?? "You have new notification";
  //
  // void _initializeLocalNotification() {
  //   AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher'); //@drawable/ic_notification
  //
  //   DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings();
  //   _flutterLocalNotificationsPlugin.initialize(
  //     InitializationSettings(
  //       android: androidInitializationSettings,
  //       iOS: iosInitializationSettings,
  //     ),
  //     onDidReceiveNotificationResponse: _onSelectLocalNotification,
  //   );
  // }
  //
  // Future _onSelectLocalNotification(NotificationResponse response) async {
  //   Map? data;
  //   if (response.payload != null) {
  //     data = json.decode(response.payload!);
  //   }
  //
  //   Map<String, dynamic> message = {
  //     "data": data,
  //   };
  //
  //   _performActionOnNotification(message);
  //   return null;
  // }
  //
  Future<void> getTokenAndUpdateCurrentUser() async {
    return _getFCMToken();
  }

  //
  Future<void> _refreshToken({bool isForLogout = false}) async {
    return Future.delayed(const Duration(milliseconds: 10)).then((value) {
      return _getFCMToken(isForLogout: isForLogout);
    });
  }

  Future<void> _getFCMToken({bool isForLogout = false}) {
    if (isForLogout) {
      return NotificationsBloc.instance.updateCurrentUserToken(null);
    }
    return _firebaseMessaging.getToken().then((token) async {
      log('fcm token: $token');
      _deviceToken = token;

      return NotificationsBloc.instance.updateCurrentUserToken(token);
    }, onError: _tokenRefreshFailure);
  }

  void initializeController() {
    // notificationsBloc ??= Get.find();
  }

  Future<void> reGenerateFCMToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _flutterLocalNotificationsPlugin.cancelAll();
      _deviceToken = null;
      await _refreshToken(isForLogout: true);
      log('Done', name: 'DELETED FCM TO DATABASE');
      return;
    } catch (e) {
      log(e.toString(), name: 'DELETED FCM TO DATABASE CATCH');
      return;
    }
  }

  //
  // void _tokenRefresh(String newToken) async {
  //   log('New Token : $newToken');
  //   _deviceToken = newToken;
  //   NotificationsBloc.instance.updateCurrentUserToken(newToken);
  //   // if (Utils.loggedInUserId != null) {
  //   //   DatabaseService(uid: Utils.loggedInUserId).updateUserFCMToken(newToken);
  //   // }
  // }
  //
  void _tokenRefreshFailure(error) {
    log("FCM token refresh failed with error $error");
  }

  // void _performActionOnNotification(Map<String, dynamic> message) {
  //   NotificationsBloc.instance.newNotification(message);
  //   // CollectionReference noteRef =
  //   //     FirebaseFirestore.instance.collection('notifications');
  //   // DocumentReference userNotRef = noteRef.doc(currentUser);
  //   //
  //   // UserNotification notificationData = UserNotification(
  //   //     id: message['data']['id'],
  //   //     title: message['notification']['title'],
  //   //     body: message['notification']['body'],
  //   //     datetime: DateTime.now());
  //   //
  //   // userNotRef.get().then((docSnap) {
  //   //   if (docSnap.exists) {
  //   //     userNotRef.update({
  //   //       'notifications': FieldValue.arrayUnion([notificationData.toMap()])
  //   //     });
  //   //   } else {
  //   //     userNotRef.set({
  //   //       'notifications': [notificationData.toMap()]
  //   //     });
  //   //   }
  //   // });
  // }
  //
  // void addOnMessageCallback(Function callback) {
  //   _onMessageCallbacks.add(callback);
  // }
  //
  // void removeOnMessageCallback(Function callback) {
  //   _onMessageCallbacks.remove(callback);
  // }
  //
  // Future<String?> getPayloadDetails() async {
  //   final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //   if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
  //     return notificationAppLaunchDetails!.notificationResponse?.payload;
  //   }
  //   return null;
  // }
  //
  // Future sendNotification() async {
  //   const String url = 'https://fcm.googleapis.com/fcm/send';
  //   // String? token = await _firebaseMessaging.getToken();
  //   if (true) {
  //     return Future(() => null);
  //   }
  //   String? token = await _firebaseMessaging.getToken();
  //   Map<String, dynamic> data = generateFCMPayload(tokens: []);
  //   final response = await http.post(Uri.parse(url),
  //       headers: <String, String>{HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "key=$serverKey"},
  //       body: json.encode(data));
  //
  //   print(response.body);
  // }
  //
  // Map<String, dynamic> generateFCMPayload({required List<String> tokens}) {
  //   return {
  //     "registration_ids": tokens,
  //     "priority": "high",
  //     "time_to_live": 40,
  //     "delay_while_idle": true,
  //     "content_available": true,
  //     "notification": {"title": "Sample Title", "body": "This is the sample message body", "sound": "default"},
  //     "data": {
  //       "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //       "message": "Hey someone has Added expense to the group",
  //       "groupId": ["0DLl1HhFrvDLfsGhelm6"],
  //       "userIds": ["E0OwYZbB7kb19ZFxYth0zEIRzIA3"],
  //       "createdAt": 1706333100000,
  //       "hasRead": false
  //     },
  //     "apns": {
  //       "headers": {"apns-priority": "10"},
  //       "payload": {
  //         "aps": {
  //           "alert": {"title": "Sample Title for iOS", "body": "This is the sample message body for iOS"},
  //           "badge": 1,
  //           "sound": "default"
  //         }
  //       }
  //     }
  //   };
  // }
  //
  // sendTestNotification() async {
  //   // var token = await _firebaseMessaging.getToken();
  //   // sendPushMessage(token);
  //   sendNotification();
  // }

  //
  // Future<void> sendPushMessage(String? _token) async {
  //   if (_token == null) {
  //     print('Unable to send FCM message, no token exists.');
  //     return;
  //   }
  //
  //   try {
  //     http.Response response = await http.post(
  //       Uri.parse('https://api.rnfirebase.io/messaging/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({
  //         'token': _token,
  //         'data': {
  //           'via': 'Cloud Messaging!!!',
  //           'title': 'Hello SpliX User!',
  //           'body': 'This notification was created via App!',
  //         },
  //         'notification': {
  //           'title': 'Hello SpliX User!',
  //           'body': 'This notification was created via App!',
  //         },
  //       }),
  //     );
  //     print('response: ${response.body}');
  //     print('FCM request for device sent!');
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // static sendMultipleNotifications({
  //   required String title,
  //   required String body,
  //   required String type,
  //   required List<String> tokens,
  //   required String groupId,
  //   List<String>? customerIdList,
  //   required String senderId,
  // }) async {
  //   NotificationData notificationModel = NotificationData();
  //   notificationModel.notificationId = getUuid();
  //   notificationModel.senderId = senderId;
  //   notificationModel.type = type;
  //   notificationModel.title = title;
  //   notificationModel.groupId = groupId;
  //   notificationModel.description = body;
  //   notificationModel.createdAt = DateTime.now().toString();
  //   notificationModel.customerId = customerIdList;
  //
  //   await FirebaseFirestore.instance
  //       .collection('notification')
  //       .doc(notificationModel.notificationId)
  //       .set(notificationModel.toJson())
  //       .then(
  //     (value) {
  //       print('notification set');
  //     },
  //   );
  //
  //   String myToken = await getToken();
  //   if (tokens.contains(myToken)) {
  //     tokens.removeWhere((element) => element == myToken);
  //   }
  //   http.Response response = await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverKey',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{'body': body, 'title': title},
  //         'priority': 'high',
  //         'data': notificationModel.toJson(),
  //         'registration_ids':
  //             tokens, // Use 'registration_ids' for multiple tokens
  //       },
  //     ),
  //   );
  //   print(response.body);
  // }

  // static sendOneNotification({
  //   required String title,
  //   required String body,
  //   required String type,
  //   required String token,
  //   required String groupId,
  //   required String? customerId,
  // }) async {
  //   NotificationData notificationModel = NotificationData();
  //   notificationModel.notificationId = getUuid();
  //   notificationModel.type = type;
  //   notificationModel.title = title;
  //   notificationModel.groupId = groupId;
  //   notificationModel.description = body;
  //   notificationModel.createdAt = DateTime.now().toString();
  //   notificationModel.customerId =customerId;
  //
  //       await FirebaseFirestore.instance.collection('notification').doc(notificationModel.notificationId).set(notificationModel.toJson()).then(
  //     (value) {
  //       print('notification set');
  //     },
  //   );
  //
  //   http.Response response = await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverKey',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{'body': body, 'title': title},
  //         'priority': 'high',
  //         'data': notificationModel.toJson(),
  //         'to': token
  //       },
  //     ),
  //   );
  //   log(response.body);
  // }
// static sendOneNotification({
//   required String title,
//   required String body,
//   required String type,
//   //required Map<String, dynamic> payload,
//   required String token,
//   required String groupId,
//   required String? payerId,
// }) async {
//   NotificationData notificationModel = NotificationData();
//
//   notificationModel.notificationId = getUuid();
//   notificationModel.type = type;
//   notificationModel.title = title;
//   notificationModel.groupId = groupId;
//   notificationModel.description = body;
//   notificationModel.payerId = payerId;
//   notificationModel.createdAt = DateTime.now().toString();
//
//   await FirebaseFirestore.instance.collection('notification').doc(notificationModel.notificationId).set(notificationModel.toJson()).then(
//     (value) {
//       print('notification set');
//     },
//   );
//
//   http.Response response = await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'key=${serverKey}',
//     },
//     body: jsonEncode(
//       <String, dynamic>{
//         'notification': <String, dynamic>{ 'body': body, 'title': title },
//         'priority': 'high',
//         'data': notificationModel.toJson(),
//         'to': token
//       },
//     ),
//   );
//   log(response.body);
// }
}

import 'dart:io';

import 'package:flutter/material.dart';



import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';

class FireBaseMessagingService  {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  BuildContext context;

  FireBaseMessagingService(this.context);

  String? type, slug;
  String? deviceToken;
  Future<FireBaseMessagingService> init() async {
    FirebaseMessaging.instance
        .requestPermission(sound: true, badge: true, alert: true);


    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            if (notificationResponse.payload != null) {

            }
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await fcmOnLaunchListeners();
    await fcmOnResumeListeners();
    await fcmOnMessageListeners();
    deviceToken = await setDeviceToken();
    return this;
  }

  Future fcmOnMessageListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Common.debugPrintApp(message.toString());
      Common.debugPrintApp(message.notification.toString());
      Common.debugPrintApp(message.data.toString());
      String image = "";
      if (message.data != null) {
        image = message.data['image'] ?? "";
      }
      if (message != null && message.notification != null) {
        generateSimpleNotification(
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            image,
            "", message.notification.hashCode);
      }

    });
  }

  Future fcmOnLaunchListeners() async {
    RemoteMessage? message =
    await FirebaseMessaging.instance.getInitialMessage();
    Common.debugPrintApp(message.toString());

    if (message != null) {
      Common.debugPrintApp(message.toString());
      Common.debugPrintApp(message!.notification.toString());
      Common.debugPrintApp(message!.data.toString());

      Navigator.pushNamed(context, Constants.dashboardRoute);
    }
  }
  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));

    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  Future fcmOnResumeListeners() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Common.debugPrintApp(message.toString());
      Common.debugPrintApp(message.notification.toString());
      String image = "";

      if (message.notification != null) {
        generateSimpleNotification(
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            image,
            "",
           message.notification.hashCode);
      }
    });
  }

  void _notificationsBackground(RemoteMessage message) {
    if (message.data['id'] == "App\\Notifications\\NewMessage") {
      _newMessageNotificationBackground(message);
    } else {
      _newBookingNotificationBackground(message);
    }
  }

  void _newBookingNotificationBackground(message) {}

  void _newMessageNotificationBackground(RemoteMessage message) {}
  Future<void> generateSimpleNotification(
      String title, String msg,String image, String type, int id) async {
    BigPictureStyleInformation? bigPictureStyleInformation;
    if (image != "") {
      var bigPicturePath = await _downloadAndSaveImage(
          Constants.imageUrl + image, image);

      bigPictureStyleInformation =
          BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
              contentTitle: title,
              htmlFormatContentTitle: true,
              summaryText: msg,
              htmlFormatSummaryText: true);
    }
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_notification_channel', 'High Importance Notifications',
        channelDescription: 'This is the travel in sync',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
        ticker: 'ticker');
    var iosDetail =const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosDetail);
    await flutterLocalNotificationsPlugin
        .show(id, title, msg, platformChannelSpecifics, payload: id.toString());
  }

  Future<String?> setDeviceToken() async {
    try{
      String? deviceToken = await FirebaseMessaging.instance.getToken(
       // vapidKey: "BIt05ptOxytl57lDNf79oNtKXDByZ0VPHzFz4NP6YmasSSDzOEAOZylBz8SC1DE4OUODbUsl-a8IG044MqPZphI"
      );
      Common.debugPrintApp(deviceToken);
      return deviceToken;
    }catch(e){
      Common.debugPrintApp(e);
    }
    return "";
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  Common.debugPrintApp('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    Common.debugPrintApp(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
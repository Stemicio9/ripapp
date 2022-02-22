
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/ui/common/SlideUpRoute.dart';
import 'package:ripapp/ui/home/user/MainScaffold.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:sprintf/sprintf.dart';
import 'Utils.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  //print("onBackgroundMessage: $message");
  //_showBigPictureNotification(message);
  return Future<void>.value();
}

class OneSignalHandler {

  static final OneSignalHandler _singleton = new OneSignalHandler._internal();

  static init() async {
    //INIT ONESIGNAL
    _initOneSignal();
  }

  factory OneSignalHandler() {
    init();
    return _singleton;
  }

  OneSignalHandler._internal();

  static void _goToNotificationsListPage() {
    Get.until(ModalRoute.withName('/'));
    Navigator.of(Get.context).push(
        SlideUpRoute(page: MainScaffold(currentPage: 1))
    );
  }
  
  static Future onSelectNotification(String payload) async {
   _goToNotificationsListPage();
  }

  static void _initOneSignal() async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init(Configuration.OneSignalAppID, iOSSettings: {OSiOSSettings.autoPrompt: true, OSiOSSettings.inAppLaunchUrl: false});
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    /*bool success = await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    if(Platform.isIOS && success != null && !success)
      return;*/
    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      //onMessage(notification);
      print("received");
      showNotification(notification.payload.title, notification.payload.body, _goToNotificationsListPage);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      onOpen(result.notification);
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

 /*   OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
      print("SUBSCRIPTION STATE CHANGED: ${emailChanges.jsonRepresentation()}");
    });*/


  /*  UserEntity user = await UserHandler().getUser();
    try {
      await OneSignal.shared.setEmail(email: user.email);
    }
    catch (e) {
      print(e.toString());
    }*/

    await OneSignal.shared.setSubscription(true);
    //Map<String, dynamic> res = await OneSignal.shared.setExternalUserId(user.accountid);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var playerId = status.subscriptionStatus.userId;
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    if(playerId != null) {
      print("playerId: " + playerId);
      _postPlayerId(playerId);
    }
  }

  static void onOpen(OSNotification notification) async {
/*    Map<String, dynamic> additionalData = notification.payload.additionalData;
    String title = notification.payload.title;
    String body = notification.payload.body;
    if (additionalData == null || additionalData.isEmpty) {
      Get.offAllNamed('/splash_screen');
      return;
    }
    String tableUuid = additionalData["table_uuid"];
    String notificationType = additionalData["notification_type"];*/

    /*if (ModalRoute.of(Get.context).settings.name == null || ModalRoute.of(Get.context).settings.name != "/main_scaffold")
      Get.offAllNamed('/splash_screen');*/
    _goToNotificationsListPage();
  }

  static void showNotification(title, body, onTap) async {
    Utils.showNotificationSnackBar(
      body,
      title: title,
      durationSeconds: 5,
      onTap: (GetBar snack) async {
        //snack.dismiss();
        if (onTap != null) onTap();
      },
    );
    return;
  }

  static void _postPlayerId(String playerId) async {
    dio.Dio d = Utils.buildDio();
    dio.Response res;
    try {
      res = await d.post(sprintf(Configuration.POST_PLAYER_ID, [playerId]));
    }
    on dio.DioError catch (e) {
      return;
    }
  }
}

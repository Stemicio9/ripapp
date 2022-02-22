import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';
import 'package:ripapp/ui/auth/LoginPage.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/common/FadeRoute.dart';
import 'package:ripapp/ui/home/admin/AdminMainScaffold.dart';
import 'package:ripapp/ui/home/user/MainScaffold.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

import 'ui/home/amministratore/AmministratoreScaffold.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  int SPLASH_SCREEN_TIME = 1500;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    HomeIndicator.hide();
    Firebase.initializeApp().then((value) {
      //FirebaseAuth.instance.signOut();
      Utils.checkServerOnline().then((value) {
        if(value == "under_maintenance") {
          Get.offAllNamed("/under_maintenance");
          return;
        }
        else if(value == "must_upgrade") {
          Get.offAllNamed("/must_upgrade");
          return;
        }
        UserHandler().getFirebaseUser().then((firebaseUser) async {
          print("IL FIREBASE USER: ");
          print(firebaseUser);
          Utils.setLanguageCookie(context);
          Utils.setLanguage(context);
          if(firebaseUser != null){
            UserStatus userStatus = await getUserStatus(firebaseUser.email);
            if(userStatus == UserStatus.notfound) {
              goToPage(LoginPage());
              return;
            }
            if(userStatus == UserStatus.admin) {
              bool success = await UserHandler().login(firebaseUser, context);
              if(success)
                goToPage(AmministratoreMainScaffold());
              return;
            }
            if(userStatus == UserStatus.agency) {
              bool success = await UserHandler().login(firebaseUser, context);
              if(success)
                goToPage(AdminMainScaffold());
              return;
            }
            if(userStatus == UserStatus.disabled) {
              Utils.showErrorSnackBar(MyLocalizations.of(context, "user_disabled"), context: context);
              return;
            }
            if(userStatus == UserStatus.active) {
              bool success = await UserHandler().login(firebaseUser, context);
              if(success){
                goToPage(MainScaffold());
              }
              else
                Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
              return;
            }

            goToPage(LoginPage());
            return;
          }
          else {
            goToPage(LoginPage());
          }
        });
      });
    });

  }

  void goToPage(Widget page) {
    Future.delayed(Duration(milliseconds: SPLASH_SCREEN_TIME)).whenComplete(() =>
        //Navigator.of(context).pushReplacementNamed(route)
        Navigator.of(context).pushReplacement(
            FadeRoute(page: page)
        )
    );

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      Scaffold(
        appBar: EmptyAppBar(),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Center(
              child: Image.asset("assets/logo_transparent.png", width: width * 0.6, fit: BoxFit.cover,)
            ),
           /* Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                MyLocalizations.of(context, "copyright"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 10.0,
                ),
              ),
            ),*/
          ],
        ),
      );
  }

  Future<UserStatus> getUserStatus(String email) async {
    UserStatus userStatus = await UserHandler().userStatus(email);
    while(userStatus == null){
      await Future.delayed(Duration(seconds: 3));
      userStatus = await UserHandler().userStatus(email);
    }

    return userStatus;
  }

}

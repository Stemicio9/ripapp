import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class LoadingPopupRouteLong extends PopupRoute {
  static LoadingPopupRouteLong instance;

  static Timer timer;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => "";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black38,
                Colors.black54,
                Colors.black38,
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
              width: 140.0,
              height: 140.0,
              decoration: new BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: new BorderRadius.all(new Radius.circular(10))),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: SpinKitDoubleBounce(
                      color: AppTheme.lightGrey,
                    ),
                  ),
                 /* message != null
                      ? Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 70.0),
                      child: Text(message, style: loadingTextStyle),
                    ),
                  )
                      : SizedBox()*/
                ],
              )),
        ),
      ],
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  static void show(BuildContext context) {
    if (instance != null)
      return;
    try {
      LoadingPopupRouteLong hud = LoadingPopupRouteLong();
      instance = hud;
      Navigator.push(context, hud);
      timer = Timer(Configuration.LOADING_TIMEOUT*8, () {
        if(instance != null)
          Utils.showWarningSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
        hide();
      });
    } catch (e) {
      instance = null;
    }
  }

  static Future<void> hide() async {
    if(instance != null){
      try {
        Navigator.removeRoute(Get.context, instance);
        instance = null;
      } catch (e) {
        instance = null;
      }
    }
  }

}
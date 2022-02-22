import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MustUpgradePage extends StatefulWidget {
  @override
  _MustUpgradePageState createState() => _MustUpgradePageState();
}

class _MustUpgradePageState extends State<MustUpgradePage> {

  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.system_update, size: 80, color: AppTheme.baseColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    MyLocalizations.of(context, "please_upgrade"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.baseColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 22.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: GestureDetector(
                  child: Center(
                      child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: AppTheme.baseColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      MyLocalizations.of(context, "click_here_update"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          //decoration: TextDecoration.underline,
                          fontSize: 20.0),
                    ),
                  )),
                  onTap: () async {
                    String url = isIOS ? await Utils.getAppLink("app_store_url") : await Utils.getAppLink("play_store_url");
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    MyLocalizations.of(context, "wait_update_rollout"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.normal,
                        //decoration: TextDecoration.underline,
                        fontSize: 14.0),
                  ),
                ),
              ),
             /* Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    MyLocalizations.of(context, "problems_updating"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.normal,
                        //decoration: TextDecoration.underline,
                        fontSize: 18.0),
                  ),
                ),
              ),*/
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(AppTheme.baseColor);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }
}

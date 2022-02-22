import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenancePage extends StatefulWidget {
  @override
  _MaintenancePageState createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {

  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.settings, size: 80, color: AppTheme.baseColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    MyLocalizations.of(context, "under_maintenance_title"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.baseColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 26.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    MyLocalizations.of(context, "under_maintenance_dscr"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0),
                  ),
                ),
              ),
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

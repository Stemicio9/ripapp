import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';

class PasswordChangedPage extends StatefulWidget {
  @override
  _PasswordChangedPageState createState() => _PasswordChangedPageState();
}

class _PasswordChangedPageState extends State<PasswordChangedPage> {
  Color statusBarColor;
  SystemUiOverlayStyle style;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(AppTheme.baseColor);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.baseColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Text(
              MyLocalizations.of(context, "password_changed"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: height * 0.05),
            Center(
                child: Image.asset("assets/password_changed.png", width: width * 0.5, fit: BoxFit.cover)
            ),
            SizedBox(height: height * 0.1),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "back"), AppTheme.baseColor, Colors.white, () {
                    Navigator.of(context).pop();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(statusBarColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

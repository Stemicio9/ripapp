import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';

class UserRegisteredPage extends StatefulWidget {
  @override
  _UserRegisteredPageState createState() => _UserRegisteredPageState();
}

class _UserRegisteredPageState extends State<UserRegisteredPage> {

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(AppTheme.baseColor);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Image.asset("assets/user_registered.png", width: width * 0.5, fit: BoxFit.cover)
            ),
            SizedBox(height: height * 0.05),
            Center(
              child: Text(
                MyLocalizations.of(context, "profile_active"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "go"), AppTheme.baseColor, Colors.white, () {
                    Navigator.of(context).popAndPushNamed(
                        "/main_scaffold"
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }

}

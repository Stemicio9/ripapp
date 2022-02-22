import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';
import 'package:ripapp/ui/auth/RecoverEmailSentPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class RecoverPasswordPage extends StatefulWidget {
  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  TextEditingController emailController = new TextEditingController();

  Color statusBarColor;
  SystemUiOverlayStyle style;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(Colors.white);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Text(
              MyLocalizations.of(context, "password_lost"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.baseColor,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 20),
            Text(
              MyLocalizations.of(context, "password_lost_dscr"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0),
              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                border: InputBorder.none,
                hintText: MyLocalizations.of(context, "email"),
                hintStyle: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              onEditingComplete: () => recoverPassword(),
            ),
            Divider(
              thickness: 0.5,
              color: AppTheme.baseColor,
            ),
            SizedBox(height: height * 0.1),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "recover"), Colors.white, AppTheme.baseColor, () {
                    recoverPassword();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void recoverPassword() async {
    if(emailController.text.isEmpty || !EmailValidator.validate(emailController.text)) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_valid_email"), context: context);
      return;
    }
    Utils.showCustomHud(context);
    bool exists = await UserHandler().userAlreadyExists(emailController.text);
    Utils.hideCustomHud(context);
    if (!exists) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "email_not_existing_register"), durationSeconds: 1, context: context);
      return;
    }

    await UserHandler().resetPassword(emailController.text);
    //Utils.showOkSnackBar(MyLocalizations.of(context, "email_sent"), durationSeconds: 5);
    Get.off(RecoverEmailSentPage());
  }

  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(statusBarColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

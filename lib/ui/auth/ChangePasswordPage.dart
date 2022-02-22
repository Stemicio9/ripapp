import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/ui/auth/PasswordChangedPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:tuple/tuple.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController newPasswordConfirmationController = new TextEditingController();

  FocusNode currentPasswordFocusNode = new FocusNode();
  FocusNode newPasswordFocusNode = new FocusNode();
  FocusNode newPasswordConfirmationFocusNode = new FocusNode();

  bool obscureCurrentPass = true;
  bool obscureNewPass = true;
  bool obscurePassConf = true;

  Color statusBarColor;
  SystemUiOverlayStyle style;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(Colors.white);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Text(
              MyLocalizations.of(context, "change_password"),
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
              controller: currentPasswordController,
              focusNode: currentPasswordFocusNode,
              obscureText: obscureCurrentPass,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0),
              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                border: InputBorder.none,
                hintText: MyLocalizations.of(context, "current_password"),
                hintStyle: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      obscureCurrentPass = !obscureCurrentPass;
                    });
                  },
                  child: Icon(
                    Icons.remove_red_eye, color: AppTheme.almostBlack, size: 20,
                  ),
                )
              ),
              onEditingComplete: () => newPasswordFocusNode,
            ),
            Divider(
              thickness: 0.5,
              color: AppTheme.baseColor,
            ),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              focusNode: newPasswordFocusNode,
              obscureText: obscureNewPass,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0),
              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                border: InputBorder.none,
                hintText: MyLocalizations.of(context, "new_password"),
                hintStyle: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      obscureNewPass = !obscureNewPass;
                    });
                  },
                  child: Icon(
                    Icons.remove_red_eye, color: AppTheme.almostBlack, size: 20,
                  ),
                )
              ),
              onEditingComplete: () => newPasswordConfirmationFocusNode,
            ),
            Divider(
              thickness: 0.5,
              color: AppTheme.baseColor,
            ),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordConfirmationController,
              focusNode: newPasswordConfirmationFocusNode,
              obscureText: obscurePassConf,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0),
              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                border: InputBorder.none,
                hintText: MyLocalizations.of(context, "repeat_password"),
                hintStyle: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      obscurePassConf = !obscurePassConf;
                    });
                  },
                  child: Icon(
                    Icons.remove_red_eye, color: AppTheme.almostBlack, size: 20,
                  ),
                )
              ),
              onEditingComplete: () => changePassword(),
            ),
            Divider(
              thickness: 0.5,
              color: AppTheme.baseColor,
            ),
            SizedBox(height: height * 0.1),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "save"), Colors.white, AppTheme.baseColor, () {
                    changePassword();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void changePassword() async {
    if(currentPasswordController.text.isEmpty
    ){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_current_password"), context: context);
      return;
    }
    if(newPasswordController.text.length < 8 /*||
        !passwordController.text.contains(new RegExp(r'[A-Z]')) ||
        !passwordController.text.contains(new RegExp(r'[-!$%^&*()_+|~=`{}\[\]:";<>?,.\/]'))*/
    ){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "password_too_short"), context: context);
      return;
    }
    if(!newPasswordController.text.contains(new RegExp(r'[0-9]'))
    ){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "password_must_contain_numbers"), context: context);
      return;
    }
    if(newPasswordController.text != newPasswordConfirmationController.text) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "password_confirmation_different"), context: context);
      return;
    }

    User user = await UserHandler().getFirebaseUser();
    Tuple2<bool, String> res = await UserHandler().signInWithEmailPassword(user.email, currentPasswordController.text, context);
    if(res == null || res.item1 == null) {
      Utils.hideCustomHud(context);
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    if(!res.item1) {
      Utils.hideCustomHud(context);
      if((res.item2 != null))
        Utils.showErrorSnackBar(res.item2, context: context);
      else
        Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    user = await UserHandler().getFirebaseUser();

    await user.updatePassword(newPasswordController.text);
    Get.off(PasswordChangedPage());
  }

  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(statusBarColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

}

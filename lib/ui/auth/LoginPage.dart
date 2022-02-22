import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';
import 'package:ripapp/ui/auth/RecoverPasswordPage.dart';
import 'package:ripapp/ui/auth/SignupPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:tuple/tuple.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode emailNode = new FocusNode();
  FocusNode passNode = new FocusNode();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      Scaffold(
        appBar: EmptyAppBar(),
        body:
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: height * 0.15),
                Center(
                    child: Image.asset("assets/logo_rect_transparent.png", width: width * 0.8, fit: BoxFit.cover)
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Login".toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.baseColor,
                    fontStyle:  FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  focusNode: emailNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                      border: InputBorder.none,
                      hintText: MyLocalizations.of(context, "email"),
                      hintStyle: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                  ),
                  onEditingComplete: () => passNode.requestFocus(),
                ),
                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: passNode,
                  obscureText: obscurePass,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                      border: InputBorder.none,
                      hintText: MyLocalizations.of(context, "password"),
                      hintStyle: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                        child: Icon(
                          Icons.remove_red_eye, color: AppTheme.almostBlack, size: 20,
                        ),
                      )
                  ),
                  onEditingComplete: () => login(),
                ),
                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.to(RecoverPasswordPage());
                    },
                    child: Text(
                      MyLocalizations.of(context, "recover"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: RoundedButton(MyLocalizations.of(context, "login"), Colors.white, AppTheme.baseColor, () {
                        login();
                      }),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      MyLocalizations.of(context, "no_account"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Get.to(SignupPage());
                      },
                      child: Text(
                        MyLocalizations.of(context, "signup"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      );
  }

  login() async {
    if(emailController.text.isEmpty || !EmailValidator.validate(emailController.text)) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_valid_email"), context: context);
      return;
    }
    if(passwordController.text.isEmpty){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_valid_pass"), context: context);
      return;
    }
    Utils.showCustomHud(context);
    Tuple2<bool, String> res = await UserHandler().signInWithEmailPassword(emailController.text, passwordController.text, context);

    print("LA RISPOSTA E' " + res.item1.toString());
    if(res == null || res.item1 == null) {
      Utils.hideCustomHud(context);
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    if(!res.item1) {
      Utils.hideCustomHud(context);
      if((res.item2 != null))
        Utils.showErrorSnackBar(res.item2);
      else
        Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    User user = await UserHandler().getFirebaseUser();
    if(user == null) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      Utils.hideCustomHud(context);
      return;
    }
    UserStatus userStatus = await UserHandler().userStatus(user.email);
    Utils.hideCustomHud(context);


    if(userStatus == UserStatus.admin) {
      bool success = await UserHandler().login(user, context);
      if(success)
        Navigator.of(context).popAndPushNamed(
            "/amministratore_main_scaffold"
        );

    }

    else if(userStatus == UserStatus.agency) {
      bool success = await UserHandler().login(user, context);
      if(success)
        Navigator.of(context).popAndPushNamed(
            "/admin_main_scaffold"
        );

    }
    else if(userStatus == UserStatus.active) {
      bool success = await UserHandler().login(user, context);
      if(success)
        Navigator.of(context).popAndPushNamed(
            "/main_scaffold"
        );
      else
        Navigator.of(context).popAndPushNamed(
            "/login"
        );
    }
    else if(userStatus == UserStatus.disabled) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "user_disabled"), context: context);
    }

    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
  }

}

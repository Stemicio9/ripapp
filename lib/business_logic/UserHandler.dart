import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ripapp/entity/AgencyEntity.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/CookiesManager.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/StorageManager.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:tuple/tuple.dart';

class UserHandler {
  static final UserHandler _singleton = new UserHandler._internal();

  factory UserHandler() {
    return _singleton;
  }

  UserHandler._internal();

  Future<auth.User> getFirebaseUser() async {
    return auth.FirebaseAuth.instance.currentUser;
  }

  Future<UserStatus> userStatus(String email) async {
    Dio dio = Utils.buildDio();
    try {
      Response r = (await dio.get(Configuration.USER_STATUS+"?email="+email));
      if(r.statusCode != 200 && r.statusCode != 201)
        return null;
      return UserStatus.values.firstWhere((element) => r.data == element.toString().split(".").last, orElse: null);
    } on DioError catch (e) {
      //print("ERROR GETTING TIME" + e.toString());
      //print(e.response?.data);
      //print(e.message);
      return null;
    }
  }

  Future<bool> updateUser(UserEntity user) async {
    Dio dio = Utils.buildDio();
    Response r;
    try {
      r = (await dio.put(Configuration.UPDATE_USER, data: json.encode(user.toJson())));
    } on DioError catch (e) {
      //print("ERROR GETTING TIME" + e.toString());
      //print(e.response?.data);
      //print(e.message);
      return false;
    }
    return (r.statusCode == 200);
  }

  Future<Tuple2<bool, String>> signInWithEmailPassword(String email, String password, BuildContext context) async {
    //Utils.showCustomHud(context);
    email = email.replaceAll(" ", "");
    String response;
 //   auth.User firebaseUser = await getFirebaseUser();
    try {
      auth.User firebaseUser = (await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password))?.user;
    }
    catch (err) {
      print("ERRORE = " + err.toString());
      switch (err.code) {
        case "user-not-found":
          response = MyLocalizations.of(context, "error_user_not_found");
          break;
        case "invalid-email":
          response = MyLocalizations.of(context, "error_invalid_email");
          break;
        case "wrong-password":
          response = MyLocalizations.of(context, "error_wrong_password");
          break;
        case "user-not_found":
          response = MyLocalizations.of(context, "error_user_not_found");
          break;
        case "user-disabled":
          response = MyLocalizations.of(context, "error_user_disabled");
          break;
        case "too-many-requests":
          response = MyLocalizations.of(context, "error_too_many_req");
          break;
        case "operation-not-allowed":
          response = MyLocalizations.of(context, "error_operation_not_allowed");
          break;
      }
      return Tuple2(false, response);
    }
    /*if (!(await isEmailVerified())) {
      Utils.hideCustomHud(context);
      return Tuple2(false, MyLocalizations.of(context, "email_not_verified"));
    }*/
    /*bool success = await finalizeLogin(context, firebaseUser);
    Utils.hideCustomHud(context);
    if(!success)
      return Tuple2(false, null);*/
    print("RISPONDO TRUE NULL");
    return Tuple2(true, null);
  }

  Future<Tuple2<bool, String>> signUpWithEmailPassword(String name, String email,
      String password, BuildContext context) async {
    email = email.replaceAll(" ", "");

    Utils.showCustomHud(context);
    String response;
    User user;
    try {
      user = (await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password))?.user;
    }
    catch (err) {
      switch (err.code) {
        case "invalid-email":
          response = ( MyLocalizations.of(context, "error_invalid_email"));
          break;
        case "weak-password":
          response = ( MyLocalizations.of(context, "error_weak_password"));
          break;
        case "email-already-in-use":
          response = MyLocalizations.of(context, "error_email_already_in_use");
          break;
        case "user-disabled":
          response = MyLocalizations.of(context, "error_user_disabled");
          break;
        case "too-many-requests":
          response = MyLocalizations.of(context, "error_too_many_req");
          break;
        case "operation-not-allowed":
          response = MyLocalizations.of(context, "error_operation_not_allowed");
          break;
      }
      return Tuple2(false, response);
    }
    if(user == null) {
      return Tuple2(false, response);
    }

    user.updateProfile(displayName: name);
    print("EMAIL UTENTE");
    print(user.email);

    bool goOn = false;
    if (!(await isEmailVerified())) {
      print("EMAIL NON VERIFICATA");
      user.sendEmailVerification();
      goOn = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) =>
          new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: new Text(MyLocalizations.of(context, "email_verification"), style: TextStyle(
                color: AppTheme.almostBlack
            ),),
            content: new Text(MyLocalizations.of(context, "verification_email_sent"), style: TextStyle(
                color: AppTheme.almostBlack
            ),),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          )
      );
    }
    return Tuple2(true, response);
  }


  Future<bool> isEmailVerified() async {
    //await reloadFirebaseUser();
    auth.User current = auth.FirebaseAuth.instance.currentUser;
    print("CURRENT USER");
    print(current.email);
    if (current == null)
      return null;
    List<String> providers = await getProviders(current.email);
    print("LA LISTA DEI PROVIDERS");
    print(providers);
    if (providers != null && providers.contains("facebook.com"))
      return true;

    await current?.reload();

    return current != null &&
        current.emailVerified;
  }


  Future<List<String>> getProviders(String email) async {
    List<String> providers = (await auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email));
    return  providers;
  }

  Future<bool> login(auth.User firebaseUser, BuildContext context) async {
    Dio dio = Utils.buildDio();
    String token;
    Response response;
    try {
      token = (await firebaseUser.getIdToken());
      Map<String, String> values = Map();
      values.putIfAbsent("idtoken", () => token);
      String fcmToken = await FirebaseMessaging.instance.getToken();
      values.putIfAbsent("instanceid", () => fcmToken);
      response = (await dio.post(
          Configuration.LOGIN,
          data: json.encode(values)
      )
      ); //.
      ////print(res);
      //dio.cookieJar.saveFromResponse(Uri.parse(Configuration.SERVER_URL), res.headers.);

      CookiesManager.clear();

      for (String cookieString in response.headers["set-cookie"])
        CookiesManager.addCookie(cookieString);

      if(context != null){
        Utils.setLanguageCookie(context);
        Utils.setLanguage(context);
      }


    } on DioError catch (e) {
      //print(e.message);
      //print(e.response?.request);
      return false;
    }
    return (response.statusCode == 200);
  }

  Future<bool> createUser(UserEntity userEntity) async {
    print("CREO UTENTE");
    Dio dio = Utils.buildDio();
    try {
      print("LA USER ENTITY E' :");
      print(userEntity.toJson());
      var jsonobj = userEntity.toJson();
      print("CHIAMO L'URL: " + Configuration.CREATE_USER);
      Response r = (await dio.post(Configuration.CREATE_USER, data: json.encode(jsonobj)));
      print(r.data);
      return r.statusCode == 201;
    } on DioError catch (e) {
      print("STAMPO L'ERRORE DA CREATEUSER");
      return false;
    }
  }

  void cancellaCookiePerAggiuntaAgenzia(){
    CookiesManager.deleteCookie("usertoconnect");
    CookiesManager.deleteCookie("agencyid");
    print("I COOKIE RIMASTI SONO: ");
    print(CookiesManager.getCookiesAsString());
  }

  Future<bool> createAgencyOperator(UserEntity userEntity) async {
    print("CREO OPERATORE AGENZIA");
    Dio dio = Utils.buildDio();
    try {
      var jsonobj = userEntity.toJson();
      print("CHIAMO L'URL: " + Configuration.CREATE_AGENCY_OPERATOR);
      Response r = (await dio.post(Configuration.CREATE_AGENCY_OPERATOR, data: json.encode(jsonobj)));
      for (String cookieString in r.headers["set-cookie"]) {
        if(cookieString.contains("usertoconnect")) {
          print("SONO IN CREA OPERATORE, AGGIUNGO IL COOKIE: ");
          print(cookieString);
          CookiesManager.addCookie(cookieString);
        }
      }

      print(r.data);
      return r.statusCode == 201;
    } on DioError catch (e) {
      print("STAMPO L'ERRORE DA CREATE AGENCY OPERATOR");
      return false;
    }
  }

  Future<bool> createAdmin(UserEntity userEntity) async {
    Dio dio = Utils.buildDio();
    try {
      Response r = (await dio.post(Configuration.CREATE_ADMIN, data: json.encode(userEntity.toJson())));

      return r.statusCode == 201;
    } on DioError catch (e) {

      print(e.error.toString());
      return false;
    }
  }

  Future<bool> createAgency(AgencyEntity agencyEntity) async {
    Dio dio = Utils.buildDio();
    try {
      Response r = (await dio.post(Configuration.CREATE_AGENCY, data: json.encode(agencyEntity.toJson())));

      for (String cookieString in r.headers["set-cookie"]) {
        if(cookieString.contains("agencyid")) {
          print("SONO IN CREA AGENZIA, AGGIUNGO IL COOKIE: ");
          print(cookieString);
          CookiesManager.addCookie(cookieString);
        }
      }

      return r.statusCode == 201;
    } on DioError catch (e) {

      print(e.error.toString());
      return false;
    }
  }

  Future<bool> connectAgencyToUser() async {
    Dio dio = Utils.buildDio();
    try {
      String agencyid = CookiesManager.getCookieVal("agencyid").value;
      String user = CookiesManager.getCookieVal("usertoconnect").value;
      print("agencyid = " + agencyid);
      print("accountid = " + user);
      var j = {
        "accountid" : user, 
        "agencyid" : agencyid
      };
      Response r = (await dio.post(Configuration.CONNECT_AGENCY_TO_USER, data: jsonEncode(j)));
      return r.statusCode == 201;
    } on DioError catch (e) {

      print(e.error.toString());
      return false;
    }
  }

  Future<UserEntity> getUser() async {
/*    return UserEntity(
      name: "mario",
      email: "maa",
      phone: "555",
      surname: "maaa",
      photourl: "https://images.unsplash.com/photo-1607502471906-162bb01c3789?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=675&q=80",
      prefix: "+56"
    );*/
    Dio dio = Utils.buildDio();
    try {
      Response r = (await dio.get(Configuration.GET_USER));
      if(r.statusCode != 200)
        return null;
      return UserEntity.fromJson(r.data);
    } on DioError catch (e) {
      //print("ERROR GETTING TIME" + e.toString());
      //print(e.response?.data);
      //print(e.message);
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    await auth.FirebaseAuth.instance.signOut();
    await reloadUser();

    CookiesManager.clear();
    try {
      Utils.setLanguageCookie(context);
    }
    catch (e) {
      print("ERROR");
    }
    await StorageManager.deleteValue("synchronized_time");
  }

  void reloadUser() async {
    auth.User u = await auth.FirebaseAuth.instance.currentUser;
    await u?.reload();
    u = await auth.FirebaseAuth.instance.currentUser;
  }

  Future<bool> userAlreadyExists(String email) async {
    return (await auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email)).length > 0;
  }

  Future<void> resetPassword(String email) async {
    await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<List<UserEntity>> autocompleteSearch(String phoneNumber) async {
    /*return [
      UserEntity(
        name: "mario",
        surname: "rossi",
        email: "mamam",
        phone: "123",
        photourl: "https://images.unsplash.com/photo-1606787504257-b22bc7a7f226?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"
      ),
      UserEntity(
          name: "mario",
          surname: "rossi",
          email: "mamam",
          photourl: "https://images.unsplash.com/photo-1606787504257-b22bc7a7f226?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"
      ),
    ];*/
    if(phoneNumber == null || phoneNumber.isEmpty || phoneNumber.length < 3)
      return [];

    Dio dio = Utils.buildDio();
    Response response;
    try {
      response = (await dio.get(
        Configuration.ADMIN_AUTOCOMPLETE_PHONE_NUMBER+"?query="+phoneNumber,
      ));
    }
    on DioError catch (e) {
      response =  e.response;
      return [];
    }
    List<dynamic> data = (response.data) as List;
    List<UserEntity> results = [];
    data.forEach( (value) {
      results.add(UserEntity.fromJson(value));
    });
    return results;
  }

  Future<bool> deleteUser() async {
    Dio dio = Utils.buildDio();
    Response response;
    try {
      response = await dio.delete(Configuration.UPDATE_USER);
    }
    on DioError catch (e) {
      response =  e.response;
      return false;
    }
    return response.statusCode == 200;
  }




}
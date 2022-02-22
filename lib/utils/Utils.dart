import 'dart:io';
import 'dart:ui';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/LoadingPopupRoute.dart';
import 'package:ripapp/ui/common/LoadingPopupRouteLong.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/CookiesManager.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static String language;

  static dio.Dio buildDio(){
    dio.Dio d = new dio.Dio();
    accettacertificato(d.httpClientAdapter);
    dio.BaseOptions options = new dio.BaseOptions(
        connectTimeout: 12000,
        receiveTimeout: 15000,
        headers: {
          "Content-Type": "application/json",
          "Cookie": CookiesManager.getCookiesAsString(),
          "app_version": Configuration.APP_VERSION,
        },
        contentType: ContentType.json.value,
        responseType: dio.ResponseType.json);
    d.options = options;
    d.interceptors.add(
        dio.InterceptorsWrapper(
            onError: (dio.DioError dioError) {
              print("STAMPO L'ERRORE DALL'INTERCEPTOR");
             print(dioError.message);
            })
    );
    return d;
  }

  static accettacertificato(DefaultHttpClientAdapter dioclientadapter){
    dioclientadapter.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port){return true;};
    };
  }

  static getCircularProgressIndicatorScaffold() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: getProgressIndicator()
    );
  }

  static getProgressIndicator() {
    return SpinKitDoubleBounce(
      color: AppTheme.baseColor,
      size: 35,
    );
  }

  static getLoadingIndicator(Color color) {
    return SpinKitThreeBounce(
      color: color ?? AppTheme.baseColor,
    );
  }

  static setLanguageCookie(BuildContext context){
    String langCookie = "lang=" + Localizations.localeOf(context).languageCode;
    if(langCookie == null)
      langCookie = "it";
    CookiesManager.addCookie(langCookie);
    //CookiesManager.addHeader("app_version="+Configuration.APP_VERSION);
  }

  static setLanguage(BuildContext context){
    language = Localizations.localeOf(context).languageCode;
    if(language == null)
      language = "it";
  }


  static void showWarningSnackBar(String message,
      {
        String title,
        int durationSeconds,
        double bottomDistance,
        Function onTap,
        bool isDismissible, BuildContext context
      }) {
    if (message == null) return;
    if(context != null) {
      FToast fToast = FToast();
      fToast.init(context);
      Widget toast = Container(
        //width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.amber,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Icon(Icons.check, color: Colors.white),
            SizedBox(
              width: 10.0,
            ),*/
            Text(
              message,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ],
        ),
      );
      fToast.showToast(
          child: toast,
          toastDuration: Duration(seconds: durationSeconds ?? 2),
          positionedToastBuilder: (context, child) {
            return Positioned(
              bottom: bottomDistance ?? 40,
              left: 20,
              right: 20,
              child: child,
            );
          });
    }
    else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: durationSeconds,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    /*Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.amber,
      margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      animationDuration: Duration(milliseconds: 400),
      duration:  Duration(seconds: durationSeconds ?? 2),
      barBlur: 10,
      borderRadius: 10,
      onTap: (Flushbar flushbar) {
        flushbar?.dismiss();
      },
    )..show(Get.context);*/
  }

  static void showInfoSnackBar(String message,
      {String title,
        int durationSeconds,
        double bottomDistance,
        Function onTap,
        bool isDismissible, BuildContext context
      }) {
    if (message == null) return;
    if(context != null) {
      FToast fToast = FToast();
      fToast.init(context);
      Widget toast = Container(
        //width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: AppTheme.grey,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Icon(Icons.check, color: Colors.white),
            SizedBox(
              width: 10.0,
            ),*/
            Text(
              message,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ],
        ),
      );
      fToast.showToast(
          child: toast,
          toastDuration: Duration(seconds: durationSeconds ?? 2),
          positionedToastBuilder: (context, child) {
            return Positioned(
              bottom: bottomDistance ?? 40,
              left: 20,
              right: 20,
              child: child,
            );
          });
    }
    else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: durationSeconds,
          backgroundColor: AppTheme.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
 /*   Flushbar(
      title: title,
      message: message,
      backgroundColor: AppTheme.grey,
      margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      animationDuration: Duration(milliseconds: 400),
      isDismissible: isDismissible ?? false,
      barBlur: 10,
      borderRadius: 10,
      duration: Duration(seconds: durationSeconds ?? 2),
      onTap: onTap ?? (Flushbar flushbar) {
        flushbar?.dismiss();
      },
    )..show(Get.context);*/
  }

  static void showOkSnackBar(String message,
      {
        String title,
        int durationSeconds,
        double bottomDistance,
        Function onTap,
        bool isDismissible, BuildContext context
      }) {
    if (message == null) return;
    if(context != null) {
      FToast fToast = FToast();
      fToast.init(context);
      Widget toast = Container(
        //width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.green,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Icon(Icons.check, color: Colors.white),
            SizedBox(
              width: 10.0,
            ),*/
            Text(
              message,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ],
        ),
      );
      fToast.showToast(
          child: toast,
          toastDuration: Duration(seconds: durationSeconds ?? 2),
          positionedToastBuilder: (context, child) {
            return Positioned(
              bottom: bottomDistance ?? 40,
              left: 20,
              right: 20,
              child: child,
            );
          });
    }
    else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: durationSeconds,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    }
    /*Flushbar(
      title:  title,
      message: message,
      backgroundColor: Colors.green,
      margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      animationDuration: Duration(milliseconds: 400),
      isDismissible: isDismissible ?? false,
      barBlur: 10,
      borderRadius: 10,
      duration:  Duration(seconds: durationSeconds ?? 2),
      onTap: onTap ?? (Flushbar flushbar) {
        flushbar?.dismiss();
      },
    )..show(Get.context);*/
  }

  static void unfocusTextField(BuildContext context) {
    /*FocusScopeNode focus = FocusScope.of(context);
    if(!focus.hasPrimaryFocus)
      focus.unfocus();*/
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void showCustomHud(BuildContext context) {
    LoadingPopupRoute.show(context);
  }

  static void hideCustomHud(BuildContext context) {
    LoadingPopupRoute.hide();
  }

  static void showCustomHudLong(BuildContext context) {
    LoadingPopupRouteLong.show(context);
  }

  static void hideCustomHudLong(BuildContext context) {
    LoadingPopupRouteLong.hide();
  }

  static void showNotificationSnackBar(String message, {String title, int durationSeconds, SnackPosition position, Function onTap, bool isDismissible}) {
    if(message == null)
      return;

    Get.snackbar(
        title,
        message,
        backgroundColor: AppTheme.lightGrey,
        colorText: AppTheme.baseColor,
        snackPosition: position ?? SnackPosition.TOP,
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        barBlur: 10,
        onTap: onTap,
        duration: Duration(seconds: durationSeconds),
        isDismissible: isDismissible
    );
    return;
  }

  static void showErrorSnackBar(
      String message, {
      String title,
      int durationSeconds,
      double bottomDistance,
      Function onTap,
      bool isDismissible, BuildContext context}) {
    if(message == null)
      return;

    showWarningSnackBar(message, title: title, durationSeconds: durationSeconds, context: context);
    return;
    /*Get.snackbar(
      title ?? MyLocalizations.of(Get.context, "snackbar_error"),
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20),
      barBlur: 10
    );
    return;*/

    /*showFlash(
      context: context,
      duration: Duration(seconds: durationSeconds ?? 2),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          barrierColor: Colors.green,
          barrierBlur: 10,
          backgroundColor: TheTableTheme.baseColor,
          boxShadows: [BoxShadow(blurRadius: 4)],
          borderRadius: BorderRadius.circular(8.0),
          borderColor: TheTableTheme.baseColor,
          position: FlashPosition.center,
          alignment:  Alignment(0, 0.95),
          enableDrag: false,
          onTap: () => controller.dismiss(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Text(message),
            ),
          ),
        );
      },
    );*/
  }

  static Future<File> pickImageFromGallery(BuildContext context) async {
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if(pickedFile == null)
      return null;
    File imageFile = File(pickedFile.path);
    imageFile = await cropImage(imageFile, context);
    return imageFile;
  }

  static Future<File> cropImage(File imageFile, BuildContext context) async {
    if(imageFile == null)
      return null;
    AndroidUiSettings androidUiSettings = AndroidUiSettings(
      toolbarColor: AppTheme.baseColor,
      statusBarColor: AppTheme.baseColor,
      toolbarWidgetColor: Colors.white

    );
    IOSUiSettings iosUiSettings = IOSUiSettings(
      cancelButtonTitle: MyLocalizations.of(context, "cancel"),
      doneButtonTitle: MyLocalizations.of(context, "done"),

    );
    File croppedFile = await ImageCropper.cropImage(
      cropStyle: CropStyle.circle,
      androidUiSettings: androidUiSettings,
      iosUiSettings: iosUiSettings,
      sourcePath: imageFile.path,
      /*ratioX: 0.8,
      ratioY: 1.0,*/
      maxWidth: 2048,
      maxHeight: 1024,
    );
    return croppedFile;
  }


  static Widget getLinearScaleTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return ScaleTransition(
      scale: new Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.linear),
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.linear),
        ),
        child: child,
      ),
    );
  }

  static Future<bool> showDialogWithoutContext(
      String title, String message, String action1, String action2) async {
    bool goOn = false;
    goOn = await Get.dialog(
      AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(title),
          content: new Text(message),
          actions: [
            action1 != null
                ? FlatButton(
              child: new Text(action1),
              onPressed: () {
                Get.back(result: false);
              },
            )
                : null,
            action2 != null
                ? FlatButton(
              child: new Text(action2),
              onPressed: () {
                Get.back(result: true);
              },
            )
                : null,
          ]),
      barrierDismissible: false,
    );
    return goOn ?? false;
  }

  static void showSimplePopupMessage(
      BuildContext context, String title, String message) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            title,
            style: TextStyle(color: AppTheme.almostBlack),
          ),
          content: Text(
            message,
            style: TextStyle(color: AppTheme.almostBlack),
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<String> savePhotoToFirebase(
      String referenceName, String name, File imageFile) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(referenceName)
        .child(name.toLowerCase() + ".jpg");
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
    while(storageTaskSnapshot.state == TaskState.running) {
      await Future.delayed(Duration(seconds: 2));
      storageTaskSnapshot = await uploadTask.snapshot;
    }
    if(storageTaskSnapshot.state == TaskState.canceled || storageTaskSnapshot.state == TaskState.paused
        || storageTaskSnapshot.state == TaskState.error)
      return null;
    String photoUrl = await ref.getDownloadURL();
    return photoUrl;
  }

  static openMap(double latitude, double longitude,
      {String address}) async {
    String googleUrl;
    if (address != null)
      googleUrl = 'https://www.google.com/maps/search/?api=1&query=' +
          address;
    else
      googleUrl =
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  }

  static Future<File> pickFileFromStorage(BuildContext context) async {
    if(! await Permission.storage.isGranted){
      Map<Permission, PermissionStatus> permissions = await [Permission.storage].request();
      if(permissions[Permission.storage].isDenied) {
        return null;
      }
    }
    FilePickerResult result = await FilePicker.platform.pickFiles(allowedExtensions: ['pdf',/* 'pages', 'doc', 'docx'*/], type: FileType.custom, onFileLoading: (loadingStatus) {
      Utils.showWarningSnackBar(loadingStatus.toString());
    }, withData: true);
    if(result == null)
      return null;
    List<File> files = result.paths.map((path) => File(path)).toList();
    if(files == null || files.isEmpty)
      return null;
    return files.first;
  }

  static Future<bool> showYesNoDialog(
      BuildContext context, String title, String message) async {
    bool goOn = false;
    goOn = await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(MyLocalizations.of(context, "no")),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text(MyLocalizations.of(context, "yes")),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    );
    return goOn ?? false;
  }

  static Future<String> showInsertPasswordDialog(BuildContext context) async {
    String pass = await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _passwordController = new TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(MyLocalizations.of(context, "insert_password")),
          content: Column(
            children: <Widget>[
              Text(MyLocalizations.of(context, "insert_password")),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: TextField(
                  controller: _passwordController,
                  //requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
                  //initialValue: user.email,
                  //onChanged: (value) => name = value,
                  //onSaved: (value) => name = value,
                  maxLines: 1,
                  //maxLength: 20,
                  maxLength: 20,
                  //maxLines: 2,
                  style: TextStyle(
                      color: AppTheme.baseColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                    counterStyle: TextStyle(
                        color: AppTheme.baseColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 10.0),
                    hintText: MyLocalizations.of(context, "insert_password"),
                    hintStyle: TextStyle(
                        color: AppTheme.baseColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(_passwordController.text);
              },
            ),
          ],
        );
      },
    );
    return pass;
  }

  static Future<String> checkServerOnline() async {
    dio.Dio d = buildDio();
    dio.Response response;
    try {
      response = (await d.get(Configuration.GET_SERVER_VERSION));
    } on dio.DioError catch (e) {
      response = e.response;
    }
    print("LA RISPOSTA DEL SERVER ");
    print(response);
    if(response == null || (response.data != "active" && response.data != "under_maintenance" && response.data != "must_upgrade"))
      return "under_maintenance";
    return (response != null ? response.data : "under_maintenance");
  }

  static Future<String> getAppLink(String key) async {
    final FirebaseApp app = await Firebase.initializeApp();
    final DatabaseReference db = FirebaseDatabase(app: app).reference();
    var d = await db.child("app_links").child(key).once();
    return d.value;
  }

}
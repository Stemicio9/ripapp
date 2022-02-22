import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ripapp/business_logic/ContactsManager.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/home/user/CityDemisesPage.dart';
import 'package:ripapp/ui/home/user/MyDefunctsPage.dart';
import 'package:ripapp/ui/home/user/NotificationsPage.dart';
import 'package:ripapp/ui/home/user/ProfilePage.dart';
import 'package:ripapp/ui/home/user/SendContactsToAgencyPage.dart';
import 'package:ripapp/ui/home/user/TelephoneBookPage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/OneSignalHandler.dart';
import 'package:ripapp/utils/StorageManager.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScaffold extends StatefulWidget {
  int currentPage;
  OneSignalHandler notificationHandler;

  MainScaffold({this.currentPage});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with WidgetsBindingObserver {
  int _currentPage = 4;
  PageController _pageController;
  List<Widget> pages = [TelephoneBookPage(), NotificationsPage(), ProfilePage(), CityDemisesPage(), MyDefunctsPage()];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        widget.notificationHandler = new OneSignalHandler();
      });

      _showPolicyDialog().then((accepted) {
        if(accepted)
          StorageManager.readValue("synchronized_time").then((value) async {
            if(this.mounted) {
              DateTime lastSync = value != null ?  DateTime.parse(value) : null;
              if (value == null || DateTime.now().difference(lastSync).inDays >= Configuration.TELEPHONE_BOOK_UPDATE_INTERVAL_DAYS) {
                bool granted = await _requestPermissions();
                if (granted) {
                  _synchronizeContacts();
                }
                else
                  Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
              }
            }
          });
      });
    });
    if(widget.currentPage != null)
      _currentPage = widget.currentPage;
    FlutterStatusbarcolor.setStatusBarColor(AppTheme.baseColor);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _pageController = PageController(initialPage: _currentPage, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: AppTheme.baseColor,
        appBar: EmptyAppBar(),
        bottomNavigationBar: _buildBottomNavBar(),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 5,left: 10, right: 10),
                color: AppTheme.baseColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo_rect_transparent.png", color: Colors.white, width: width * 0.5, fit: BoxFit.cover),
                    _buildMoreButton()
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: pages
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildMoreButton() {
    return PopupMenuButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onSelected: (value) {
          switch (value) {
            case "logout":
              {
                _logout();
                break;
              }
            case "terms_and_cond":
              {
                _showTermsAndConditions();
                break;
              }
            case "privacy_policy":
              {
                _showPrivacyPolicy();
                break;
              }
            case "send_contacts_to_agency":
              {
                _sendContactsToAgency();
                break;
              }
            case "share":
              {
                _share();
                break;
              }
          }
        },
        itemBuilder: (context) {
          return
            [
              PopupMenuItem<String>(
                value: "logout",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.exit_to_app_rounded, size: 20, color: AppTheme.baseColor),
                    SizedBox(width: 20),
                    Text(
                      MyLocalizations.of(context, "logout"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "terms_and_cond",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 20, color: AppTheme.almostBlack),
                    SizedBox(width: 20),
                    Text(
                      MyLocalizations.of(context, "terms_and_cond"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "privacy_policy",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.almostBlack),
                    SizedBox(width: 20),
                    Text(
                      MyLocalizations.of(context, "privacy_policy"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] + (_pageController.page == 0 ? [
              PopupMenuItem<String>(
                value: "send_contacts_to_agency",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.share, size: 20, color: AppTheme.almostBlack),
                    SizedBox(width: 20),
                    Text(
                      MyLocalizations.of(context, "send_contacts_to_agency"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] : []) + [
              PopupMenuItem<String>(
                value: "share",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.share, size: 20, color: AppTheme.almostBlack),
                    SizedBox(width: 20),
                    Text(
                      MyLocalizations.of(context, "share"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            ];
        },
        icon: Icon(
          Icons.more_vert,
          size: 30,
          color: Colors.white,
        ));
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      elevation: 5,
      child: SizedBox(
        height: 70.0,
        child: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildChildren()
          ),
        ),
      ),
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      color: Colors.white,
    );
  }

  _buildChildren() {
    var builder = [
      _buildTab("assets/bottom_nav_bar/telephone_book.png", MyLocalizations.of(context, "telephone_book"), 0)
    ];
    builder.add(_buildTab("assets/bottom_nav_bar/notifications.png", MyLocalizations.of(context, "notifications"), 1));
    builder.add(_buildTab("assets/bottom_nav_bar/profile.png", MyLocalizations.of(context, "profile"), 2));
    builder.add(_buildTab("assets/bottom_nav_bar/demises.png", MyLocalizations.of(context, "demises"), 3));
    builder.add(_buildTab("assets/bottom_nav_bar/defuncts.png", MyLocalizations.of(context, "my_defuncts_newline"), 4));
    return builder;
  }

  Widget _buildTab(String iconName, String text, int index) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        width: width / 5,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(iconName, color: _currentPage == index ? AppTheme.baseColor : Colors.grey, width: 25, height: 25,),
            SizedBox(height: index != 3 &&  index != 4 ? 10 : 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _currentPage == index ? AppTheme.baseColor : Colors.grey,
                  fontWeight: _currentPage == index ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12
              ),
            )
          ],
        ),
      ),
      onTap: () {
        setCurrentTab(index);
      },
    );
  }

  void setCurrentTab(int index) {
    HapticFeedback.mediumImpact();
    _currentPage = index;
    _pageController.jumpToPage(
      index,
      /*duration: Duration(milliseconds: 400),
        curve: Curves.decelerate*/
    );
    setState(() {});
  }

  void _showTermsAndConditions() async {
    String link = await Utils.getAppLink("terms_and_conditions");
    if (await canLaunch(link))
      await launch(link);
  }

  void _showPrivacyPolicy() async {
    String link = await Utils.getAppLink("privacy_policy");
    if (await canLaunch(link))
      await launch(link);
  }

  void _sendContactsToAgency() async {
    bool granted = await _requestPermissions();
    if(granted) {
      Get.to(SendContactsToAgencyPage());
    }
    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
  }

  void _share() async {
    String downloadLink = await Utils.getAppLink("unique_download_url");
    if(downloadLink != null)
      Share.share(downloadLink, subject: MyLocalizations.of(context, "download_claim"));
  }

  void _logout() async {
    Utils.showCustomHud(context);
    await UserHandler().logout(context);
    Utils.hideCustomHud(context);
    Get.offAllNamed("/splash_screen");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      return true;
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
    ].request();
    return (statuses[Permission.contacts].isGranted);

  }

  void _synchronizeContacts() async {
    //Utils.showOkSnackBar(MyLocalizations.of(context, "syncing_contacts"), context: context);
    List<Contact> contacts;
    try {
      contacts = await FlutterContacts.getContacts(
          withProperties: true
      );
    }
    catch (e) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
      return;
    }
    bool success = await ContactsManager().synchronizeContacts(contacts);
    var now = DateTime.now();
    if(success) {
      //Utils.showOkSnackBar(MyLocalizations.of(context, "telephone_book_synced"), context: context);
      await StorageManager.storeValue("synchronized_time", now.toString());
    }
    //else Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);

  }

  Future<bool> _showPolicyDialog() async {
    bool alreadyAccepted = await StorageManager.readBoolValue("accepted_policy");
    if(alreadyAccepted != null && alreadyAccepted)
      return true;
    String privacyUrl = await Utils.getAppLink("privacy_policy");
    bool accepted = await showDialog(
        barrierDismissible: false,
        context: Get.context,
        builder: (_) =>
        new AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: new Text(MyLocalizations.of(Get.context, "popup_text_title"), style: TextStyle(
              color: AppTheme.almostBlack
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MyLocalizations.of(Get.context, "popup_text_dscr"),
                style: TextStyle(
                  color: AppTheme.almostBlack
              ),),
              RichText(
        text: TextSpan(
            text: '',
            style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black, fontSize: 18),
            children: <TextSpan>[
              TextSpan(text: MyLocalizations.of(context, "privacy_policy"),
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueAccent, fontSize: 16),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch(privacyUrl))
                        await launch(privacyUrl);
                    }
              )
            ]
            ),
          )
            ],
          ),
          actions: <Widget> [
            new FlatButton(
              child: new Text(MyLocalizations.of(Get.context, "refuse")),
              onPressed: () {
                Navigator.of(Get.context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text(MyLocalizations.of(Get.context, "accept")),
              onPressed: () {
                Navigator.of(Get.context).pop(true);
              },
            ),
          ],
        )
    );
    StorageManager.storeBoolValue("accepted_policy", accepted);
    if(!accepted)
      exit(0);
    return accepted;
  }
}

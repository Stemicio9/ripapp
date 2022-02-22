


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/home/amministratore/AmministratoreMainPage.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AmministratoreMainScaffold extends StatefulWidget {
  int currentPage;

  AmministratoreMainScaffold({this.currentPage});

  @override
  _AmministratoreMainScaffoldState createState() => _AmministratoreMainScaffoldState();
}

class _AmministratoreMainScaffoldState extends State<AmministratoreMainScaffold> {

  int _currentPage = 0;
  PageController _pageController;
  List<Widget> pages = [AmministratoreMainPage()];


  @override
  void initState() {
    super.initState();
    if(widget.currentPage != null)
      _currentPage = widget.currentPage;
    FlutterStatusbarcolor.setStatusBarColor(AppTheme.baseColor);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _pageController = PageController(initialPage: 0, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppTheme.baseColor,
      appBar: EmptyAppBar(),
      //bottomNavigationBar: _buildBottomNavBar(),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 5, left: 10, right: 10),
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
            SizedBox(height: 20,),
            Expanded(
              child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: pages
              ),
            ),
          ],
        ),
      ),
    );
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
      _buildTab("assets/bottom_nav_bar/demises.png", MyLocalizations.of(context, "demises"), 0)
    ];
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
            SizedBox(height: index != 3 ? 10 : 5),
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
            ];
        },
        icon: Icon(
          Icons.more_vert,
          size: 30,
          color: Colors.white,
        ));
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

  void _logout() async {
    Utils.showCustomHud(context);
    await UserHandler().logout(context);
    Utils.hideCustomHud(context);
    Get.offAllNamed("/splash_screen");
  }

}
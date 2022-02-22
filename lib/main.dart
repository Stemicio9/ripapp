import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ripapp/SplashScreen.dart';
import 'package:ripapp/ui/auth/LoginPage.dart';
import 'package:ripapp/ui/auth/UserRegisteredPage.dart';
import 'package:ripapp/ui/common/MaintenancePage.dart';
import 'package:ripapp/ui/common/MustUpgradePage.dart';
import 'package:ripapp/ui/home/admin/AdminMainScaffold.dart';
import 'package:ripapp/ui/home/amministratore/AmministratoreScaffold.dart';
import 'package:ripapp/ui/home/user/MainScaffold.dart';
import 'package:ripapp/utils/MyLocalizationDelegate.dart';

void main() {
  ErrorWidget.builder = (errorDetails) {
    return Container(
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Ops, something went wrong! Please retry.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,

                ),
              ),
              Image.asset("assets/error_loading.png", height: 100.0,)
            ],
          )
      ),
    );
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

    static var routes = <String, WidgetBuilder>{
      '/main_scaffold': (BuildContext context) => new MainScaffold(),
      '/admin_main_scaffold': (BuildContext context) => new AdminMainScaffold(),
      '/amministratore_main_scaffold': (BuildContext context) => new AmministratoreMainScaffold(),
      '/splash_screen': (BuildContext context) => new SplashScreen(),
      '/login': (BuildContext context) => new LoginPage(),
      '/user_registered': (BuildContext context) => new UserRegisteredPage(),
      '/must_upgrade': (BuildContext context) => new MustUpgradePage(),
      '/under_maintenance': (BuildContext context) => new MaintenancePage(),
    };

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return GetMaterialApp(
        title: 'RipApp',
        enableLog: false,
        defaultTransition: Transition.cupertino,
        opaqueRoute: Get.isOpaqueRouteDefault,
        popGesture: Get.isPopGestureEnable,
/*      transitionDuration: Get.defaultDurationTransition,
      defaultGlobalState: Get.defaultGlobalState,*/
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.cyan[600],
          //,
          brightness: Brightness.light,
          /*textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),*/
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
          /*pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),*/
        ),

        routes: routes,
        localizationsDelegates: [
          MyLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FallbackCupertinoLocalisationsDelegate()
        ],
        supportedLocales: [
          const Locale('it', 'IT'), // Italian
          //const Locale('en', 'US'), // English
          // ... other locales the app supports
        ],
        home: SplashScreen(),
      );
    }

}

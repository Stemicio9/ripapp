import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

class PhotoPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const PhotoPage(this.imageProvider);

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {

  Color statusBarColor;
  SystemUiOverlayStyle style;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(Colors.black);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
            child:
            Container(
                margin: EdgeInsets.only(bottom: height * 0.1),
                color: Colors.black,
                width: width,
                height: height,
                child:
                //Image(image: imageProvider,)
                Material(
                    color: Colors.transparent,
                    child: ExtendedImage(
                      image: widget.imageProvider,
                      fit: BoxFit.fitWidth,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) => GestureConfig(
                          minScale: 1.0,
                          animationMinScale: 0.7,
                          maxScale: 3.0,
                          animationMaxScale: 3.5,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: false
                      ),
                    ))
            )
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


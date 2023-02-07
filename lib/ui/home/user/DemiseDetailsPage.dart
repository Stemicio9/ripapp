import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:geocode/geocode.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ripapp/business_logic/DemisesManager.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/Kinship.dart';
import 'package:ripapp/entity/RelativeEntity.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/PhotoPage.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/ui/home/admin/AdminEditDemisePage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DemiseDetailsPage extends StatefulWidget {
  final DemiseEntity demiseEntity;

  DemiseDetailsPage(this.demiseEntity);

  @override
  _DemiseDetailsPageState createState() => _DemiseDetailsPageState();
}

class _DemiseDetailsPageState extends State<DemiseDetailsPage> {
  Color statusBarColor;
  SystemUiOverlayStyle style;

  UserEntity userEntity;


  DemiseEntity _demiseEntity;

  @override
  void initState() {
    super.initState();
    this._demiseEntity = DemiseEntity.from(widget.demiseEntity);
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(Colors.white);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });

    UserHandler().getUser().then((value) {
      if(value != null && this.mounted)
        setState(() {
          userEntity = value;
        });
    });
  }


 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
   // this._demiseEntity = widget.demiseEntity;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.baseColor),
        actionsIconTheme: IconThemeData(color: AppTheme.baseColor),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10.0, left: 20, right: 20),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                MyLocalizations.of(context, "demise_details"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.baseColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                if (_demiseEntity.photourl != null)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhotoPage(NetworkImage(_demiseEntity.photourl))),
                  );
              },
              child: Container(
                width: width * 0.5,
                height: width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                  border: _demiseEntity.photourl == null ? Border.all(color: AppTheme.almostBlack, width: 2) : null,
                  image: _demiseEntity.photourl != null ?
                  DecorationImage(
                    image: CachedNetworkImageProvider(_demiseEntity.photourl),
                    fit: BoxFit.contain,
                  )
                      : null,
                ),
                child: _demiseEntity.photourl == null ?
                Center(
                  child: Text(
                    MyLocalizations.of(context, "no_photo"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0,
                    ),
                  ),
                ) : SizedBox(),
              ),
            ),
            SizedBox(height: 20),
            _buildParents(),
            _demiseEntity.title != null ?
            Text(
              _demiseEntity.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ) : SizedBox(),
            SizedBox(height: _demiseEntity.kinshipdesc != null ? 20 : 10),
            _demiseEntity.kinshipdesc != null ?
            Text(
              _demiseEntity.kinshipdesc,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ) : SizedBox(),
            SizedBox(height: _demiseEntity.kinshipdesc != null ? 20 : 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppTheme.baseColor,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    _demiseEntity.cityName != null ? _demiseEntity.cityName : MyLocalizations.of(context, "no_living_city_name"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _demiseEntity.date != null ? MyLocalizations.of(context, "died_on") + " " + DateFormat('dd/MM/yyyy').format(_demiseEntity.date)
                  :
              MyLocalizations.of(context, "no_demise_date_specified"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _demiseEntity.age != null ? MyLocalizations.of(context, "years") + " " + _demiseEntity.age.toString() : MyLocalizations.of(context, "no_age_specified"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            _demiseEntity.obituary != null ?
            RoundedButton(MyLocalizations.of(context, "fullscreen_pdf"), Colors.white, AppTheme.baseColor,
                    () async {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Scaffold(
                            appBar: AppBar(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              actionsIconTheme: IconThemeData(color: Colors.black),
                              iconTheme: IconThemeData(color: Colors.black),
                            ),
                            body: PDF().cachedFromUrl(
                              _demiseEntity.obituary,
                              placeholder: (progress) => Center(child: Text('$progress %')),
                              errorWidget: (error) => Center(child: Text(error.toString())),
                            ),

                          ))
                      );
                }) : SizedBox(),

            SizedBox(height: 20),
            _demiseEntity.obituary != null ?
           Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.almostBlack)
                ),
                child: Center(
                  child:
                  SfPdfViewer.network(_demiseEntity.obituary)
                /*  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        MyLocalizations.of(context, "pdf_document"),
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        MyLocalizations.of(context, "touch_to_open"),
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ), */
                ),
              ): SizedBox(),
            SizedBox(height: _demiseEntity.obituary != null ? 20 : 0),
            /*InkWell(
              onTap: () {
                //Utils.openMap(_demiseEntity.cemeteryLat, _demiseEntity.cemeteryLon);
              },
              child: Row(
                children: [
                  Text(
                    _demiseEntity.cityName != null ? _demiseEntity.cityName : MyLocalizations.of(context, "no_living_city_name"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),*/
            /*SizedBox(height: 20),
            InkWell(
              onTap: () {
                Utils.openMap(_demiseEntity.cemeteryLat, _demiseEntity.cemeteryLon);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _demiseEntity.cemeteryAddress ?? MyLocalizations.of(context, "no_cemetery_address_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  _demiseEntity.cemeteryAddress != null ? Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppTheme.almostBlack,) : SizedBox()
                ],
              ),
            ),*/
            SizedBox(height: 40),
            //WAKE DETAILS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                MyLocalizations.of(context, "wake_details"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.baseColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _demiseEntity.wakets != null ? DateFormat('dd/MM/yyyy').format(_demiseEntity.wakets) : MyLocalizations.of(context, "no_wake_date_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    _demiseEntity.wakets != null ? DateFormat('HH:mm').format(_demiseEntity.wakets) : MyLocalizations.of(context, "no_wake_time_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                if(_demiseEntity.wakeAddress == null)
                  return;
                double lat;
                double lon;
                GeoCode geoCode = GeoCode();
                Coordinates coordinates;
                try {
                  coordinates = await geoCode.forwardGeocoding(address: _demiseEntity.wakeAddress);
                }
                catch (e) {
                  Utils.hideCustomHudLong(context);
                  Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_find_cemetery_address"), context: context);
                  return;
                }
                lat = coordinates.latitude;
                lon = coordinates.longitude;
                Utils.openMap(lat, lon);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _demiseEntity.wakeAddress != null && _demiseEntity.wakeAddress.isNotEmpty ? _demiseEntity.wakeAddress : MyLocalizations.of(context, "no_wakeaddress_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  _demiseEntity.wakeAddress != null ? Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppTheme.almostBlack,) : SizedBox()
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              _demiseEntity.wakenotes ?? MyLocalizations.of(context, "no_wake_notes_specified"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 40),
            //FUNERAL DETAILS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                MyLocalizations.of(context, "funeral_details"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.baseColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _demiseEntity.funeralTs != null ? DateFormat('dd/MM/yyyy').format(_demiseEntity.funeralTs) : MyLocalizations.of(context, "no_funeral_date_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    _demiseEntity.funeralTs != null ? DateFormat('HH:mm').format(_demiseEntity.funeralTs) : MyLocalizations.of(context, "no_funeral_time_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                if(_demiseEntity.funeralAddress == null)
                  return;
                double lat;
                double lon;
                GeoCode geoCode = GeoCode();
                Coordinates coordinates;
                try {
                  coordinates = await geoCode.forwardGeocoding(address: _demiseEntity.wakeAddress);
                }
                catch (e) {
                  Utils.hideCustomHudLong(context);
                  Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_find_funeral_address"), context: context);
                  return;
                }
                lat = coordinates.latitude;
                lon = coordinates.longitude;
                Utils.openMap(lat, lon);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _demiseEntity.funeralAddress != null && _demiseEntity.funeralAddress.isNotEmpty ? _demiseEntity.funeralAddress
                      :
                    MyLocalizations.of(context, "no_funeraladdress_specified"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  _demiseEntity.funeralAddress != null ? Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppTheme.almostBlack,) : SizedBox()
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              _demiseEntity.funeralnotes ?? MyLocalizations.of(context, "no_funeral_notes_specified"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            userEntity != null && userEntity.status == UserStatus.agency ?
              Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: width,
                  child: RoundedButton(MyLocalizations.of(context, "edit"), Colors.white, AppTheme.baseColor,
                          () async {
                    DemiseEntity updated = await Get.to(AdminEditDemisePage(_demiseEntity));
                    if(updated != null && this.mounted) {
                      setState(() {
                         _demiseEntity = updated;
                      });
                    }
                  }),
                ),
                SizedBox(height: 20),
                Container(
                  width: width,
                  child: RoundedButton(MyLocalizations.of(context, "delete"), Colors.white, Colors.red,
                          () {
                          _deleteDemise();
                      }),
                ),
                SizedBox(height: 20),
              ],
            )
                :
              Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: width,
                    child: RoundedButton(MyLocalizations.of(context, "share"), Colors.white, AppTheme.baseColor,
                            () async {
                              String downloadLink = await Utils.getAppLink("unique_download_url");
                              if(downloadLink != null) {
                                Utils.showCustomHud(context);
                                //Share.share(downloadLink, subject: MyLocalizations.of(context, "download_claim"));
                                Directory documentDirectory = await getApplicationDocumentsDirectory();
                                var response = await Utils.buildDio().download(_demiseEntity.obituary,
                                    '${documentDirectory.path}/' + _demiseEntity.demiseid + '.pdf');
                                File pdf = new File('${documentDirectory.path}/' + _demiseEntity.demiseid + '.pdf');
                                //pdf.writeAsString(response.data);
                                Utils.hideCustomHud(context);
                                Share.shareFiles([pdf.path]);
                              }
                            }),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            userEntity != null && userEntity.status == UserStatus.agency ? SizedBox() :
            Container(
              width: width,
              child: RoundedButton(MyLocalizations.of(context, "send_telegram"), Colors.white, AppTheme.baseColor,
                      () async {
                    String url = Configuration.SEND_TELEGRAM_URL + _demiseEntity.demiseid;
                    if (await canLaunch(url))
                      await launch(url);
                  }),
            ),
            SizedBox(height: 20),
            Container(
              width: width * 0.3,
              height: width * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                image: _demiseEntity.agencylogo != null ?
                DecorationImage(
                  image: CachedNetworkImageProvider(_demiseEntity.agencylogo),
                  fit: BoxFit.contain,
                ) : null,
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(statusBarColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  void _deleteDemise() async {
    HapticFeedback.lightImpact();
    bool proceed = await Utils.showYesNoDialog(context, MyLocalizations.of(context, "are_you_sure"), MyLocalizations.of(context, "are_you_sure_delete"));
    if(!proceed)
      return;
    Utils.showCustomHud(context);
    bool success = await DemisesManager().deleteDemise(_demiseEntity.demiseid);
    Utils.hideCustomHud(context);
    if(success) {
      Get.back();
      Utils.showOkSnackBar(MyLocalizations.of(context, "demise_deleted"), context: context);
    }
    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
  }

  Widget _buildParents() {
    List<Widget> listaparenti = List.filled(_demiseEntity.relatives.length, Container(),growable: true);
    listaparenti.clear();
    for(RelativeEntity curr in _demiseEntity.relatives){
      listaparenti.add(parente(curr));
    }

    print("LISTA PARENTI");
    print(listaparenti);


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget> [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            MyLocalizations.of(context, "relatives_details_desc") + " " + _demiseEntity.name + " " + _demiseEntity.surname,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppTheme.almostBlack,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        for(Widget curr in listaparenti) curr
      ]
    /*      + _demiseEntity.relatives.map((e) => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              MyLocalizations.of(context, "the_" + kinshipToString(e.kinship)) + MyLocalizations.of(context, "of") + (e.prefix ?? "") + " " + (e.phone ?? ""),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      )).toList(), */
    );
  }


  Widget parente(e){
    String first = "";
    if(e.kinship != null) {
      first = MyLocalizations.of(context, "the_" + kinshipToString(e.kinship));
    }
    String second = MyLocalizations.of(context, "of");
    String third =  (e.prefix ?? "") + " " + (e.phone ?? "");
    String total = first + second + third;
    return
      Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
     //         MyLocalizations.of(context, "the_" + kinshipToString(e.kinship)) + MyLocalizations.of(context, "of") + (e.prefix ?? "") + " " + (e.phone ?? ""),
              total,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],);
  }

}

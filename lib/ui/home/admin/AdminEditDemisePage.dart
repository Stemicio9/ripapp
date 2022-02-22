import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:geocode/geocode.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ripapp/business_logic/DemisesManager.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/CemeteryEntity.dart';
import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/Kinship.dart';
import 'package:ripapp/entity/RelativeEntity.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/ui/auth/ChooseCitiesPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/AutocompleteTextField.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/DelayedSearch.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as pt;
import 'package:path/path.dart' as path;

class AdminEditDemisePage extends StatefulWidget {
  final DemiseEntity oldDemiseEntity;

  AdminEditDemisePage(this.oldDemiseEntity,);
  @override
  _AdminEditDemisePageState createState() => _AdminEditDemisePageState();
}

class _AdminEditDemisePageState extends State<AdminEditDemisePage> {
  List<String> prefixes = ["+1","+7","+7","+20","+27","+30","+31","+32","+33","+34","+36","+39","+40","+41","+43","+44","+45","+46","+47","+48","+49","+51","+52","+53","+53","+54","+55","+56","+57","+58","+60","+61","+61","+62","+63","+64","+65","+66","+81","+82","+84","+86","+90","+91","+92","+93","+94","+95","+98","+212","+213","+216","+218","+220","+221","+222","+223","+224","+225","+226","+227","+229","+230","+231","+232","+233","+234","+235","+236","+237","+238","+239","+240","+241","+242","+243","+244","+245","+248","+249","+250","+251","+252","+253","+254","+255","+256","+257","+258","+260","+261","+262","+263","+264","+265","+266","+267","+268","+269","+269","+290","+291","+297","+298","+299","+350","+351","+352","+353","+354","+355","+356","+357","+358","+359","+370","+371","+372","+373","+374","+375","+376","+377","+378","+380","+385","+386","+387","+389","+418","+420","+421","+423","+500","+501","+502","+503","+504","+505","+506","+507","+508","+509","+590","+591","+592","+593","+594","+595","+596","+597","+598","+599","+670","+672","+672","+673","+674","+675","+676","+677","+678","+679","+680","+681","+682","+683","+685","+686","+687","+688","+689","+690","+691","+692","+850","+852","+853","+855","+856","+880","+886","+960","+961","+962","+963","+964","+965","+966","+967","+968","+970","+971","+972","+973","+974","+975","+976","+977","+992","+993","+994","+995","+996","+998"];
  String _defunctPrefix;
  String _relativePrefix;
  String DEFAULT_PREFIX = "+39";

  List<UserEntity> usersFound = [];

  TextEditingController defunctPhoneController = new TextEditingController();
  List<RelativeEntity> relatives = [];
  bool _isSearching = false;
  DelayedSearch delayedSearch;
  File imageFile;

  CemeteryEntity cemeteryEntity;

  List<CityEntity> selectedCities = [];

  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController cemeteryAddressController = new TextEditingController();
  TextEditingController wakeAddressController = new TextEditingController();
  TextEditingController funeralAddressController = new TextEditingController();
  TextEditingController funeralNotesController = new TextEditingController();
  TextEditingController wakeNotesController = new TextEditingController();

  DateTime demiseDate;

  DateTime wakeDate = DateTime.now();
  DateTime funeralDate;

  FocusNode nameNode = new FocusNode();
  FocusNode lastNameNode = new FocusNode();
  FocusNode cemeterySearchNode = new FocusNode();
  FocusNode citySearchNode = new FocusNode();
  FocusNode dateNode = new FocusNode();
  FocusNode timeNode = new FocusNode();
  FocusNode cemeteryAddressNode = new FocusNode();
  FocusNode wakeAddressNode = new FocusNode();
  FocusNode funeralAddressNode = new FocusNode();
  FocusNode funeralNotesNode = new FocusNode();
  FocusNode wakeNotesNode = new FocusNode();

  List<CityEntity> cities;

  CityEntity livingCity;

  File document;

  int age;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    if(widget.oldDemiseEntity != null) {
      _defunctPrefix = widget.oldDemiseEntity.phoneprefix;
      defunctPhoneController.text = widget.oldDemiseEntity.phonenumber;
      if(widget.oldDemiseEntity.relatives.isNotEmpty) {
        relatives = widget.oldDemiseEntity.relatives;
      }

      cemeteryEntity = new CemeteryEntity(
          cemeteryid: widget.oldDemiseEntity.cemeteryUuid,
          cemeteryaddress: widget.oldDemiseEntity.cemeteryAddress,
          cemeterylat: widget.oldDemiseEntity.cemeteryLat,
          cemeterylon: widget.oldDemiseEntity.cemeteryLon,
          cemeteryname: widget.oldDemiseEntity.cemeteryName
      );

      //chosenCity = widget.oldDemiseEntity.city;
      selectedCities = widget.oldDemiseEntity.cities;
      nameController.text = widget.oldDemiseEntity.name;
      lastnameController.text = widget.oldDemiseEntity.surname;
      if(widget.oldDemiseEntity.cityName != null)
        livingCity = CityEntity(name: widget.oldDemiseEntity.cityName);
      cemeteryAddressController.text = widget.oldDemiseEntity.cemeteryAddress;
      wakeAddressController.text = widget.oldDemiseEntity.wakeAddress;
      demiseDate = widget.oldDemiseEntity.date;
      wakeDate = widget.oldDemiseEntity.wakets;
      funeralDate = widget.oldDemiseEntity.funeralTs;
      funeralAddressController.text = widget.oldDemiseEntity.funeralAddress;
      age = widget.oldDemiseEntity.age;
      funeralNotesController.text = widget.oldDemiseEntity.funeralnotes;
      wakeNotesController.text = widget.oldDemiseEntity.wakenotes;

    }


    _loadCities().then((value) {
      if(this.mounted && value != null)
        setState(() {
          cities = value;
        });
    });
    Function onEmptyQuery = () => setState(() {
      _isSearching = false;
      usersFound = [];
    });
    Function onComplete = (result) {
      if (this.mounted && result != null)
        setState(() {
          _isSearching = false;
          usersFound = result;
        });
    };
    delayedSearch = new DelayedSearch(UserHandler().autocompleteSearch, 350, onEmptyQuery, onComplete);
    if(relatives.isEmpty)
      relatives.add(new RelativeEntity());
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: EmptyAppBar(),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Container(
                padding: EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
                color: AppTheme.baseColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo_rect_transparent.png", color: Colors.white, width: width * 0.5, fit: BoxFit.cover),
                    _buildMoreButton()
                  ],
                ),
              ),*/
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: AppTheme.almostBlack,), onPressed: () async {
                    HapticFeedback.lightImpact();
                    bool proceed = await Utils.showYesNoDialog(context, MyLocalizations.of(context, "are_you_sure"), MyLocalizations.of(context, "are_you_sure_go_back"));
                    if(!proceed)
                      return;
                    Get.back();
                  }),
                  SizedBox(width: 10),
                  Text(
                    MyLocalizations.of(context, "edit_demise"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.baseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                 /*   SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          MyLocalizations.of(context, "insert_demise"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppTheme.baseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),*/
                    Row(
                      children: <Widget>[
                        Container(
                          width: 75,
                          color: Colors.transparent,
                          child: Theme(
                            data: new ThemeData(
                                canvasColor: Colors.white,
                                primaryColor: Colors.white,
                                accentColor: Colors.white,
                                hintColor: Colors.white),
                            child: DropdownButton<String>(
                              elevation: 24,
                              isExpanded: true,
                              underline: SizedBox(),
                              itemHeight: 50,
                              items:
                              prefixes
                                  .map((mapEntry)=> DropdownMenuItem<String>(
                                value: mapEntry,
                                child: Text(
                                  mapEntry,
                                  style: TextStyle(
                                      color: AppTheme.almostBlack,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  ),
                                ),
                              )
                              ).toList(),
                              value: _defunctPrefix != null ? _defunctPrefix : DEFAULT_PREFIX,
                              onChanged: (value) {
                                setState(() {
                                  _defunctPrefix = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Expanded(
                          child: TextField(
                            controller: defunctPhoneController,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (text) => Utils.unfocusTextField(context),
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.almostBlack),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: .0),
                              hintText: MyLocalizations.of(context, "defunct_phone"),
                              hintStyle: TextStyle(
                                  fontSize: 18.0,
                                  color: AppTheme.almostBlack,
                                  fontWeight: FontWeight.normal
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyLocalizations.of(context, "relatives_details"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: relatives.map((e) => _buildRelativeDetails(e)).toList(),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: width,
                      child: RoundedButton(MyLocalizations.of(context, "add_relative"), Colors.white, AppTheme.baseColor, () {
                        setState(() {
                          relatives.add(new RelativeEntity());
                        });
                      }),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyLocalizations.of(context, "demise_details"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: ()  async {
                        File photo = await Utils.pickImageFromGallery(context);
                        if(this.mounted)
                          setState(() {
                            imageFile = photo;
                          });
                      },
                      child: Container(
                        width: width * 0.5,
                        height: width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                          border: Border.all(color: AppTheme.almostBlack, width: 2),
                          image: imageFile != null || widget.oldDemiseEntity.photourl != null ?
                          DecorationImage(
                            image:
                            imageFile != null ? FileImage(imageFile) : CachedNetworkImageProvider(widget.oldDemiseEntity.photourl),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: imageFile == null && widget.oldDemiseEntity.photourl == null ?
                        Center(
                          child: Text(
                            MyLocalizations.of(context, "tap_insert_photo"),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: width/2.5,
                          child: TextField(
                            controller: nameController,
                            focusNode: nameNode,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            style: TextStyle(
                                color: AppTheme.almostBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                            decoration: InputDecoration(
                              //border: OutlineInputBorder(),
                              border: InputBorder.none,
                              hintText: MyLocalizations.of(context, "name"),
                              hintStyle: TextStyle(
                                  color: AppTheme.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18.0),
                            ),
                            onEditingComplete: () => lastNameNode.requestFocus(),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: width/2.5,
                          child: TextField(
                            controller: lastnameController,
                            focusNode: lastNameNode,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            style: TextStyle(
                                color: AppTheme.almostBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                            decoration: InputDecoration(
                              //border: OutlineInputBorder(),
                              border: InputBorder.none,
                              hintText: MyLocalizations.of(context, "lastname"),
                              hintStyle: TextStyle(
                                  color: AppTheme.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18.0),
                            ),
                            onEditingComplete: () => citySearchNode.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: width/2.5,
                          height: 10,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                        Container(
                          width: width/2.5,
                          height: 10,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        showAgePicker(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            width: width/2.5,
                            child: Text(
                              age != null ? age.toString() : MyLocalizations.of(context, "no_age_specified"),
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: width/2.5,
                          height: 10,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    /*AutocompleteTextField(
                        MyLocalizations.of(context, "cities_found"),
                        MyLocalizations.of(context, "no_city_found"),
                        AppTheme.baseColor,
                        AppTheme.almostBlack,
                        MyLocalizations.of(context, "living_city"),
                        AppTheme.grey,
                            (value) {
                          setState(() {
                            chosenCity = value;
                          });
                          return chosenCity.name;
                        },
                        autocompleteSearch,
                        _buildCity,
                        labelFocusNode: citySearchNode,
                        initialValue: widget.oldDemiseEntity.city.name,
                    ),*/
                    InkWell(
                      onTap: () async {
                        await showSelectCitiesPopup();
                      },
                      child: selectedCities.isEmpty ?
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          MyLocalizations.of(context, "no_city_selected"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0,
                          ),
                        ),
                      ) :
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              MyLocalizations.of(context, "city_of_interest") + " - " + MyLocalizations.of(context, "tap_to_edit").toLowerCase(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              //alignment: WrapAlignment.spaceAround,
                              children: selectedCities.map((city) => InkWell(
                                onTap: () async {
                                  setState(() {
                                    selectedCities.remove(city);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppTheme.baseColor,
                                      borderRadius: BorderRadius.circular(40)
                                  ),
                                  margin: EdgeInsets.only(right: 10, bottom: 10),
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        city.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Padding(
                                        padding: EdgeInsets.only(top: 0),
                                        child: Icon(Icons.clear, size: 30, color: Colors.white,),
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        DateTime newDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(Duration(days: 1)),
                          firstDate: DateTime.now().subtract(Duration(days: 90)),
                          lastDate: DateTime.now(),
                        );
                        if(this.mounted && newDate != null)
                          setState(() {
                            demiseDate = newDate;
                            wakeDate = null;
                            funeralDate = null;
                          });
                      },
                      child: Container(
                        height: 30,
                        width: width,
                        child: Text(
                          demiseDate != null ? DateFormat('dd/MM/yyyy').format(demiseDate) : MyLocalizations.of(context, "death_date"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: demiseDate != null ? AppTheme.almostBlack : AppTheme.grey,
                            fontSize: 18.0,
                            fontWeight: demiseDate != null ?  FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        showSelectLivingCityPopup();
                      },
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              MyLocalizations.of(context, "living_city_name") + " - " + MyLocalizations.of(context, "tap_to_edit").toLowerCase(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          SizedBox(height: livingCity != null ? 10 : 0),
                          livingCity != null ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                  livingCity.name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: livingCity != null ? AppTheme.almostBlack : Colors.black.withOpacity(0.5),
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ) : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        _loadDocument();
                      },
                      child: Container(
                        width: width,
                        height: document != null || widget.oldDemiseEntity.obituary != null ? 230 : 100,
                        decoration: BoxDecoration(
                            color: AppTheme.grey.withAlpha(40),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              MyLocalizations.of(context, "pdf_document"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            /*Text(
                              document != null ? MyLocalizations.of(context, "tap_open") : MyLocalizations.of(context, "tap_insert_pdf"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),*/
                            Text(
                              MyLocalizations.of(context, "tap_insert_pdf"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            document != null || widget.oldDemiseEntity.obituary != null ?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  path.basename(document != null ? document.path : MyLocalizations.of(context, "obituary_pdf")),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.grey,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(icon: Icon(Icons.history), onPressed: () {
                                  _loadDocument();
                                }),
                              ],
                            )
                                :
                            SizedBox(),
                            SizedBox(height: document != null || widget.oldDemiseEntity.obituary != null ? 20 : 0),
                            document != null || widget.oldDemiseEntity.obituary != null ?
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RoundedButton(
                                        MyLocalizations.of(context, "delete"), Colors.white, Colors.red,
                                            () {
                                          if(this.mounted)
                                            setState(() {
                                              this.document = null;
                                            });
                                        }
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: RoundedButton(
                                        MyLocalizations.of(context, "change"), Colors.white, AppTheme.darkGrey,
                                            () {
                                          _loadDocument();
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyLocalizations.of(context, "wake_details"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            if(demiseDate == null) {
                              Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_demise_date_first"));
                              return;
                            }
                            DateTime newDate = await showDatePicker(
                              context: context,
                              initialDate: wakeDate ?? DateTime.now().subtract(Duration(days: 1)),
                              firstDate: demiseDate,
                              lastDate: DateTime.now().add(Duration(days: 120)),
                            );
                            if(this.mounted && newDate != null)
                              setState(() {
                                wakeDate = newDate;
                              });
                          },
                          child: Container(
                            height: 40,
                            width: width/2.5,
                            child: Text(
                              wakeDate != null ? DateFormat('dd/MM/yyyy').format(wakeDate) : MyLocalizations.of(context, "date"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: wakeDate != null ? AppTheme.almostBlack : AppTheme.grey,
                                fontSize: 18.0,
                                fontWeight: wakeDate != null ?  FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            TimeOfDay date = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 16, minute: 0),
                              confirmText: MyLocalizations.of(context, "done"),
                              cancelText: MyLocalizations.of(context, "cancel"),
                            );
                            if(this.mounted && date != null)
                              setState(() {
                                wakeDate = DateTime(
                                    wakeDate != null ? wakeDate.year : DateTime.now().year,
                                    wakeDate != null ? wakeDate.month : DateTime.now().month,
                                    wakeDate != null ? wakeDate.day : DateTime.now().day,
                                    date.hour, date.minute
                                );
                              });
                          },
                          child: Container(
                            height: 40,
                            width: width/2.5,
                            child: Text(
                              wakeDate != null ? DateFormat('HH:mm').format(wakeDate) : MyLocalizations.of(context, "time"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: wakeDate != null ? AppTheme.almostBlack : AppTheme.grey,
                                fontSize: 18.0,
                                fontWeight: wakeDate != null ?  FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: width/2.5,
                          height: 1,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                        Container(
                          width: width/2.5,
                          height: 1,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: wakeAddressController,
                      focusNode: wakeAddressNode,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        border: InputBorder.none,
                        hintText: MyLocalizations.of(context, "address"),
                        hintStyle: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0),
                      ),
                      onEditingComplete: () => Utils.unfocusTextField(context),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: wakeNotesController,
                      focusNode: wakeNotesNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        border: InputBorder.none,
                        hintText: MyLocalizations.of(context, "wake_notes"),
                        hintStyle: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0),
                      ),
                      onEditingComplete: () => Utils.unfocusTextField(context),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    //FUNERAL DETAILS
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyLocalizations.of(context, "funeral_details"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            if(demiseDate == null) {
                              Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_demise_date_first"));
                              return;
                            }
                            DateTime newDate = await showDatePicker(
                              context: context,
                              initialDate: funeralDate ?? DateTime.now().add(Duration(days: 2)),
                              firstDate: demiseDate,
                              lastDate: DateTime.now().add(Duration(days: 120)),
                            );
                            if(this.mounted && newDate != null)
                              setState(() {
                                funeralDate = newDate;
                              });
                          },
                          child: Container(
                            height: 40,
                            width: width/2.5,
                            child: Text(
                              funeralDate != null ? DateFormat('dd/MM/yyyy').format(funeralDate) : MyLocalizations.of(context, "date"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: funeralDate != null ? AppTheme.almostBlack : AppTheme.grey,
                                fontSize: 18.0,
                                fontWeight: funeralDate != null ?  FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            TimeOfDay date = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 16, minute: 0),
                              confirmText: MyLocalizations.of(context, "done"),
                              cancelText: MyLocalizations.of(context, "cancel"),
                            );
                            if(this.mounted && date != null)
                              setState(() {
                                funeralDate = DateTime(
                                    funeralDate != null ? funeralDate.year : DateTime.now().year,
                                    funeralDate != null ? funeralDate.month : DateTime.now().month,
                                    funeralDate != null ? funeralDate.day : DateTime.now().day,
                                    date.hour, date.minute
                                );
                              });
                          },
                          child: Container(
                            height: 40,
                            width: width/2.5,
                            child: Text(
                              funeralDate != null ? DateFormat('HH:mm').format(funeralDate) : MyLocalizations.of(context, "time"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: funeralDate != null ? AppTheme.almostBlack : AppTheme.grey,
                                fontSize: 18.0,
                                fontWeight: funeralDate != null ?  FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: width/2.5,
                          height: 1,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                        Container(
                          width: width/2.5,
                          height: 1,
                          child: Divider(
                            thickness: 0.5,
                            color: AppTheme.almostBlack,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: funeralAddressController,
                      focusNode: funeralAddressNode,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        border: InputBorder.none,
                        hintText: MyLocalizations.of(context, "address"),
                        hintStyle: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0),
                      ),
                      onEditingComplete: () => Utils.unfocusTextField(context),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: funeralNotesController,
                      focusNode: funeralNotesNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        border: InputBorder.none,
                        hintText: MyLocalizations.of(context, "funeral_notes"),
                        hintStyle: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0),
                      ),
                      onEditingComplete: () => Utils.unfocusTextField(context),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: AppTheme.almostBlack,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: RoundedButton(
                              MyLocalizations.of(context, "save"), Colors.white, AppTheme.baseColor,
                                  () {
                                    _saveDemise();
                              }
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildUser(UserEntity e, RelativeEntity relativeEntity) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            relativeEntity.phone = e.phone;
            usersFound = [];
          });
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                e.photourl != null ?
                Container(
                  width: width * 0.3,
                  height: height * 0.13,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(e.photourl),
                        fit: BoxFit.cover,
                      )
                  ),
                )
                    :
                Container(
                  width: width * 0.2,
                  height: height * 0.13,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.almostBlack, width: 2)
                  ),
                  child: Icon(Icons.person, size: height * 0.05,),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Divider(
                        color: AppTheme.almostBlack,
                        height: 1,
                        thickness: 1,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        e.surname,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Divider(
                        color: AppTheme.almostBlack,
                        height: 1,
                        thickness: 1,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        e.email,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Divider(
                        color: AppTheme.almostBlack,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20,),
              ],
            ),
            SizedBox(height: 10,),
            Container(
              height: 50,
              width: width,
              child: RoundedButton(
                MyLocalizations.of(context, "select"), Colors.white, AppTheme.baseColor,
                    () {
                  setState(() {
                    relativeEntity.phone = e.phone;
                    usersFound = [];
                  });
                },
                verticalPadding: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<CityEntity>> _loadCities() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/cities.json");
    final jsonResult = json.decode(data);
    List<CityEntity> cities = [];
    for(var city in jsonResult)
      cities.add(CityEntity.fromJson(city));
    return cities;
  }

  List<CityEntity> autocompleteSearch(String cityName) {
    if(cityName == null || cityName.isEmpty /*|| cityName.length < 3*/)
      return [];
    List<CityEntity> result = cities
        .where((city) => city.name.toLowerCase().startsWith(cityName.toLowerCase()) || city.name.toLowerCase().contains(cityName.toLowerCase()))
        .toList();
    result.sort((c1, c2)=> c1.name.compareTo(c2.name));
    return result;
  }


  Widget _buildCity(dynamic cityEntity) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.grey.withAlpha(40),
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cityEntity.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Icon(Icons.check, color: AppTheme.almostBlack,)
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        SizedBox(height: 0),
        Divider(
          thickness: 0.5,
          height: 1,
          color: AppTheme.almostBlack,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCemetery(dynamic cemeteryEntity) {
    if(cemeteryEntity == null)
      return Container();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.grey.withAlpha(40),
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cemeteryEntity.cemeteryname,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Icon(Icons.check, color: AppTheme.almostBlack,)
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        SizedBox(height: 0),
        Divider(
          thickness: 0.5,
          height: 1,
          color: AppTheme.almostBlack,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _loadDocument() async {
   /* File f = await Utils.pickFileFromStorage(context);
    if(f == null)
      return;
    Directory tempDir = await getTemporaryDirectory();
    String basename = pt.basename(f.path);
    this.document = await File('${tempDir.path}/' + basename).create();
    if(this.mounted)
      setState(() {
      });*/
    File d = await Utils.pickFileFromStorage(context);
    if(this.mounted && d != null)
      setState(() {
        this.document = d;
      });
  }

  void _saveDemise() async {
    if(nameController.text.isEmpty || lastnameController.text.isEmpty)
       /* || chosenCity == null || demiseDate == null ||
        (cemeteryEntity == null && (cemeteryNameController.text.isEmpty || cemeteryAddressController.text.isEmpty)))*/ {
    Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_name_surname"), context: context);
      return;
    }
    if(livingCity == null) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_living_city"), context: context);
      return;
    }
    if(selectedCities == null) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_interest_cities"), context: context);
      return;
    }
    if(demiseDate == null) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_demise_date"), context: context);
      return;
    }
    if(age == null) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "insert_age"), context: context);
      return;
    }
    if(defunctPhoneController.text.isEmpty || !relatives.any((element) => element.phone != null) || !relatives.any((element) => element.kinship != null)
    /* || chosenCity == null || demiseDate == null ||*/
    /*|| (cemeteryEntity == null && (cemeteryNameController.text.isEmpty || cemeteryAddressController.text.isEmpty))*/
    ) {
      bool proceed = await showDialog(
          barrierDismissible: false,
          context: Get.context,
          builder: (_) =>
          new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: new Text(MyLocalizations.of(context, "sure_proceed_empty_fields_title"),
              style: TextStyle(
                  color: AppTheme.almostBlack
              ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MyLocalizations.of(Get.context, "sure_proceed_empty_fields_dscr"),
                  style: TextStyle(
                      color: AppTheme.almostBlack
                  ),),
              ],
            ),
            actions: <Widget> [
              new FlatButton(
                child: new Text(MyLocalizations.of(Get.context, "no")),
                onPressed: () {
                  Navigator.of(Get.context).pop(false);
                },
              ),
              new FlatButton(
                child: new Text(MyLocalizations.of(Get.context, "yes")),
                onPressed: () {
                  Navigator.of(Get.context).pop(true);
                },
              ),
            ],
          )
      );
      if(!proceed)
        return;
    }

    String docUrl;
    Utils.showCustomHudLong(context);
    if(document != null) {
      Reference ref = FirebaseStorage.instance.ref().child("obituary_pdfs").child(widget.oldDemiseEntity.demiseid);
      UploadTask uploadTask = ref.putFile(document);
      //TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if(snapshot.state == TaskState.success) {
          Utils.showOkSnackBar(MyLocalizations.of(context, "pdf_loaded"), context: context);
        }
        else
          Utils.showInfoSnackBar(MyLocalizations.of(context, "pdf_loading") + ': ${((snapshot.bytesTransferred / snapshot.totalBytes) * 100).toStringAsFixed(2)} %', context: context);
      }, onError: (e) {
        // The final snapshot is also available on the task via `.snapshot`,
        // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
        /*if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }*/
      });
      TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
      while(storageTaskSnapshot.state == TaskState.running) {
        await Future.delayed(Duration(seconds: 2));
        storageTaskSnapshot = await uploadTask.snapshot;
      }
      if(storageTaskSnapshot.state == TaskState.canceled || storageTaskSnapshot.state == TaskState.paused
          || storageTaskSnapshot.state == TaskState.error)
        return;
      docUrl = await ref.getDownloadURL();
    }
    else if (widget.oldDemiseEntity.obituary != null)
      docUrl = widget.oldDemiseEntity.obituary;
    String photoUrl;
    if(imageFile != null) {
      photoUrl = await Utils.savePhotoToFirebase(Configuration.DEMISE_PHOTOS, widget.oldDemiseEntity.demiseid, imageFile);
    }
    else if (widget.oldDemiseEntity.photourl != null)
      photoUrl = widget.oldDemiseEntity.photourl;
    double lat;
    double lon;
    if(cemeteryAddressController.text.isNotEmpty && (cemeteryEntity == null || cemeteryEntity.cemeterylat == null || cemeteryEntity.cemeterylon == null )) {
      GeoCode geoCode = GeoCode();
      Coordinates coordinates;
      try {
        coordinates = await geoCode.forwardGeocoding(address: cemeteryAddressController.text);
      }
      catch (e) {
        Utils.hideCustomHudLong(context);
        Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_find_cemetery_address"), context: context);
        return;
      }
      lat = coordinates.latitude;
      lon = coordinates.longitude;
    }
    else {
      lat = cemeteryEntity?.cemeterylat;
      lon = cemeteryEntity?.cemeterylon;
    }
    DemiseEntity createDemiseEntity = DemiseEntity(
          demiseid: widget.oldDemiseEntity.demiseid,
          name: nameController.text,
          surname: lastnameController.text,
          /*city: chosenCity,
          cityid: chosenCity.cityid,*/
          cities: selectedCities,
          date: demiseDate,
          phoneprefix: _defunctPrefix ?? DEFAULT_PREFIX,
          phonenumber: defunctPhoneController.text.isNotEmpty ? defunctPhoneController.text : null,
          photourl: photoUrl,
          obituary: docUrl,
          wakeAddress: wakeAddressController.text.isNotEmpty ? wakeAddressController.text : null,
          wakets: wakeDate,
          cemeteryUuid: cemeteryEntity?.cemeteryid,
          //cemeteryName:/* cemeteryEntity != null && cemeteryEntity.cemeteryname != null ? cemeteryEntity.cemeteryname : */cemeteryNameController.text.isNotEmpty ? cemeteryNameController.text : null,
          cityName: livingCity.name,
          cemeteryAddress: cemeteryAddressController.text.isNotEmpty ? cemeteryAddressController.text : null,
          cemeteryLat: lat,
          cemeteryLon: lon,
          relatives: relatives,
          funeralAddress: funeralAddressController.text.isNotEmpty ? funeralAddressController.text : null,
          funeralTs: funeralDate,
          age: age,
          wakenotes: wakeNotesController.text.isNotEmpty ? wakeNotesController.text : null,
          funeralnotes:funeralNotesController.text.isNotEmpty ? funeralNotesController.text : null,
    );
    bool success = await DemisesManager().updateDemise(createDemiseEntity);
    Utils.hideCustomHudLong(context);
    if(!success)
      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_update_demise"), context: context);
    else {
      Get.back(result:createDemiseEntity);
   //   Navigator.of(context).pop(createDemiseEntity);

      Utils.showOkSnackBar(MyLocalizations.of(context, "demise_updated"), context: context);
    }


  }

  Widget _buildRelativeDetails(RelativeEntity relativeEntity) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextEditingController relativePhoneController = new TextEditingController();
    relativePhoneController.value = TextEditingValue(text: relativeEntity.phone ?? "");
    relativePhoneController.selection = TextSelection.fromPosition(TextPosition(offset: relativePhoneController.text.length));
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            MyLocalizations.of(context, "relatives_details_desc"),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppTheme.almostBlack,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton<Kinship>(
            hint: Text(
              MyLocalizations.of(context, "select_kinship"),
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            underline: Divider(
              thickness: 1,
              color: AppTheme.almostBlack,
              height: 1,
            ),
            value: relativeEntity.kinship,
            onChanged: (Kinship value) {
              setState(() {
                relativeEntity.kinship = value;
              });
            },
            items: Kinship.values.map((Kinship kinship) {
              return  DropdownMenuItem<Kinship>(
                value: kinship,
                child: Text(
                  MyLocalizations.of(context, "the_" + kinshipToString(kinship)) + MyLocalizations.of(context, "of"),
                  style: TextStyle(
                    color: AppTheme.almostBlack,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Container(
              width: 75,
              color: Colors.transparent,
              child: Theme(
                data: new ThemeData(
                    canvasColor: Colors.white,
                    primaryColor: Colors.white,
                    accentColor: Colors.white,
                    hintColor: Colors.white),
                child: DropdownButton<String>(
                  elevation: 24,
                  isExpanded: true,
                  underline: SizedBox(),
                  itemHeight: 50,
                  items:
                  prefixes
                      .map((mapEntry)=> DropdownMenuItem<String>(
                    value: mapEntry,
                    child: Text(
                      mapEntry,
                      style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                  )
                  ).toList(),
                  value: relativeEntity.prefix != null ? relativeEntity.prefix : DEFAULT_PREFIX,
                  onChanged: (value) {
                    setState(() {
                      relativeEntity.prefix = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 15,),
            Expanded(
              child: TextField(
                controller: relativePhoneController,
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (text) => Utils.unfocusTextField(context),
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.almostBlack),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: .0),
                  hintText: MyLocalizations.of(context, "search_relative_phone"),
                  hintStyle: TextStyle(
                      fontSize: 18.0,
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onChanged: (val) {
                  /*if(val.length > 2 && !_isSearching)
                                setState(() {
                                  _isSearching = true;
                                });*/
                  relativeEntity.phone = val;
                  delayedSearch.doSearchAddress(val);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        usersFound.isNotEmpty ?
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Text(
                MyLocalizations.of(context, "users_found"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        )
            :
        SizedBox(),
        usersFound.isNotEmpty ? Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: usersFound.map((e) => _buildUser(e, relativeEntity)).toList()
            ),
          ),
        ) : SizedBox(),
        Divider(
          thickness: 0.5,
          color: AppTheme.almostBlack,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          width: width,
          child: RoundedButton(MyLocalizations.of(context, "remove_relative"), Colors.white, Colors.red, () {
            setState(() {
              relatives.remove(relativeEntity);
            });
          }),
        ),
      ],
    );
  }

  showAgePicker(BuildContext context) {
    return new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 150, initValue: age ?? 75),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ))
        ],
        hideHeader: true,
        title: new Text(MyLocalizations.of(context, "select_age")),
        onConfirm: (Picker picker, List value) {
          setState(() {
            age = value.first;
          });
        }
    ).showDialog(context);
  }

  void showSelectCitiesPopup() async {
    final selectedValues = await Get.to(ChooseCitiesPage(selectedCities));
    if(this.mounted && selectedValues != null)
      setState(() {
        selectedCities = selectedValues;
      });
  }

  void showSelectLivingCityPopup() async {
    final selectedValues = await Get.to(ChooseCitiesPage(livingCity != null ? [livingCity] : [], singleChoice: true, title: MyLocalizations.of(context, "city_of_residence"),));
    if(this.mounted && selectedValues != null)
      setState(() {
        livingCity = selectedValues.first;
      });
  }

}

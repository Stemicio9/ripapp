import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ripapp/business_logic/AgencyManager.dart';
import 'package:ripapp/business_logic/ContactsManager.dart';
import 'package:ripapp/entity/AgencyEntity.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/DelayedSearch.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class SendContactsToAgencyPage extends StatefulWidget {
  @override
  _SendContactsToAgencyPageState createState() => _SendContactsToAgencyPageState();
}

class _SendContactsToAgencyPageState extends State<SendContactsToAgencyPage> {
  DelayedSearch delayedSearch;
  TextEditingController searchController = new TextEditingController();
  bool _isSearching = false;
  List<AgencyEntity> agencies;

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
    Function onEmptyQuery = () => setState(() {
      searchController.text = "";
      _isSearching = false;
      agencies = [];
    });
    Function onComplete = (result) {
      if (this.mounted && result != null)
        setState(() {
          _isSearching = false;
          agencies = result;
        });
    };
    delayedSearch = new DelayedSearch(AgencyManager().agenciesAutocomplete, 350, onEmptyQuery, onComplete);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title:  Text(
          MyLocalizations.of(context, "send_contacts"),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.baseColor,
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.almostBlack),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.almostBlack, width: 1),
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Icon(Icons.search, color: AppTheme.almostBlack, size: 25,),
                  SizedBox(width: 10),
                  Container(
                    width: width - 100,
                    child: TextField(
                      controller: searchController,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        hintText: MyLocalizations.of(context, "search_agencies_by_name"),
                        hintStyle: TextStyle(
                            color: AppTheme.grey,
                            fontSize: 18
                        ),
                        labelStyle: TextStyle(
                            color: AppTheme.almostBlack,
                            fontSize: 18
                        ),
                        //enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.almostBlack)),
                      ),
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      onChanged: (val) {
                        if (val.length < 2)
                          return;
                                /*setState(() {
                                  _isSearching = true;
                                });*/
                        delayedSearch.doSearchAddress(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            agencies == null ?
            Center(
              child: Text(
                MyLocalizations.of(context, "type_at_least_2_chars"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
              ),
            )
              :
            agencies.isNotEmpty ?
            ListView.builder(
                shrinkWrap: true,
                itemCount: agencies.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      width: width,
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agencies[index].name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          Text(
                            agencies[index].address,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: RoundedButton(MyLocalizations.of(context, "select"), Colors.white, AppTheme.baseColor, () {
                                  _sendContactsToAgency(agencies[index].agencyid);
                                }),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            )
                :
            Center(
              child: Text(
                MyLocalizations.of(context, "no_agency_found"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.almostBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
              ),
            )
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

  void _sendContactsToAgency(String agencyId) async {
    //Utils.showOkSnackBar(MyLocalizations.of(context, "sending_contacts"));
    Utils.showCustomHud(context);
    List<Contact> contacts;
    try {
      contacts = await FlutterContacts.getContacts(
          withProperties: true
      );
      /*contacts = await Contacts.streamContacts(
          bufferSize: Configuration.CONTACTS_BUFFER_SIZE,
          withThumbnails: false,
          withHiResPhoto: false
      ).toList();*/
    }
    catch (e) {
      if(this.mounted)
        setState(() {

        });
      Utils.hideCustomHud(context);
      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
      bool accepted = await showDialog(
          barrierDismissible: false,
          context: Get.context,
          builder: (_) =>
          new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: new Text(MyLocalizations.of(Get.context, "open_app_settings"), style: TextStyle(
                color: AppTheme.almostBlack
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MyLocalizations.of(Get.context, "open_app_settings_dscr"),
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
                child: new Text(MyLocalizations.of(Get.context, "ok")),
                onPressed: () {
                  Navigator.of(Get.context).pop(true);
                },
              ),
            ],
          )
      );
      if(accepted)
        AppSettings.openAppSettings();
      return;
    }
    List<List<dynamic>> contactsConverted = [

    ];
    contactsConverted.addAll(contacts.map(
            (contact) => [
              contact.name.first,
              contact.name.last,
              ]
                + contact.phones.map((e) => e.number).toList()
                + contact.emails.map((e) => e.address).toList()
                + contact.addresses.map((e) => e.street + ";" + e.postalCode + ";" + e.city + ";" + e.state + ";" + e.country).toList() +
                [
              contact.id,
              contact.organizations.isEmpty ? null :  contact.organizations.first?.company,
              //contact.prefix,
              //contact.suffix,
              //contact.jobTitle,
              contact.notes.join(";"),
              //contact.accounts.toString(),
            ]
                + contact.socialMedias.map((e) => e.userName).toList()
    ).toList());

    String csv = ListToCsvConverter().convert(contactsConverted, fieldDelimiter: ";");
    Directory tempDir = await getTemporaryDirectory();
    File contactsFile = new File(tempDir.path + "contacts.csv");
    contactsFile = await contactsFile.writeAsString('$csv');

    bool success = await ContactsManager().sendContactsToAgency(agencyId, contactsFile);
    Utils.hideCustomHud(context);
    if(success) {
      Utils.showOkSnackBar(MyLocalizations.of(context, "contacts_sent"), context: context);
    }
    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
  }
}

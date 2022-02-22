import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ripapp/business_logic/ContactsManager.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/ui/home/user/SendContactsToAgencyPage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/StorageManager.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:intl/intl.dart';

class TelephoneBookPage extends StatefulWidget {
  @override
  _TelephoneBookPageState createState() => _TelephoneBookPageState();
}

class _TelephoneBookPageState extends State<TelephoneBookPage> {
  //bool _syncronized = false;
  DateTime lastSync;

  @override
  void initState() {
    super.initState();
    StorageManager.readValue("synchronized_time").then((value) async {
      if(this.mounted && value != null) {
        //_syncronized = true;
        DateTime lastSync = DateTime.parse(value);
        if (lastSync.difference(DateTime.now()).inDays >= Configuration.TELEPHONE_BOOK_UPDATE_INTERVAL_DAYS) {
          bool granted = await _requestPermissions();
          if (granted) {
            _synchronizeContacts();
          }
          else
            Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
        }
        else
          //_syncronized = true; //recently synced
        setState(() {
          this.lastSync = lastSync;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var formatter = new DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MyLocalizations.of(context, "telephone_book"),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.baseColor,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "synchronize_phone_contacts"), Colors.white, AppTheme.baseColor, () async {
                    bool granted = await _requestPermissions();
                    if(granted) {
                      _synchronizeContacts();
                    }
                    else
                      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
                  }),
                ),
              ],
            ),
            SizedBox(height: lastSync != null ? 10 : 0,),
            lastSync != null ?
            Text(
              MyLocalizations.of(context, "telephone_book_last_sync") + formatter.format(lastSync),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
              ),
            ) : SizedBox(),
            /*SizedBox(height: lastSync != null ? 20 : 10,),
            Row(
              children: [
                Expanded(
                  child: RoundedButton(MyLocalizations.of(context, "send_contacts_to_agency"), Colors.white, AppTheme.baseColor, () async {
                    bool granted = await _requestPermissions();
                    if(granted) {
                      Get.to(SendContactsToAgencyPage());
                    }
                    else
                      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
                  }),
                ),
              ],
            ),*/
            SizedBox(height: height * 0.1),
            /*lastSync != null ? Center(
              child:
                Image.asset("assets/synchronized_image.png", width: width * 0.6, fit: BoxFit.cover)
            ) : SizedBox(),*/
          ],
        ),
      ),
    );
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
    Utils.showOkSnackBar(MyLocalizations.of(context, "syncing_contacts"), context: context);
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
      lastSync = null;
      if(this.mounted)
        setState(() {

        });
      Utils.showErrorSnackBar(MyLocalizations.of(context, "cannot_get_contacts"), context: context);
      return;
    }
    bool success = await ContactsManager().synchronizeContacts(contacts);
    var now = DateTime.now();
    if(success) {
      Utils.showOkSnackBar(MyLocalizations.of(context, "telephone_book_synced"), context: context);
      await StorageManager.storeValue("synchronized_time", now.toString());
    }
    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);

    if(success)
      setState(() {
        lastSync = now;
      });
  }

}

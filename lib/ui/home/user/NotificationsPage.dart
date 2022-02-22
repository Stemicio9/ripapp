import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ripapp/business_logic/DemisesManager.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/Kinship.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/ui/home/user/DemiseDetailsPage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with WidgetsBindingObserver{

  List<DemiseEntity> demises;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _finishedLoading = false;
  bool _listIsLoading;

  PermissionStatus notificationsStatus;

  int offset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listIsLoading = false;
    _checkNotificationsPermissionStatus();
    DemisesManager().getNotifications(offset).then((value) {
      if(value != null && this.mounted)
        setState(() {
          demises = value;
        });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.detached || state == AppLifecycleState.paused){
      
    }
    else if (state == AppLifecycleState.resumed) {
      _checkNotificationsPermissionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    var day_formatter = new DateFormat('dd/MM');
    var hour_formatter = new DateFormat('HH:mm');
    return
      demises == null ? Utils.getProgressIndicator() :
      Container(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyLocalizations.of(context, "notifications"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.baseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(height: notificationsStatus != null && notificationsStatus != PermissionStatus.granted ? 20 : 0),
              SizedBox(height: notificationsStatus != null && notificationsStatus != PermissionStatus.granted ? 20 : 0),
              notificationsStatus != null && (notificationsStatus != PermissionStatus.granted) ?
              Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 50,
                width: width,
                child: RoundedButton(
                  MyLocalizations.of(context, "enable_notifications"), Colors.white, AppTheme.baseColor,
                      () {
                    _goToNotificationsSettings();
                  },
                  verticalPadding: 0,
                ),
              )
                  :
              SizedBox(),
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  header: MaterialClassicHeader(
                    distance: 100,
                    color: AppTheme.baseColor,
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context,LoadStatus mode){
                      Widget body;
                      if(mode==LoadStatus.loading){
                        body =  CupertinoActivityIndicator();
                      }
                      else if(mode==LoadStatus.idle){
                        body = Text(MyLocalizations.of(context, "load_finished"));
                      }
                      else if(mode==LoadStatus.loading){
                        body =  CupertinoActivityIndicator();
                      }
                      else if(mode == LoadStatus.failed){
                        body = Text(MyLocalizations.of(context, "load_failed"));
                      }
                      else if(mode == LoadStatus.canLoading){
                        body = Text(MyLocalizations.of(context, "load_more"));
                      }
                      else{
                        body = Text(MyLocalizations.of(context, "load_finished"));
                      }
                      return Container(

                      );

                    },
                  ),
                  onRefresh: _handleRefresh,
                  onLoading: (){
                    _loadMoreListValues();
                  },
                  child:
                  demises.isNotEmpty ?
                  SingleChildScrollView(
                    child: Column(
                      children: demises.map((demise) =>
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: InkWell(
                              onTap: () {
                                Get.to(DemiseDetailsPage(demise));
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: width * 0.5,
                                              child: Text(
                                                demise.title != null ? (demise.title.substring(0,1).toUpperCase() + demise.title.substring(1)) : "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: demise.read ? AppTheme.almostBlack.withOpacity(0.6) : AppTheme.almostBlack,
                                                  fontSize: 16.0,
                                                  fontWeight: demise.read ? FontWeight.normal : FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 1),
                                              child: Text(
                                                (now.difference(demise.ts).inHours < 24 && now.day == demise.ts.day && now.year == demise.ts.year ?
                                                MyLocalizations.of(context, "today") :
                                                now.difference(demise.ts).inDays == 1 || now.difference(demise.ts).inHours < 24 && now.day != demise.ts.day && now.year == demise.ts.year ?
                                                MyLocalizations.of(context, "yesterday")
                                                    :
                                                day_formatter.format(demise.ts)) + " " + MyLocalizations.of(context, "at_time") + " " + hour_formatter.format(demise.ts),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: demise.read ? AppTheme.almostBlack.withOpacity(0.6) : AppTheme.almostBlack,
                                                  fontSize: 12.0,
                                                  fontWeight: demise.read ? FontWeight.normal : FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        /*SizedBox(height: 5,),
                                        Text(
                                          MyLocalizations.of(context, "tap_info"),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: demise.read ? AppTheme.almostBlack.withOpacity(0.6) : AppTheme.almostBlack,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),*/
                                        SizedBox(height: 10,),
                                        Container(
                                          height: 40,
                                          width: width,
                                          child: RoundedButton(
                                            MyLocalizations.of(context, "info"), Colors.white,
                                            demise.read ? AppTheme.baseColor.withOpacity(0.6) :  AppTheme.baseColor,
                                                () {
                                              Get.to(DemiseDetailsPage(demise));
                                            },
                                            verticalPadding: 0,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )).toList(),

                  /*    children: [
                        ListView.builder(
                            padding: EdgeInsets.only(top: 20),
                            shrinkWrap: true,
                            itemCount: demises.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(DemiseDetailsPage(demises[index]));
                                  },
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getNotificationTitle(demises[index]),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: demises[index].read ? AppTheme.almostBlack.withOpacity(0.6) : AppTheme.almostBlack,
                                                fontSize: 18.0,
                                                fontWeight: demises[index].read ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5,),
                                            Text(
                                              MyLocalizations.of(context, "tap_info"),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: demises[index].read ? AppTheme.almostBlack.withOpacity(0.6) : AppTheme.almostBlack,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            Container(
                                              height: 40,
                                              width: width,
                                              child: RoundedButton(
                                                MyLocalizations.of(context, "info"), Colors.white,
                                                demises[index].read ? AppTheme.baseColor.withOpacity(0.6) :  AppTheme.baseColor,
                                                    () {
                                                  Get.to(DemiseDetailsPage(demises[index]));
                                                },
                                                verticalPadding: 0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ],*/
                    ),
                  )
                      :
                  Center(
                    child: Text(
                      MyLocalizations.of(context, "no_notification_found"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                ),
              )

            ],
          ),
        ),
      );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    //Utils.showCustomHud(context);
    offset = 0;
    List<DemiseEntity> dem = await DemisesManager().getNotifications(offset);
    if(this.mounted)
      setState(() {
        demises = dem;
      });
    _refreshController.refreshCompleted();
    //Utils.hideCustomHud(context);
  }

  _loadMoreListValues() async {
    if(_finishedLoading){
      _refreshController.loadComplete();
      return;
    }
    setState(() {
      _listIsLoading = true;
    });
    offset = demises.length;
    List<DemiseEntity> additional = await DemisesManager().getNotifications(offset);
    if(additional == null){
      _finishedLoading = true;
      _refreshController.loadComplete();
      return;
    }

    _finishedLoading = additional.length < Configuration.DEMISES_CHUNK_SIZE;
    demises.addAll(additional);
    print(demises.length);

    setState(() {
      _listIsLoading = false;
    });
    _refreshController.loadComplete();
  }

  /*String getNotificationTitle(DemiseEntity demiseEntity) {
    String name = "";
    if(demiseEntity.kinship != null) {
      switch (demiseEntity.kinship) {
        case Kinship.son:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.daughter:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.nephew:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.uncle:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.aunt:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.father:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.mother:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.wife:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.brother:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.sister:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.grandmother:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.grandfather:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.nephew_f:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.husband:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.brother_in_law:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.mother_in_law:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.father_in_law:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.son_in_law:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.daughter_in_law:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.sister_in_law:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.cousin_m:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.cousin_f:
          name += MyLocalizations.of(context, "the_woman");
          break;
        case Kinship.grandniece_m:
          name += MyLocalizations.of(context, "the_man");
          break;
        case Kinship.grandniece_f:
          name += MyLocalizations.of(context, "the_woman");
          break;
      }
      name += " " + MyLocalizations.of(context, kinshipToString(demiseEntity.kinship)).toLowerCase();
      name += " " + MyLocalizations.of(context, "of");
    }
    return sprintf(MyLocalizations.of(context, "notification_title"), [name, demiseEntity.relativeName]);
  }
*/
  void _goToNotificationsSettings() {
    AppSettings.openNotificationSettings();
  }

  void _checkNotificationsPermissionStatus() async {
    if(notificationsStatus == PermissionStatus.granted)
      return;
    PermissionStatus permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
    if(this.mounted && permissionStatus != null)
      setState(() {
        notificationsStatus = permissionStatus;
      });
  }
}

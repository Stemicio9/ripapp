import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ripapp/business_logic/DemisesManager.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/ui/home/admin/AdminCreateDemisePage.dart';
import 'package:ripapp/ui/home/user/DemiseDetailsPage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class AdminDemisesPage extends StatefulWidget {
  @override
  _AdminDemisesPageState createState() => _AdminDemisesPageState();
}

class _AdminDemisesPageState extends State<AdminDemisesPage> {

  List<DemiseEntity> demises;
  int offset = 0;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _finishedLoading = false;
  bool _listIsLoading;

  @override
  void initState() {
    super.initState();
    DemisesManager().getAgencyDemises(offset).then((value) {
      if(value != null && this.mounted)
        setState(() {
          demises = value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      demises == null ? Utils.getProgressIndicator() :
      Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          elevation: 5,
          backgroundColor: AppTheme.baseColor,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AdminCreateDemisePage()),
                ).whenComplete(() {
              _handleRefresh();
            });
          },
          icon: Icon(Icons.add),
          label: Text(
            MyLocalizations.of(context, "create_demise"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
            demises.isEmpty ?
            Center(
              child: Text(
                MyLocalizations.of(context, "no_demise_found"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            )
                :
          ListView.builder(
              shrinkWrap: true,
              itemCount: demises.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Get.to(DemiseDetailsPage(demises[index])).whenComplete(() {
                        _handleRefresh();
                      });

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
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              demises[index].photourl != null ?
                              Container(
                                width: width * 0.3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(demises[index].photourl),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ) : SizedBox(),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: demises[index].photourl == null ? 20 : 10),
                                    Text(
                                      demises[index].name + " " + demises[index].surname,
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
                                      demises[index].age != null ? (MyLocalizations.of(context, "years") + " " + demises[index].age.toString()) : MyLocalizations.of(context, "no_age_specified"),
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
                                      demises[index].cityName != null ? demises[index].cityName : MyLocalizations.of(context, "no_living_city_name"),
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
                                    SizedBox(height: 20),
                                    Container(
                                      height: 40,
                                      width: width,
                                      child: RoundedButton(
                                        MyLocalizations.of(context, "info"), Colors.white, AppTheme.baseColor,
                                            () {
                                          Get.to(DemiseDetailsPage(demises[index]));

                                        },
                                        verticalPadding: 0,
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
          ),

          ),
        ),
      );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    Utils.showCustomHud(context);
    offset = 0;
    List<DemiseEntity> dem = await DemisesManager().getAgencyDemises(offset);
    if(this.mounted)
      setState(() {
        demises = dem;
      });
    Utils.hideCustomHud(context);
    _refreshController.refreshCompleted();
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
    List<DemiseEntity> additional = await DemisesManager().getAgencyDemises(offset);
    if(additional == null){
      _finishedLoading = true;
      return;
    }

    _finishedLoading = additional.length < Configuration.DEMISES_CHUNK_SIZE;
    demises.addAll(additional);

    setState(() {
      _listIsLoading = false;
    });
    _refreshController.loadComplete();
  }

}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ripapp/business_logic/DemisesManager.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/DemisesSearchEntity.dart';
import 'package:ripapp/ui/auth/ChooseCitiesPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/ui/home/user/DemiseDetailsPage.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class CityDemisesPage extends StatefulWidget {
  @override
  _CityDemisesPageState createState() => _CityDemisesPageState();
}

class _CityDemisesPageState extends State<CityDemisesPage> {
  List<CityEntity> selectedCities = [];
  List<DemiseEntity> demises;
  DemisesSearchEntity demisesSearchEntity;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _finishedLoading = false;

  @override
  void initState() {
    super.initState();
    demisesSearchEntity = DemisesSearchEntity(
      cities: [],
      sorting: SearchSorting.date,
      offset: 0
    );
    DemisesManager().getDemisesByCities(demisesSearchEntity).then((value) {
      if(value != null && this.mounted)
        setState(() {
          demises = value;
        });
    });
    UserHandler().getUser().then((value) {
      if(this.mounted && value != null) {
        setState(() {
          selectedCities.addAll(value.cities);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      demises == null ? Utils.getProgressIndicator() :
      Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyLocalizations.of(context, "my_cities_demises"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppTheme.baseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  showSelectCitiesPopup();
                },
                child: Container(
                  height: 50,
                  width: width,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          MyLocalizations.of(context, "select_cities_of_interest"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppTheme.almostBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: AppTheme.almostBlack,)
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 0.5,
                color: AppTheme.almostBlack,
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selectedCities.map((city) => InkWell(
                        onTap: () {
                          selectedCities.remove(city);
                          _handleRefresh();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppTheme.baseColor,
                              borderRadius: BorderRadius.circular(40)
                          ),
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
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
                              SizedBox(width: 10,),
                              Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.clear, size: 30, color: Colors.white,),
                              ),

                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: selectedCities.isNotEmpty ? 10 : 0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            MyLocalizations.of(context, "order_by"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.almostBlack,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          DropdownButton<SearchSorting>(
                            hint: Text(MyLocalizations.of(context, "select")),
                            underline: Divider(
                              thickness: 1,
                              color: AppTheme.almostBlack,
                              height: 1,
                            ),
                            value: demisesSearchEntity.sorting,
                            onChanged: (SearchSorting value) {
                              demisesSearchEntity.sorting = value;
                              _handleRefresh();
                            },
                            items: SearchSorting.values.map((SearchSorting sorting) {
                              return  DropdownMenuItem<SearchSorting>(
                                value: sorting,
                                child: Row(
                                  children: <Widget>[
                                    /*user.icon,
                                    SizedBox(width: 10,),*/
                                    Text(
                                      MyLocalizations.of(context, searchSortingToString(sorting)),
                                      style: TextStyle(
                                        color: AppTheme.almostBlack,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      demises.isNotEmpty ?
                      Column(
                          children: demises.map((demise) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
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
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          demise.photourl != null ?
                                          Container(
                                            width: width * 0.3,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                                image: DecorationImage(
                                                  image: CachedNetworkImageProvider(demise.photourl),
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
                                                SizedBox(height: demise.photourl == null ? 20 : 10),
                                                Text(
                                                  demise.title ?? "",
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
                                                  demise.age != null ? (MyLocalizations.of(context, "years") + " " + demise.age.toString()) : MyLocalizations.of(context, "no_age_specified"),
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
                                                  demise.cityName != null ? demise.cityName : MyLocalizations.of(context, "no_living_city_name"),
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
                                                demise.kinshipdesc != null ?
                                                Text(
                                                  demise.kinshipdesc,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: AppTheme.almostBlack,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ) : SizedBox(),
                                                SizedBox(height: demise.kinshipdesc != null ? 5 : 0),
                                                demise.kinshipdesc != null ?
                                                Divider(
                                                  color: AppTheme.almostBlack,
                                                  height: 1,
                                                  thickness: 1,
                                                ) : SizedBox(),
                                                SizedBox(height: 10,),
                                                Container(
                                                  height: 40,
                                                  width: width,
                                                  child: RoundedButton(
                                                    MyLocalizations.of(context, "info"), Colors.white, AppTheme.baseColor,
                                                        () {
                                                      Get.to(DemiseDetailsPage(demise));
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
                          }).toList()
                      )
                          :
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: height * 0.1),
                          child: Text(
                            MyLocalizations.of(context, "no_demise_in_cities"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    Utils.showCustomHud(context);
    demisesSearchEntity.offset = 0;
    List<DemiseEntity> dem = await DemisesManager().getDemisesByCities(demisesSearchEntity);
    if(this.mounted)
      setState(() {
        demises = dem;
    });
    _refreshController.refreshCompleted();
    Utils.hideCustomHud(context);
  }

  _loadMoreListValues() async {
    if(_finishedLoading){
      _refreshController.loadComplete();
      return;
    }
    setState(() {

    });
    demisesSearchEntity.offset = demises.length;
    List<DemiseEntity> additional = await DemisesManager().getDemisesByCities(demisesSearchEntity);
    if(additional == null){
      _finishedLoading = true;
      return;
    }

    _finishedLoading = additional.length < Configuration.DEMISES_CHUNK_SIZE;
    demises.addAll(additional);

    setState(() {

    });
    _refreshController.loadComplete();
  }

  void showSelectCitiesPopup() async {
    final selectedValues = await Get.to(ChooseCitiesPage(selectedCities));
    if(this.mounted && selectedValues != null)
      setState(() {
        selectedCities = selectedValues;
        demisesSearchEntity.cities = selectedCities.map((city) => city.cityid).toList();
      });
    _handleRefresh();
  }

}

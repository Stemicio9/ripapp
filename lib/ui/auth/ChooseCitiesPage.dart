import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/DelayedSearch.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class ChooseCitiesPage extends StatefulWidget {
  List<CityEntity> selectedCities;
  final bool singleChoice;
  final String title;

  ChooseCitiesPage(this.selectedCities, {this.singleChoice: false, this.title});

  @override
  _ChooseCitiesPageState createState() => _ChooseCitiesPageState();
}

class _ChooseCitiesPageState extends State<ChooseCitiesPage> {
  List<CityEntity> cities;
  List<CityEntity> filteredCities;
  TextEditingController searchController = new TextEditingController();
  bool _isSearching = false;
  DelayedSearch delayedSearch;

  Color statusBarColor;
  SystemUiOverlayStyle style;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _finishedLoading = false;
  bool _listIsLoading;
  int offset =  30;

  @override
  void initState() {
    super.initState();
    FlutterStatusbarcolor.getStatusBarColor().then((value) {
      statusBarColor = value;
      style = SystemChrome.latestStyle;
      FlutterStatusbarcolor.setStatusBarColor(Colors.white);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
    _loadCities().then((value) {
      Function onEmptyQuery = () => setState(() {
        searchController.text = "";
        _isSearching = false;
        filteredCities = cities;
      });
      Function onComplete = (result) {
        if (this.mounted && result != null) {
          setState(() {
            _isSearching = false;
            filteredCities = result;
          });
        }
      };

      if(this.mounted && value != null)
        setState(() {
          delayedSearch = new DelayedSearch(autocompleteSearch, 300, onEmptyQuery, onComplete);
          cities = value;
          filteredCities = value;
        });
    });
  }

  List<CityEntity> autocompleteSearch(String cityName) {
    if(cityName == null || cityName.isEmpty || cityName.length < 3)
      return [];
    return cities
        .where((city) => city.name.toLowerCase().startsWith(cityName.toLowerCase()) || city.name.toLowerCase().contains(cityName.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return filteredCities == null ? Utils.getCircularProgressIndicatorScaffold() :
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title:  Text(
            widget.title ?? MyLocalizations.of(context, "cities_of_interest"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.baseColor,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          iconTheme: IconThemeData(color: AppTheme.almostBlack),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                    fontSize: 18.0,
                    color: AppTheme.almostBlack
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: AppTheme.almostBlack,
                    size: 30,
                  ),
                  hintText: MyLocalizations.of(context, "search_city"),
                  hintStyle: TextStyle(
                      fontSize: 18.0),
                ),
                onChanged: (val) {
                  if(val.length > 2 && !_isSearching)
                    setState(() {
                      _isSearching = true;
                    });
                    delayedSearch.doSearchAddress(val);

                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                thickness: 0.5,
                height: 1,
                color: AppTheme.almostBlack,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: height * 0.7,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: filteredCities.sublist(0, min(filteredCities.length, offset)).map((e) => _buildItem(e)).toList()
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: RoundedButton(MyLocalizations.of(context, "ok"), Colors.white, AppTheme.baseColor, () {
                      Navigator.of(context).pop(widget.selectedCities);
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
          ],
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

  _onItemCheckedChange(CityEntity cityEntity) {
    setState(() {
      if (widget.selectedCities.any((city) => city.cityid == cityEntity.cityid)) {
        widget.selectedCities.removeWhere((city) => city.cityid == cityEntity.cityid);
      } else {
        if(widget.singleChoice) {
          widget.selectedCities.clear();
        }
        widget.selectedCities.add(cityEntity);
      }
    });
  }

  Widget _buildItem(CityEntity cityEntity) {
    return
      InkWell(
        onTap: () {
          _onItemCheckedChange(cityEntity);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Checkbox(
                shape: CircleBorder(),
                value: widget.selectedCities.any((city) => city.cityid == cityEntity.cityid),
                onChanged: (checked) => _onItemCheckedChange(cityEntity),
                activeColor: AppTheme.almostBlack,
                checkColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              cityEntity.name,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(width: 10,),
          ],
        ),
      );

  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    Utils.showCustomHud(context);
    if(this.mounted)
      setState(() {
        offset = 0;
        filteredCities = cities;
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
      _listIsLoading = true;
    });

    _finishedLoading = offset >= cities.length;
    if(_finishedLoading) {
      _refreshController.loadComplete();
      return;
    }
    offset += 20;

    setState(() {
      _listIsLoading = false;
    });
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    super.dispose();
    FlutterStatusbarcolor.setStatusBarColor(statusBarColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

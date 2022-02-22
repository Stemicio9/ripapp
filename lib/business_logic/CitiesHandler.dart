import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/Utils.dart';

class CitiesHandler {

  /*Future<List<CityEntity>> getCities() async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.get(Configuration.GET_CITIES);
    }
    on DioError catch (e) {
      return null;
    }
    if (res.statusCode != 200)
      return [];
    List<CityEntity> cities = [];
    for(var s in res.data)
      cities.add(CityEntity.fromJson(s));
    return cities;
  }*/

}
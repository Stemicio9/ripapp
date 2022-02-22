import 'package:dio/dio.dart';
import 'package:ripapp/entity/AgencyEntity.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/Utils.dart';

class AgencyManager {

  Future<List<AgencyEntity>> agenciesAutocomplete(String query) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.get(Configuration.GET_AGENCIES + query);
    }
    on DioError catch (e) {
      return null;
    }
    if (res.statusCode != 200)
      return [];
    List<AgencyEntity> cities = [];
    for(var s in res.data)
      cities.add(AgencyEntity.fromJson(s));
    return cities;
  }

}
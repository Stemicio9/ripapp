import 'package:dio/dio.dart';
import 'package:ripapp/entity/CemeteryEntity.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/Utils.dart';

class CemeteryManager {

  Future<List<CemeteryEntity>> getCemeteries(String query) async {
    if(query == null || query.isEmpty || query.length < 3)
      return [];

    Dio dio = Utils.buildDio();
    Response response;
    try {
      response = (await dio.get(
        Configuration.AUTOCOMPLETE_CEMETERIES+"?query="+query,
      ));
    }
    on DioError catch (e) {
      response =  e.response;
      return [];
    }
    List<dynamic> data = (response.data) as List;
    List<CemeteryEntity> results = [];
    data.forEach( (value) {
      results.add(CemeteryEntity.fromJson(value));
    });
    return results;
  }

}
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ripapp/entity/CreateDemiseEntity.dart';
import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/DemisesSearchEntity.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/Utils.dart';

class DemisesManager {

  Future<List<DemiseEntity>> getDemisesByCities(DemisesSearchEntity demisesSearchEntity) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.post(Configuration.GET_DEMISES_BY_CITIES, data: json.encode(demisesSearchEntity));
    }
    on DioError catch (e) {
      return null;
    }
    if (res.statusCode != 201)
      return [];
    List<DemiseEntity> demises = [];
    for(var s in res.data)
      demises.add(DemiseEntity.fromJson(s));
    return demises;
  }

  Future<List<DemiseEntity>> getMyDemises(DemisesSearchEntity demisesSearchEntity) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.post(Configuration.GET_MY_DEMISES, data: json.encode(demisesSearchEntity));
    }
    on DioError catch (e) {
      return null;
    }
    if (res.statusCode != 201)
      return [];
    List<DemiseEntity> demises = [];
    for(var s in res.data)
      demises.add(DemiseEntity.fromJson(s));
    return demises;
  }

  Future<bool> createDemise(DemiseEntity createDemiseEntity) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.post(Configuration.ADMIN_CREATE_DEMISE,
          data: json.encode(createDemiseEntity)
      );
    }
    on DioError catch (e) {
      return false;
    }
    return res.statusCode == 201;
  }

  Future<List<DemiseEntity>> getNotifications(int offset) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.get(Configuration.GET_NOTIFICATIONS + "?offset=" + offset.toString());
    }
    on DioError catch (e) {
      return null;
    }
    if (res.statusCode != 200)
      return [];
    List<DemiseEntity> demises = [];
    for(var s in res.data)
      demises.add(DemiseEntity.fromJson(s));
    return demises;
  }

  Future<List<DemiseEntity>> getAgencyDemises(int offset) async {
      Dio dio = Utils.buildDio();
      Response res;
      try {
        res = await dio.get(Configuration.ADMIN_GET_ALL_DEMISES + "?offset=" + offset.toString());
      }
      on DioError catch (e) {
        return null;
      }
      if (res.statusCode != 200)
        return [];
      List<DemiseEntity> demises = [];
      for(var s in res.data)
        demises.add(DemiseEntity.fromJson(s));
      return demises;
    }

  Future<bool> updateDemise(DemiseEntity demiseEntity) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.put(Configuration.ADMIN_PUT_DEMISE + "/" + demiseEntity.demiseid, data: json.encode(demiseEntity));
    }
    on DioError catch (e) {
      return false;
    }
    return (res.statusCode == 201);
  }

  Future<bool> deleteDemise(String demiseId) async {
    Dio dio = Utils.buildDio();
    Response res;
    try {
      res = await dio.delete(Configuration.ADMIN_DELETE_DEMISE + "/" + demiseId);
    }
    on DioError catch (e) {
      return false;
    }
    return (res.statusCode == 200);
  }

}
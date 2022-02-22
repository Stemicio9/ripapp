/*
// To parse this JSON data, do
//
//     final createDemiseEntity = createDemiseEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ripapp/entity/DemiseEntity.dart';
import 'package:ripapp/entity/RelativeEntity.dart';

CreateDemiseEntity createDemiseEntityFromJson(String str) => CreateDemiseEntity.fromJson(json.decode(str));

String createDemiseEntityToJson(CreateDemiseEntity data) => json.encode(data.toJson());

class CreateDemiseEntity {
  CreateDemiseEntity({
    this.relatives,
    this.demiseEntity
  });

  DemiseEntity demiseEntity;
  List<RelativeEntity> relatives;

  factory CreateDemiseEntity.fromJson(Map<String, dynamic> json) => CreateDemiseEntity(
    relatives: List<RelativeEntity>.from(json["relatives"].map((x) => RelativeEntity.fromJson(x))),
    demiseEntity: json["demise"] != null ? DemiseEntity.fromJson(json["demise"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "cities": List<dynamic>.from(relatives.map((x) => x.toJson())),
    "relatives": relatives,
    "demise": demiseEntity != null ? demiseEntity.toJson() : null
  };
}*/

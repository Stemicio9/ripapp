// To parse this JSON data, do
//
//     final cemeteryEntity = cemeteryEntityFromJson(jsonString);

import 'dart:convert';

CemeteryEntity cemeteryEntityFromJson(String str) => CemeteryEntity.fromJson(json.decode(str));

String cemeteryEntityToJson(CemeteryEntity data) => json.encode(data.toJson());

class CemeteryEntity {
  CemeteryEntity({
    this.cemeteryid,
    this.cemeteryname,
    this.cemeteryaddress,
    this.cemeterylon,
    this.cemeterylat,
  });

  String cemeteryid;
  String cemeteryname;
  String cemeteryaddress;
  double cemeterylon;
  double cemeterylat;

  factory CemeteryEntity.fromJson(Map<String, dynamic> json) => CemeteryEntity(
    cemeteryid: json["cemeteryid"],
    cemeteryname: json["cemeteryname"],
    cemeteryaddress: json["cemeteryaddress"],
    cemeterylon: json["cemeterylon"],
    cemeterylat: json["cemeterylat"],
  );

  Map<String, dynamic> toJson() => {
    "cemeteryid": cemeteryid,
    "cemeteryname": cemeteryname,
    "cemeteryaddress": cemeteryaddress,
    "cemeterylon": cemeterylon,
    "cemeterylat": cemeterylat,
  };
}

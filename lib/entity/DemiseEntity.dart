// To parse this JSON data, do
//
//     final demiseEntity = demiseEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/entity/Kinship.dart';
import 'package:ripapp/entity/RelativeEntity.dart';

DemiseEntity demiseEntityFromJson(String str) => DemiseEntity.fromJson(json.decode(str));

String demiseEntityToJson(DemiseEntity data) => json.encode(data.toJson());

class DemiseEntity {
  DemiseEntity({
    this.demiseid,
    this.name,
    this.surname,
    this.photourl,
    this.date,
    this.cemeteryAddress,
    this.cityid,
    this.obituary,
    this.wakets,
    this.wakeAddress,
    this.city,
    this.cemeteryUuid,
    this.cemeteryName,
    this.cemeteryLat,
    this.cemeteryLon,
    this.phonenumber,
    this.phoneprefix,
    this.relativeName,
    this.kinship,
    this.read,
    this.relatives,
    this.funeralTs,
    this.funeralAddress,
    this.age,
    this.agencylogo,
    this.title,
    this.ts,
    this.kinshipdesc,
    this.funeralnotes,
    this.wakenotes,
    this.cities,
    this.cityName
  });

  String demiseid;
  String name;
  String surname;
  String photourl;
  DateTime date;
  String cemeteryUuid;
  String cemeteryAddress;
  double cemeteryLat;
  double cemeteryLon;
  String cemeteryName;
  String cityid;
  String obituary;
  DateTime wakets;
  String wakeAddress;
  CityEntity city;
  String cityName;
  String phonenumber;
  String phoneprefix;
  String relativeName;
  Kinship kinship;
  bool read;
  List<RelativeEntity> relatives;
  DateTime funeralTs;
  String funeralAddress;
  int age;
  String title;
  String agencylogo;
  DateTime ts;
  String kinshipdesc;
  String funeralnotes, wakenotes;
  List<CityEntity> cities;

  factory DemiseEntity.from(DemiseEntity other) => DemiseEntity(
    demiseid: other.demiseid,
    cityName: other.cityName,
    name: other.name,
    surname: other.surname,
    photourl: other.photourl,
    date: other.date,
    cemeteryUuid: other.cemeteryUuid,
    cemeteryAddress: other.cemeteryAddress,
    cemeteryLat: other.cemeteryLat,
    cemeteryLon: other.cemeteryLon,
    cemeteryName: other.cemeteryName,
    cityid: other.cityid,
    obituary: other.obituary,
    wakets: other.wakets,
    wakeAddress: other.wakeAddress,
    phonenumber: other.phonenumber,
    phoneprefix: other.phoneprefix,
    city: other.city,
    relativeName: other.relativeName,
    kinship: other.kinship,
    read: other.read,
    relatives: other.relatives,
    funeralAddress: other.funeralAddress,
    funeralTs: other.funeralTs,
    age: other.age,
    title: other.title,
    agencylogo: other.agencylogo,
    ts: other.ts,
    kinshipdesc: other.kinshipdesc,
    funeralnotes: other.funeralnotes,
    wakenotes: other.wakenotes,
    cities: other.cities,
  );

  factory DemiseEntity.fromJson(Map<String, dynamic> json) => DemiseEntity(
    demiseid: json["demiseid"],
    cityName: json["cityname"],
    name: json["name"],
    surname: json["surname"],
    photourl: json["photourl"],
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    cemeteryUuid: json["cemeteryid"],
    cemeteryAddress: json["cemeteryaddress"],
    cemeteryLat: json["cemeterylat"],
    cemeteryLon: json["cemeterylon"],
    cemeteryName: json["cemeteryname"],
    cityid: json["cityid"],
    obituary: json["obituary"],
    wakets: json["wakets"] != null ? DateTime.parse(json["wakets"]) : null,
    wakeAddress: json["wakeaddress"],
    phonenumber: json["phonenumber"],
    phoneprefix: json["phoneprefix"],
    city: json["city"] != null ? CityEntity.fromJson(json["city"]) : null,
    relativeName: json["relativename"],
    kinship: kinshipFromString(json["kinship"]),
    read: json["read"] ?? false,
    relatives: json["relatives"] != null ? List<RelativeEntity>.from(json["relatives"].map((x) => RelativeEntity.fromJson(x))) : [],
    funeralAddress: json["funeraladdress"],
    funeralTs: json["funeralts"] != null ? DateTime.parse(json["funeralts"]) : null,
    age: json["age"],
    title: json["title"],
    agencylogo: json["agencylogo"],
    ts: json["ts"] != null ? DateTime.parse(json["ts"]) : null,
    kinshipdesc: json["kinshipdesc"],
    funeralnotes: json["funeralnotes"],
    wakenotes: json["wakenotes"],
    cities: json["cities"] != null ? List<CityEntity>.from(json["cities"].map((x) => CityEntity.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "demiseid": demiseid,
    "name": name,
    "cityname": cityName,
    "surname": surname,
    "photourl": photourl,
    "date": date != null ? "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" : null,
    "cemeteryid": cemeteryUuid,
    "cemeteryaddress": cemeteryAddress,
    "cemeterylat": cemeteryLat,
    "cemeterylon": cemeteryLon,
    "cemeteryname": cemeteryName,
    "cityid": cityid,
    "obituary": obituary,
    "wakets": wakets?.toIso8601String(),
    "wakeaddress": wakeAddress,
    "phonenumber": phonenumber,
    "phoneprefix": phoneprefix,
    "city": city?.toJson(),
    "relativename": relativeName,
    "kinship": kinshipToString(kinship),
    "read": read,
    "relatives": List<dynamic>.from(relatives.map((x) => x.toJson())),
    "funeraladdress": funeralAddress,
    "funeralts": funeralTs?.toIso8601String(),
    "age": age,
    "title": title,
    "ts": ts?.toIso8601String(),
    "kinshipdesc": kinshipdesc,
    "funeralnotes": funeralnotes,
    "wakenotes": wakenotes,
    "cities": List<dynamic>.from(cities.map((x) => x.toJson())),
  };
}

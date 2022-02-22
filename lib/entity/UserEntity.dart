// To parse this JSON data, do
//
//     final userEntity = userEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/entity/UserStatusEnum.dart';

UserEntity userEntityFromJson(String str) => UserEntity.fromJson(json.decode(str));

String userEntityToJson(UserEntity data) => json.encode(data.toJson());

class UserEntity {
  UserEntity({
    this.accountid,
    this.name,
    this.surname,
    this.email,
    this.prefix,
    this.phone,
    this.notif,
    this.cities,
    this.idtoken,
    this.photourl,
    this.status
  });

  String accountid;
  String idtoken;
  String name;
  String surname;
  String email;
  String prefix;
  String phone;
  bool notif;
  List<CityEntity> cities;
  String photourl;
  UserStatus status;

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    accountid: json["accountid"],
    idtoken: json["idtoken"],
    name: json["name"],
    surname: json["surname"],
    email: json["email"],
    prefix: json["prefix"],
    phone: json["phone"],
    notif: json["notif"],
    cities: json["cities"] != null ? List<CityEntity>.from(json["cities"].map((x) => CityEntity.fromJson(x))) : [],
    photourl: json["photourl"],
    status: json["status"] != null ? userStatusFromString(json["status"]) : null
  );

  Map<String, dynamic> toJson() => {
    "accountid": accountid,
    "idtoken": idtoken,
    "name": name,
    "surname": surname,
    "email": email,
    "prefix": prefix,
    "phone": phone,
    "notif": notif,
    "cities": cities != null ? List<dynamic>.from(cities.map((x) => x.toJson())) : null,
    "photourl": photourl,
    "status": userStatusToString(status)
  };
}

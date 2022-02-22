// To parse this JSON data, do
//
//     final phoneEntity = phoneEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ripapp/entity/Kinship.dart';

RelativeEntity phoneEntityFromJson(String str) => RelativeEntity.fromJson(json.decode(str));

String phoneEntityToJson(RelativeEntity data) => json.encode(data.toJson());

class RelativeEntity {
  RelativeEntity({
    this.accountId,
    this.phone,
    this.prefix,
    this.kinship
  });

  String accountId;
  String phone;
  String prefix;
  Kinship kinship;

  factory RelativeEntity.fromJson(Map<String, dynamic> json) => RelativeEntity(
    accountId: json["accountid"],
    phone: json["phone"],
    prefix: json["prefix"],
    kinship: kinshipFromString(json["kinship"]),
  );

  Map<String, dynamic> toJson() => {
    "accountid": accountId,
    "phone": phone,
    "prefix": prefix,
    "kinship": kinshipToString(kinship)
  };
}

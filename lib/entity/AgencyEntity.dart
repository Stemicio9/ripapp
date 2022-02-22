// To parse this JSON data, do
//
//     final agencyEntity = agencyEntityFromJson(jsonString);

import 'dart:convert';

AgencyEntity agencyEntityFromJson(String str) => AgencyEntity.fromJson(json.decode(str));

String agencyEntityToJson(AgencyEntity data) => json.encode(data.toJson());

class AgencyEntity {
  AgencyEntity({
    this.agencyid,
    this.name,
    this.address,
    this.email
  });

  String agencyid;
  String name;
  String address;
  String email;

  factory AgencyEntity.fromJson(Map<String, dynamic> json) => AgencyEntity(
    agencyid: json["agencyid"],
    name: json["name"],
    address: json["address"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "agencyid": agencyid,
    "name": name,
    "address": address,
    "email": email,
  };
}

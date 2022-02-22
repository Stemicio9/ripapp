// To parse this JSON data, do
//
//     final contactEntity = contactEntityFromJson(jsonString);

import 'dart:convert';

ContactEntity contactEntityFromJson(String str) => ContactEntity.fromJson(json.decode(str));

String contactEntityToJson(ContactEntity data) => json.encode(data.toJson());

class ContactEntity {
  ContactEntity({
    this.num,
    this.prefix,
    this.name,
  });

  String num;
  String prefix;
  String name;

  factory ContactEntity.fromJson(Map<String, dynamic> json) => ContactEntity(
    num: json["num"],
    prefix: json["prefix"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "num": num,
    "prefix": prefix,
    "name": name,
  };
}

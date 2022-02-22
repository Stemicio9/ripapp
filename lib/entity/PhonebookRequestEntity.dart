// To parse this JSON data, do
//
//     final phonebookRequestEntity = phonebookRequestEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ripapp/entity/ContactEntity.dart';

PhonebookRequestEntity phonebookRequestEntityFromJson(String str) => PhonebookRequestEntity.fromJson(json.decode(str));

String phonebookRequestEntityToJson(PhonebookRequestEntity data) => json.encode(data.toJson());

class PhonebookRequestEntity {
  PhonebookRequestEntity({
    this.contacts,
    this.offset,
    this.total,
    this.hasNextChunk
  });

  List<ContactEntity> contacts;
  int offset;
  int total;
  bool hasNextChunk;

  factory PhonebookRequestEntity.fromJson(Map<String, dynamic> json) => PhonebookRequestEntity(
    contacts: List<ContactEntity>.from(json["contacts"].map((x) => ContactEntity.fromJson(x))),
    offset: json["offset"],
    total: json["total"],
    hasNextChunk: json["hasnextchunk"],
  );

  Map<String, dynamic> toJson() => {
    "contacts": List<dynamic>.from(contacts.map((x) => x.toJson())),
    "offset": offset,
    "total": total,
    "hasnextchunk": hasNextChunk,
  };
}

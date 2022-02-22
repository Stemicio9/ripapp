import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ripapp/entity/ContactEntity.dart';
import 'package:ripapp/entity/PhonebookRequestEntity.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:sprintf/sprintf.dart';

class ContactsManager {

  Future<bool> synchronizeContacts(List<Contact> contacts) async {
    List<Contact> contactsFiltered = contacts.where((contact) => contact.phones.isNotEmpty).toList();
    Dio dio = Utils.buildDio();
    Response res;
    for(int i=0; i<contactsFiltered.length; i+=Configuration.SYNC_CONTACTS_BUFFER_SIZE) {
      try {
        List<Contact> l = contactsFiltered.sublist(i, min(contactsFiltered.length, i+Configuration.SYNC_CONTACTS_BUFFER_SIZE));
        List<ContactEntity> entities = l
            .map((contact) => ContactEntity(
            name: contact.displayName,
            num: contact.phones.first.number
        )).toList();
        PhonebookRequestEntity phonebookRequestEntity = new PhonebookRequestEntity(
          contacts: entities,
          offset: i,
          total: contactsFiltered.length,
          hasNextChunk: i + Configuration.SYNC_CONTACTS_BUFFER_SIZE < contactsFiltered.length
        );
        //print("ciao");
        res = await dio.post(Configuration.SYNCHRONIZE_CONTACTS, data: json.encode(phonebookRequestEntity));
        if((res.statusCode != 201))
          return false;
      }
      on DioError catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<bool> sendContactsToAgency(String agencyId, File contactsFile) async {
    Dio dio = Utils.buildDio();
    var bytes = await contactsFile.readAsBytes();
    var formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(bytes)
    });
    /*var formData = FormData.fromMap({
      "file": await MultipartFile.fromFile("./text.txt", filename: "contacts.csv"),
    });*/
    Response response;
    try {
      response = await dio.post(sprintf(Configuration.SEND_CONTACTS_TO_AGENCY, [agencyId]), data: formData);
    }
    on DioError catch (e) {
      return false;
    }
    if (response.statusCode != 201)
      return false;

    return true;
  }

}
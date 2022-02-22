// To parse this JSON data, do
//
//     final demisesSearchEntity = demisesSearchEntityFromJson(jsonString);

import 'dart:convert';

DemisesSearchEntity demisesSearchEntityFromJson(String str) => DemisesSearchEntity.fromJson(json.decode(str));

String demisesSearchEntityToJson(DemisesSearchEntity data) => json.encode(data.toJson());

class DemisesSearchEntity {
  DemisesSearchEntity({
    this.cities,
    this.sorting,
    this.offset,
  });

  List<String> cities;
  SearchSorting sorting;
  int offset;

  factory DemisesSearchEntity.fromJson(Map<String, dynamic> json) => DemisesSearchEntity(
    cities: List<String>.from(json["cities"].map((x) => x)),
    sorting: json["sorting"] != null ? searchSortingFromString(json["sorting"]) : null,
    offset: json["offset"],
  );

  Map<String, dynamic> toJson() => {
    "cities": List<dynamic>.from(cities.map((x) => x)),
    "sorting": searchSortingToString(sorting),
    "offset": offset,
  };
}

enum SearchSorting {
  date, name, surname
}

String searchSortingToString(SearchSorting type) {
  if(type == null)
    return null;
  return '$type'.split('.').last;
}

SearchSorting searchSortingFromString(String type) {
  if(type == null)
    return null;
  return SearchSorting.values.firstWhere((element) => element.toString().split(".").last == type, orElse: null);
}

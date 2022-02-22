
class CityEntity {
  CityEntity({
    this.cityid,
    this.name,
  });

  String cityid;
  String name;

  factory CityEntity.fromJson(Map<String, dynamic> json) => CityEntity(
    cityid: json["cityid"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "cityid": cityid,
    "name": name,
  };
}
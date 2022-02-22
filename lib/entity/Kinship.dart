enum Kinship {
  son,
  daughter,
  nephew,
  uncle,
  aunt,
  father,
  mother,
  wife,
  brother,
  sister,
  grandmother,
  grandfather,
  nephew_f,
  husband,
  brother_in_law,
  mother_in_law,
  father_in_law,
  son_in_law,
  daughter_in_law,
  sister_in_law,
  cousin_m,
  cousin_f,
  grandniece_m,
  grandniece_f
}

String kinshipToString(Kinship type) {
  if(type == null)
    return null;
  return '$type'.split('.').last;
}

Kinship kinshipFromString(String type) {
  if(type == null)
    return null;
  return Kinship.values.firstWhere((element) => element.toString().split(".").last == type, orElse: null);
}

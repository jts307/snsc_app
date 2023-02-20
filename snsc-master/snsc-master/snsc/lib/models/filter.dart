class Filter {
  String? name;
  int? frequency;

  Filter({this.name, this.frequency});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['frequency'] = frequency;
    return data;
  }

  // ignore: non_constant_identifier_names
  factory Filter.fromJson(Map<String, dynamic> Json) {
    Filter newFilter = Filter(name: Json['name'], frequency: Json['frequency']);
    return newFilter;
  }

  static List<String> convertToStringList(dynamic values) {
    List<String> result = [];

    for (var item in values) {
      result.add(item.name);
    }

    return result;
  }
}

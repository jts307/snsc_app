class User {
  String? name;
  String email;
  String? password;
  String? dateOfBirth;
  String? location;
  String? disability;
  String? insurance;
  List<dynamic>? favoriteIds;
  bool? isAdmin;
  String? token;

  User(
      {this.name,
      required this.email,
      this.password,
      this.dateOfBirth,
      this.location,
      this.disability,
      this.insurance,
      this.favoriteIds,
      this.isAdmin,
      this.token});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['dateOfBirth'] = dateOfBirth;
    data['location'] = location;
    data['disability'] = disability;
    data['insurance'] = insurance;
    data['favoriteIds'] = favoriteIds;
    data['isAdmin'] = isAdmin;
    data['token'] = token;
    return data;
  }

  // ignore: non_constant_identifier_names
  factory User.fromJson(Map<String, dynamic> Json) {
    User newUser = User(
        name: Json['name'],
        email: Json['email'],
        password: Json['password'],
        dateOfBirth: Json['dateOfBirth'],
        location: Json['location'],
        disability: Json['disability'],
        insurance: Json['insurance'],
        favoriteIds: Json['favoriteIds'],
        isAdmin: Json['isAdmin'],
        token: Json['token']);
    return newUser;
  }
}

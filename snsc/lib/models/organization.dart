// ignore_for_file: non_constant_identifier_names

class Age {
  int? lowerRange;
  int? upperRange;
  bool? allAges;

  Age({
    this.lowerRange,
    this.upperRange,
    this.allAges,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lowerRange'] = lowerRange;
    data['upperRange'] = upperRange;
    data['allAges'] = allAges;
    return data;
  }

  factory Age.fromJson(Map<String, dynamic> Json) {
    Age newAge = Age(
        lowerRange: Json['lowerRange'],
        upperRange: Json['upperRange'],
        allAges: Json['allAges']);
    return newAge;
  }
}

class Organization {
  String? id;
  String? name;
  String? descriptions;
  String? primaryContactName;
  String? primaryContactRole;
  String? primaryEmail;
  String? fullEmail;
  String? primaryPhoneNumber;
  String? fullPhoneNumber;
  String? primaryWebsite;
  String? fullWebsite;
  List<dynamic>? disabilitiesServed;
  List<dynamic>? servicesProvided;
  List<dynamic>? statesServed;
  List<dynamic>? townsNewHampshire;
  List<dynamic>? townsVermont;
  Age? agesServed;
  String? fee;
  String? feeDescription;
  List<dynamic>? insurancesAccepted;
  String? imageURL;

  Organization(
      {this.id,
      this.name,
      this.descriptions,
      this.primaryContactName,
      this.primaryContactRole,
      this.primaryEmail,
      this.fullEmail,
      this.primaryPhoneNumber,
      this.fullPhoneNumber,
      this.primaryWebsite,
      this.fullWebsite,
      this.disabilitiesServed,
      this.servicesProvided,
      this.statesServed,
      this.townsNewHampshire,
      this.townsVermont,
      this.agesServed,
      this.fee,
      this.feeDescription,
      this.insurancesAccepted,
      this.imageURL});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['descriptions'] = descriptions;
    data['primaryContactName'] = primaryContactName;
    data['primaryContactRole'] = primaryContactRole;
    data['primaryEmail'] = primaryEmail;
    data['fullEmail'] = fullEmail;
    data['primaryPhoneNumber'] = primaryPhoneNumber;
    data['fullPhoneNumber'] = fullPhoneNumber;
    data['primaryWebsite'] = primaryWebsite;
    data['fullWebsite'] = fullWebsite;
    data['disabilitiesServed'] = disabilitiesServed;
    data['servicesProvided'] = servicesProvided;
    data['statesServed'] = statesServed;
    data['townsNewHampshire'] = townsNewHampshire;
    data['townsVermont'] = townsVermont;
    data['agesServed'] = agesServed?.toJson();
    data['fee'] = fee;
    data['feeDescription'] = feeDescription;
    data['insurancesAccepted'] = insurancesAccepted;
    data['imageURL'] = imageURL;
    return data;
  }

  factory Organization.fromJson(Map<String, dynamic> Json) {
    Organization newOrganization = Organization(
        id: Json['id'] ?? Json['_id'],
        name: Json['name'],
        descriptions: Json['descriptions'],
        primaryContactName: Json['primaryContactName'],
        primaryContactRole: Json['primaryContactRole'],
        primaryEmail: Json['primaryEmail'],
        fullEmail: Json['fullEmail'],
        primaryPhoneNumber: Json['primaryPhoneNumber'],
        fullPhoneNumber: Json['fullPhoneNumber'],
        primaryWebsite: Json['primaryWebsite'],
        fullWebsite: Json['fullWebsite'],
        disabilitiesServed: Json['disabilitiesServed'],
        servicesProvided: Json['servicesProvided'],
        statesServed: Json['statesServed'],
        townsNewHampshire: Json['townsNewHampshire'],
        townsVermont: Json['townsVermont'],
        agesServed: Json['agesServed'] != null
            ? Age.fromJson(Json['agesServed'])
            : Age(),
        fee: Json['fee'],
        feeDescription: Json['feeDescription'],
        insurancesAccepted: Json['insurancesAccepted'],
        imageURL: Json['imageURL']);
    return newOrganization;
  }
}

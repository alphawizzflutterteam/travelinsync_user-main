class AddressModel {
  String? id;
  String? userId;
  String? address;
  String? type;
  String? lat;
  String? lang;
  String? createdAt;
  String? updatedAt;

  AddressModel(
      {this.id,
        this.userId,
        this.address,
        this.type,
        this.lat,
        this.lang,
        this.createdAt,
        this.updatedAt});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    address = json['address'];
    type = json['type'];
    lat = json['lat'];
    lang = json['lang'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['address'] = this.address;
    data['type'] = this.type;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

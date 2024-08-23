class PlanModel {
  String? id;
  String? title;
  String? description;
  String? type;
  String? image;
  String? price;
  String? status;
  String? createdAt;
  String? updatedAt;

  PlanModel(
      {this.id,
        this.title,
        this.description,
        this.type,
        this.image,
        this.price,
        this.status,
        this.createdAt,
        this.updatedAt});

  PlanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    image = json['image'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['type'] = this.type;
    data['image'] = this.image;
    data['price'] = this.price;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

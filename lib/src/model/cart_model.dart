import 'package:iam/src/model/single_product_model.dart';

class CartModel {
  int? id;
  String? name;
  double? price;
  String? img;
  int? quantity;
  bool? isExist;
  String? time;
  SingleProductModel? product;

  CartModel({
    this.id,
    this.name,
    this.price,
    this.img,
    this.quantity,
    this.isExist,
    this.time,
    this.product,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'] is int ? (json['price'] as int).toDouble() : json['price'];
    img = json['img'];
    quantity = json['quantity'];
    isExist = json['isExist'];
    time = json['time'];

    // Handle product field - check if it's a Map before parsing
    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      product = SingleProductModel.fromJson(json['product']);
    } else {
      product = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "img": img,
      "quantity": quantity,
      "isExist": isExist,
      "time": time,
      "product": product?.toJson(), // Safe null access
    };
  }
}
import 'dart:convert';

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

  // Convert to JSON string
  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'price': price,
      'img': img,
      'quantity': quantity,
      'isExist': isExist,
      'time': time,
    };

    // Include product data if available
    if (product != null) {
      data['product'] = {
        'id': product!.id,
        'name': product!.name,
        'price': product!.price,
        'image': product!.image,
        'description': product!.description,
        'category_id': product!.category_id,
        'category_name': product!.category_name,
        'stock': product!.stock,
      };
    }

    return jsonEncode(data);
  }

  // Create from JSON string
  factory CartModel.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    SingleProductModel? productModel;
    if (data['product'] != null) {
      final productData = data['product'];
      productModel = SingleProductModel(
        id: productData['id'],
        name: productData['name'],
        price: productData['price']?.toDouble(),
        image: productData['image'],
        description: productData['description'],
        category_id: productData['category_id'],
        category_name: productData['category_name'],
        stock: productData['stock'],
      );
    }

    return CartModel(
      id: data['id'],
      name: data['name'],
      price: data['price']?.toDouble(),
      img: data['img'],
      quantity: data['quantity'],
      isExist: data['isExist'],
      time: data['time'],
      product: productModel,
    );
  }
}
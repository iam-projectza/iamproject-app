import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../data/repository/cart_repo.dart';
import '../model/cart_model.dart';
import '../model/single_product_model.dart';

class CartController extends GetxController {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  Map<int, CartModel> _items = {};
  Map<int, CartModel> get items => _items;
  List<CartModel> storageItems = [];

  // Add this getter for total items count
  int get totalItemsCount {
    return _items.values.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  void addItem(SingleProductModel product, int quantity) {
    var totalQuantity = 0;

    if (_items.containsKey(product.id!)) {
      _items.update(product.id!, (value) {
        totalQuantity = (value.quantity ?? 0) + quantity;

        return CartModel(
          id: value.id,
          name: value.name,
          price: value.price,
          img: value.img,
          quantity: totalQuantity,
          isExist: true,
          time: DateTime.now().toString(),
          product: product,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(product.id);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(product.id!, () {
          return CartModel(
            id: product.id,
            name: product.name,
            price: product.price,
            img: product.image,
            quantity: quantity,
            isExist: true,
            time: DateTime.now().toString(),
            product: product,
          );
        });
      } else {
        Get.snackbar(
          'Item Count',
          'You should at least add 1 item',
          backgroundColor: AppColors.mainColor,
          colorText: Colors.white,
        );
      }
    }

    cartRepo.addToCartList(getItems);
    update();
  }

  bool existInCart(SingleProductModel product) {
    return _items.containsKey(product.id);
  }

  int getQuantity(SingleProductModel product) {
    var quantity = 0;
    if (_items.containsKey(product.id)) {
      _items.forEach((key, value) {
        if (key == product.id) {
          quantity = value.quantity ?? 0;
        }
      });
    }
    return quantity;
  }

  int get totalItems {
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity ?? 0;
    });
    return totalQuantity;
  }

  List<CartModel> get getItems {
    return _items.entries.map((e) => e.value).toList();
  }

  double get totalAmount {
    double total = 0;
    _items.forEach((key, value) {
      total += (value.quantity ?? 0) * (value.price ?? 0);
    });
    return total;
  }

  List<CartModel> getCartData() {
    setCart = cartRepo.getCartList();
    return storageItems;
  }

  set setCart(List<CartModel> items) {
    storageItems = items;
    print('items in cart ' + storageItems.length.toString());

    // Clear existing items and add new ones
    _items.clear();
    for (int i = 0; i < storageItems.length; i++) {
      if (storageItems[i].product?.id != null) {
        _items.putIfAbsent(storageItems[i].product!.id!, () => storageItems[i]);
      }
    }
    update();
  }

  void addToHistory() {
    cartRepo.addToCartHistoryList();
    clear();
  }

  void clear() {
    _items = {};
    update();
  }

  List<CartModel> getCartHistoryList() {
    return cartRepo.getCartHistoryList();
  }

  void clearCartHistory() {
    cartRepo.clearCartHistory();
    update();
  }

  // Add this method to remove specific item
  void removeItem(int productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      cartRepo.addToCartList(getItems);
      update();
    }
  }

  // Add this method to update quantity
  void updateQuantity(int productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        _items.update(productId, (value) {
          return CartModel(
            id: value.id,
            name: value.name,
            price: value.price,
            img: value.img,
            quantity: newQuantity,
            isExist: true,
            time: value.time,
            product: value.product,
          );
        });
        cartRepo.addToCartList(getItems);
        update();
      }
    }
  }
}
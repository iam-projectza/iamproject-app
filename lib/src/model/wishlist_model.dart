import '../utils/app_constants.dart';

class WishlistItem {
  final String address;
  final int userId;
  final String user;
  final String phone;
  final List<dynamic> wishlistItems; // Change the type to List<WishlistItemImage>

  WishlistItem({
    required this.address,
    required this.userId,
    required this.user,
    required this.phone,
    required this.wishlistItems,
  });
}

class WishlistItemImage {
  final String imgUrl;
  final String productName;
  final int price;

  WishlistItemImage({
    required this.imgUrl,
    required this.productName,
    required this.price,
  });

  factory WishlistItemImage.fromMap(Map<String, dynamic> data) {
    final String? imageUrlFromData = data['img'] as String?;
    final String imageUrl = imageUrlFromData ?? ''; // Use the data directly
    final String? productName = data['productName'] as String?;
    final int price = data['price'] as int? ?? 0;

    return WishlistItemImage(
      imgUrl: imageUrl.trim(),
      productName: productName ?? '',
      price: price,
    );
  }

}

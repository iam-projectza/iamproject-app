import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:iam/src/widgets/small_text.dart';

import '../constants/colors.dart';
import '../controllers/single_product_controller.dart';
import '../model/single_product_model.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import 'big_text.dart';

class SingleProductCard extends StatelessWidget {
  final SingleProductModel product;
  final SingleProductController controller;

  const SingleProductCard({
    Key? key,
    required this.product,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe dimension values with fallbacks
    final width20 = Dimensions.width20 ?? 20.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;
    final radius15 = Dimensions.radius15 ?? 15.0;
    final listViewImgSize = Dimensions.listViewImgSize ?? 120.0;
    final iconSize24 = Dimensions.iconSize24 ?? 24.0;
    final height45 = Dimensions.height45 ?? 45.0;
    final font16 = Dimensions.font16 ?? 16.0;
    final font20 = Dimensions.font20 ?? 20.0;

    return Container(
      margin: EdgeInsets.only(
        left: width20,
        right: width20,
        bottom: height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: listViewImgSize,
            height: listViewImgSize,
            margin: EdgeInsets.all(height10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius15),
              color: AppColors.darkColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
              image: product.image != null && product.image!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(
                  '${AppConstants.BASE_URL}/${product.image!}',
                ),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: product.image == null || product.image!.isEmpty
                ? Icon(
              Icons.fastfood,
              color: AppColors.mainColor ?? Colors.orange,
              size: iconSize24,
            )
                : null,
          ),

          // Product Details
          Expanded(
            child: Container(
              padding: EdgeInsets.all(height10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name - Using BigText with ellipsis overflow
                  SizedBox(
                    width: double.maxFinite,
                    child: BigText(
                      text: product.name ?? 'Unknown Product',
                      size: font16,
                    ),
                  ),

                  Gap(height10),

                  // Product Description - Using SmallText with constrained height
                  Container(
                    height: height45, // Fixed height to limit lines
                    child: SmallText(
                      text: product.description ?? 'No description available',
                      size: font16,
                      color: AppColors.textColor ?? Colors.black54,
                    ),
                  ),

                  Gap(height10),

                  // Price and Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      BigText(
                        text: '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                        color: AppColors.mainColor ?? Colors.orange,
                        size: font20,
                      ),

                      // Add to Cart Button
                      Container(
                        width: height45,
                        height: height45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius15),
                          color: AppColors.mainColor ?? Colors.orange,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: iconSize24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
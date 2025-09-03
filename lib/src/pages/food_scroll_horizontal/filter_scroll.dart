import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../controllers/category_product_controller.dart';

class FilterScroll extends StatelessWidget {
  const FilterScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryProductController>(builder: (controller) {
      if (!controller.isLoaded) {
        return const Center(child: CircularProgressIndicator());
      }

      return SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoryProductList.length,
          itemBuilder: (context, index) {
            final category = controller.categoryProductList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FilterChip(
                side: BorderSide.none,
                label: Text(
                  category.name ?? 'No Name',
                  style: TextStyle(color: AppColors.mainBlackColor),
                ),
                onSelected: (_) {},
                selected: false,
                backgroundColor: const Color(0xfffaf1f0),
                selectedColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

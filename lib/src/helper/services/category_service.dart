import 'package:get/get.dart';
import '../../model/category_product_model.dart';

class CategoryService extends GetxController {  // CHANGE: GetxService → GetxController
  final Map<int, String> _categoryNames = {};
  final Map<String, int> _categoryIds = {};

  void loadCategories(List<CategoryModel> categories) {
    print('Loading ${categories.length} categories into service');
    _categoryNames.clear();
    _categoryIds.clear();

    for (var category in categories) {
      if (category.id != null && category.name != null) {
        _categoryNames[category.id!] = category.name!;
        _categoryIds[category.name!] = category.id!;
        print('Loaded category: ${category.id} -> ${category.name}');
      }
    }
    print('Total categories in service: ${_categoryNames.length}');
    update(); // ADD THIS: Notify listeners when categories are loaded
  }

  String getCategoryName(int? categoryId) {
    if (categoryId == null) {
      print('Category ID is null');
      return 'Uncategorized';
    }

    final name = _categoryNames[categoryId];
    print('Looking up category $categoryId -> $name');

    return name ?? 'Uncategorized';
  }

  int? getCategoryIdByName(String? categoryName) {
    if (categoryName == null) {
      print('Category name is null');
      return null;
    }

    final id = _categoryIds[categoryName];
    print('Looking up category "$categoryName" -> $id');

    if (id == null) {
      print('Category "$categoryName" not found in service. Available categories:');
      _categoryNames.forEach((id, name) => print('  $id: $name'));
    }

    return id;
  }

  @override
  void onClose() {
    _categoryNames.clear();
    _categoryIds.clear();
    super.onClose();
  }
}
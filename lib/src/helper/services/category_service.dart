import 'package:get/get.dart';
import '../../model/category_product_model.dart';

class CategoryService extends GetxController {
  final Map<int, String> _categoryNames = {};
  final Map<String, int> _categoryIds = {};

  bool get isLoaded => _categoryNames.isNotEmpty;

  void loadCategories(List<CategoryModel> categories) {
    print('Loading ${categories.length} categories into service');
    _categoryNames.clear();
    _categoryIds.clear();

    for (var category in categories) {
      if (category.id != null && category.name != null && category.name!.isNotEmpty) {
        _categoryNames[category.id!] = category.name!;
        _categoryIds[category.name!] = category.id!;
        print('Loaded category: ${category.id} -> ${category.name}');
      } else {
        print('Skipped invalid category: id=${category.id}, name=${category.name}');
      }
    }
    print('Total categories in service: ${_categoryNames.length}');
    update();
  }

  String getCategoryName(int? categoryId) {
    if (categoryId == null) {
      return 'Uncategorized';
    }
    return _categoryNames[categoryId] ?? 'Uncategorized';
  }

  int? getCategoryIdByName(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      return null;
    }
    return _categoryIds[categoryName];
  }

  @override
  void onClose() {
    _categoryNames.clear();
    _categoryIds.clear();
    super.onClose();
  }
}
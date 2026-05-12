import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  // 🔹 All products from DB (master copy)
  List<Product> _allProducts = [];

  // 🔹 Products shown on UI
  List<Product> _products = [];

  bool _loading = false;

  List<Product> get products => _products;
  bool get isLoading => _loading;

  // ================================
  // 🔥 FETCH PRODUCTS FROM DATABASE
  // ================================
  Future<void> fetchProducts([String? goal]) async {
    _loading = true;
    notifyListeners();

    try {
      final response = goal == null
          ? await supabase.from('products').select()
          : await supabase
              .from('products')
              .select()
              .eq('goal', goal);

      _allProducts = (response as List)
          .map((e) => Product.fromMap(e))
          .toList();

      // Initially show all
      _products = [..._allProducts];
    } catch (e) {
      debugPrint("❌ Product fetch error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  // ================================
  // 🔄 RESET PRODUCTS (Voice search uses this)
  // ================================
  void resetProducts() {
    _products = [..._allProducts];
    notifyListeners();
  }

  // ================================
  // 🔍 SEARCH PRODUCTS BY NAME
  // ================================
  void searchProducts(String query) {
  if (query.isEmpty) {
    resetProducts();
    return;
  }

  query = query.toLowerCase();

  _products = _allProducts.where((product) {
    return product.name.toLowerCase().contains(query) ||
           product.goal.toLowerCase().contains(query);
  }).toList();

  notifyListeners();
}


  // ================================
  // 🎯 FILTER PRODUCTS BY GOAL
  // ================================
  void filterByGoal(String goal) {
  goal = goal.toLowerCase();

  _products = _allProducts.where((product) {
    return product.goal.toLowerCase().contains(goal);
  }).toList();

  notifyListeners();
}

}

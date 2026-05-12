import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  final supabase = Supabase.instance.client; // ✅ Added to safely update quantities

  List<dynamic> _cartItems = [];
  List<dynamic> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ================= FETCH CART =================
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCartItems();
    } catch (e) {
      debugPrint("❌ Cart fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= ADD TO CART =================
  Future<void> addToCart(String productId) async {
    try {
      await _cartService.addToCart(
        productId: productId,
        quantity: 1,
      );
      await fetchCart();
    } catch (e) {
      debugPrint("❌ Add to cart error: $e");
    }
  }

  // ================= REMOVE ITEM =================
  Future<void> removeFromCart(String cartId) async {
    try {
      await _cartService.removeFromCart(cartId);
      await fetchCart();
    } catch (e) {
      debugPrint("❌ Remove cart item error: $e");
    }
  }

  // ================= UPDATE QUANTITY (✅ NEW FOR SWIGGY UI) =================
  Future<void> updateQuantity(String cartId, int newQuantity) async {
    if (newQuantity < 1) {
      // If quantity drops below 1, remove the item entirely
      await removeFromCart(cartId);
      return;
    }

    try {
      // Safely updating directly via Supabase so you don't need to edit CartService
      await supabase.from('cart').update({'quantity': newQuantity}).eq('id', cartId);
      await fetchCart(); // Refresh the cart to show new totals
    } catch (e) {
      debugPrint("❌ Update quantity error: $e");
    }
  }

  // ================= CLEAR CART =================
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cartItems = [];
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Clear cart error: $e");
    }
  }

  // ================= TOTAL ITEMS =================
  int get totalItems {
    int count = 0;
    for (var item in _cartItems) {
      count += (item['quantity'] ?? 1) as int;
    }
    return count;
  }

  // ================= TOTAL PRICE =================
  double get totalPrice {
    double total = 0;

    for (var item in _cartItems) {
      final product = item['products'];
      final quantity = item['quantity'] ?? 1;
      final price = product['price'] ?? 0;

      total += price * quantity;
    }

    return total;
  }
}
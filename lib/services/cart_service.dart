import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final supabase = Supabase.instance.client;

  // Add to Cart
  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) throw Exception("User not logged in");

    // Check if product already in cart
    final existing = await supabase
        .from('cart')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await supabase
          .from('cart')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      await supabase.from('cart').insert({
        'user_id': user.id,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  // Get Cart Items
  Future<List<dynamic>> getCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('cart')
        .select('*, products(*)')
        .eq('user_id', user.id);

    return response;
  }

  // Remove Item
  Future<void> removeFromCart(String cartId) async {
    await supabase.from('cart').delete().eq('id', cartId);
  }

  // Clear Cart
  Future<void> clearCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('cart').delete().eq('user_id', user.id);
  }
}

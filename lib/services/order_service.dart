import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<void> placeOrder({
  required List<dynamic> cartItems,
  required double totalAmount,
  required String addressId,
  required String paymentMethod,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final order = await supabase.from('orders').insert({
    'user_id': user.id,
    'total_amount': totalAmount,
    'address_id': addressId,
    'payment_method': paymentMethod,
    'status': 'placed',
  }).select().single();

  for (var item in cartItems) {
  final product = item['products'];

  await supabase.from('order_items').insert({
    'order_id': order['id'],
    'product_id': item['product_id'],
    'quantity': item['quantity'],
    'price': product['price'],   // ✅ FIX ADDED
  });
}




    // 3️⃣ Clear Cart
    await supabase.from('cart').delete().eq('user_id', user.id);
  }
}

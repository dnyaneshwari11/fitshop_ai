import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> address;

  const OrderSummaryScreen({super.key, required this.address});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool isPlacingOrder = false;

  // Premium Colors
  static const Color primaryOrange = Color(0xFFFC8019);
  static const Color bgColor = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Bill Calculation (Strictly Item Total only for self-pickup)
    double grandTotal = cart.totalPrice;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Order Summary", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. PICKUP DETAILS SECTION
            _buildSectionHeader("PICKUP DETAILS"),
            _buildPickupCard(),

            // 2. ITEMS SECTION
            _buildSectionHeader("ITEMS ORDERED"),
            _buildItemsCard(cart),

            // 3. PAYMENT METHOD (Hardcoded to Pay at Shop / COD)
            _buildSectionHeader("PAYMENT METHOD"),
            _buildPaymentMethod(),

            // 4. BILL DETAILS (No Fees)
            _buildSectionHeader("BILL DETAILS"),
            _buildBillDetails(grandTotal),
            
            const SizedBox(height: 120), // Space for bottom bar
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(grandTotal, cart),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2),
      ),
    );
  }

  // Adapted for Takeaway: Shows who the order is for and reminds them to pick it up
  Widget _buildPickupCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront_outlined, color: primaryOrange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Store Pickup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "Customer: ${widget.address['name'] ?? 'User'}",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "Phone: ${widget.address['phone'] ?? 'N/A'}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.orange.shade800),
                      const SizedBox(width: 6),
                      Text(
                        "Please collect your order from the shop.",
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(CartProvider cart) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cart.cartItems.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
        itemBuilder: (context, index) {
          final item = cart.cartItems[index];
          final product = item['products'] ?? {};
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Veg Indicator
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 1), borderRadius: BorderRadius.circular(2)),
                  child: const CircleAvatar(radius: 3, backgroundColor: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ),
                Text("x${item['quantity']}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 16),
                Text("₹${(product['price'] * item['quantity'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Renamed from "Cash on Delivery" to "Pay at Shop"
  Widget _buildPaymentMethod() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.store, color: Colors.green.shade600),
          const SizedBox(width: 12),
          const Text(
            "Pay at Shop (Cash/UPI)",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          const Icon(Icons.check_circle, color: primaryOrange, size: 20),
        ],
      ),
    );
  }

  // Cleanest Bill Details: Just the total
  Widget _buildBillDetails(double total) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Item Total", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Text("₹$total", style: const TextStyle(fontSize: 14)),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TO PAY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹$total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(double total, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("FINAL AMOUNT", style: TextStyle(fontSize: 10, color: primaryOrange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: isPlacingOrder ? null : () => _handlePlaceOrder(cart, total),
                child: isPlacingOrder 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("CONFIRM ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(CartProvider cart, double total) async {
    setState(() => isPlacingOrder = true);

    try {
      await OrderService().placeOrder(
        cartItems: cart.cartItems,
        totalAmount: total,
        addressId: widget.address['id'],
        paymentMethod: "SHOP_PAYMENT", // Updated to reflect reality
      );

      await cart.clearCart();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order confirmed! See you at the shop."),
          backgroundColor: Colors.green,
        )
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }
}
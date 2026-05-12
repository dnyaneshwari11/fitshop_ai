import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final Map order;

  const AdminOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState
    extends State<AdminOrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic>? addressData;

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;

  // ================= COLORS =================

  static const Color orange = Color(0xFFFF8A00);
  static const Color lightOrange = Color(0xFFFFB347);
  static const Color green = Color(0xFF34C759);
  static const Color bg = Color(0xFFFFFAF5);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    loadAllData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= LOAD DATA =================

  Future<void> loadAllData() async {
    try {
      final order = widget.order;

      debugPrint("ORDER DATA => $order");

      // ================= FETCH ORDER ITEMS =================

      final List<dynamic> itemsResponse = await supabase
          .from('order_items')
          .select()
          .eq('order_id', order['id']);

      debugPrint("RAW ORDER ITEMS => $itemsResponse");

      List<Map<String, dynamic>> loadedItems = [];

      for (var item in itemsResponse) {
        final itemMap = Map<String, dynamic>.from(item);

        Map<String, dynamic>? productData;

        try {
          final productId =
              itemMap['product_id']?.toString();

          debugPrint(
            "FETCHING PRODUCT ID => $productId",
          );

          if (productId != null &&
              productId.isNotEmpty) {
            final List<dynamic> productResponse =
                await supabase
                    .from('products')
                    .select('id,name')
                    .eq('id', productId)
                    .limit(1);

            debugPrint(
              "PRODUCT RESPONSE => $productResponse",
            );

            if (productResponse.isNotEmpty) {
              productData =
                  Map<String, dynamic>.from(
                productResponse.first,
              );
            }
          }
        } catch (e) {
          debugPrint(
            "PRODUCT FETCH ERROR => $e",
          );
        }

        loadedItems.add({
          ...itemMap,
          'product': productData,
        });
      }

      // ================= FETCH ADDRESS =================

      Map<String, dynamic>? address;

      try {
        final addressId =
            order['address_id']?.toString();

        debugPrint(
          "ADDRESS ID => $addressId",
        );

        if (addressId != null &&
            addressId.isNotEmpty) {
          final List<dynamic> addressResponse =
              await supabase
                  .from('addresses')
                  .select()
                  .eq('id', addressId)
                  .limit(1);

          debugPrint(
            "ADDRESS RESPONSE => $addressResponse",
          );

          if (addressResponse.isNotEmpty) {
            address =
                Map<String, dynamic>.from(
              addressResponse.first,
            );
          }
        }
      } catch (e) {
        debugPrint(
          "ADDRESS FETCH ERROR => $e",
        );
      }

      debugPrint(
        "FINAL ORDER ITEMS => $loadedItems",
      );

      if (!mounted) return;

      setState(() {
        orderItems = loadedItems;
        addressData = address;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("MAIN ERROR => $e");

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ================= TOTAL =================

  double calculateGrandTotal() {
    double total = 0;

    for (var item in orderItems) {
      final qty = item['quantity'] ?? 0;

      final price =
          double.tryParse(item['price'].toString()) ?? 0;

      total += qty * price;
    }

    return total;
  }

  // ================= STATUS COLOR =================

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return green;

      case "cancelled":
        return Colors.red;

      case "processing":
        return Colors.blue;

      default:
        return orange;
    }
  }

  // ================= GLASS CARD =================

  Widget glassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.80),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ================= INFO ROW =================

  Widget infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                orange,
                lightOrange,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ================= PRODUCT CARD =================

  Widget productCard(Map<String, dynamic> item) {
    final qty = item['quantity'] ?? 0;

    final price =
        double.tryParse(item['price'].toString()) ?? 0;

    final subtotal = qty * price;

    final product = item['product'];

    final productName =
        product != null && product['name'] != null
            ? product['name'].toString()
            : "Product Not Found";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  orange,
                  lightOrange,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Qty: $qty × ₹$price",
                  style: TextStyle(
                    color:
                        Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "₹${subtotal.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FULL ADDRESS =================

  String buildFullAddress() {
    if (addressData == null) return "";

    final houseNo =
        addressData!['house_no']?.toString() ?? '';

    final area =
        addressData!['area']?.toString() ?? '';

    final landmark =
        addressData!['landmark']?.toString() ?? '';

    final city =
        addressData!['city']?.toString() ?? '';

    final pincode =
        addressData!['pincode']?.toString() ?? '';

    return [
      if (houseNo.isNotEmpty) "House No: $houseNo",
      if (area.isNotEmpty) area,
      if (landmark.isNotEmpty)
        "Landmark: $landmark",
      if (city.isNotEmpty) city,
      if (pincode.isNotEmpty) pincode,
    ].join(", ");
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final status =
        order['status']?.toString() ?? "Placed";

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ================= BACKGROUND =================

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 +
                        (_animationController.value * 30),
                    left: -80 +
                        (_animationController.value * 20),
                    child: Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: orange.withOpacity(0.15),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -120 +
                        (_animationController.value * 40),
                    right: -90 +
                        (_animationController.value * 20),
                    child: Container(
                      height: 320,
                      width: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: green.withOpacity(0.10),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ================= BODY =================

          SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: orange,
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Text(
                          "Error: $errorMessage",
                        ),
                      )
                    : SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // ================= HEADER =================

                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(
                                              18),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .arrow_back_ios_new_rounded,
                                      color:
                                          Colors.black87,
                                    ),
                                  ),
                                ),

                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      "Order Details",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),

                                Container(width: 52),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ================= ORDER SUMMARY =================

                            glassCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 72,
                                        width: 72,
                                        decoration:
                                            BoxDecoration(
                                          gradient:
                                              const LinearGradient(
                                            colors: [
                                              orange,
                                              lightOrange,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      24),
                                        ),
                                        child: const Icon(
                                          Icons
                                              .shopping_bag_rounded,
                                          color:
                                              Colors.white,
                                          size: 34,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 18),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            const Text(
                                              "Order Summary",
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    22,
                                                fontWeight:
                                                    FontWeight
                                                        .w900,
                                              ),
                                            ),

                                            const SizedBox(
                                                height: 8),

                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                horizontal:
                                                    14,
                                                vertical: 8,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color: getStatusColor(
                                                        status)
                                                    .withOpacity(
                                                        0.12),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            30),
                                              ),
                                              child: Text(
                                                status,
                                                style:
                                                    TextStyle(
                                                  color:
                                                      getStatusColor(
                                                          status),
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 26),

                                  infoRow(
                                    "Order ID",
                                    order['id']
                                        .toString(),
                                  ),

                                  infoRow(
                                    "Payment",
                                    order['payment_method']
                                            ?.toString() ??
                                        "N/A",
                                  ),

                                  infoRow(
                                    "Stored Total",
                                    "₹${order['total_amount'] ?? 0}",
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ================= ADDRESS =================

                            glassCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  sectionTitle(
                                    "Delivery Address",
                                    Icons
                                        .location_on_rounded,
                                  ),

                                  const SizedBox(
                                      height: 24),

                                  if (addressData == null)
                                    const Text(
                                      "No Address Found",
                                    )
                                  else ...[
                                    infoRow(
                                      "Receiver",
                                      addressData!['name']
                                              ?.toString() ??
                                          '',
                                    ),

                                    infoRow(
                                      "Phone",
                                      addressData![
                                                  'phone']
                                              ?.toString() ??
                                          '',
                                    ),

                                    infoRow(
                                      "Type",
                                      addressData![
                                                  'address_type']
                                              ?.toString() ??
                                          '',
                                    ),

                                    infoRow(
                                      "Full Address",
                                      buildFullAddress(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ================= PRODUCTS =================

                            glassCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  sectionTitle(
                                    "Products",
                                    Icons
                                        .restaurant_menu_rounded,
                                  ),

                                  const SizedBox(
                                      height: 24),

                                  if (orderItems.isEmpty)
                                    const Text(
                                      "No Products Found",
                                    )
                                  else
                                    ...orderItems.map(
                                      (item) =>
                                          productCard(
                                              item),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ================= GRAND TOTAL =================

                            glassCard(
                              child: Row(
                                children: [
                                  Container(
                                    height: 74,
                                    width: 74,
                                    decoration:
                                        BoxDecoration(
                                      gradient:
                                          const LinearGradient(
                                        colors: [
                                          green,
                                          Color(
                                              0xFF63E283),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  24),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .currency_rupee_rounded,
                                      color:
                                          Colors.white,
                                      size: 34,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 18),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          "Grand Total",
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .black
                                                .withOpacity(
                                                    0.55),
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        Text(
                                          "₹${calculateGrandTotal().toStringAsFixed(2)}",
                                          style:
                                              const TextStyle(
                                            fontSize: 30,
                                            fontWeight:
                                                FontWeight
                                                    .w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
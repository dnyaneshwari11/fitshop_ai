import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailsScreen extends StatefulWidget {
  final dynamic orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  Map<String, dynamic>? order;
  List<dynamic> items = [];
  bool isLoading = true;

  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color green =
      Color(0xFF2ECC71);

  static const Color lightGreen =
      Color(0xFFEAFBF1);

  static const Color darkGreen =
      Color(0xFF15803D);

  static const Color white =
      Colors.white;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10),
    )..repeat(reverse: true);

    loadOrderDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= LOAD DATA =================

  Future<void> loadOrderDetails() async {
    try {
      final orderData = await supabase
          .from('orders')
          .select()
          .eq('id', widget.orderId)
          .single();

      final orderItems = await supabase
          .from('order_items')
          .select('*, products(name)')
          .eq(
            'order_id',
            widget.orderId,
          );

      final addressData = await supabase
          .from('addresses')
          .select()
          .eq(
            'id',
            orderData['address_id'],
          )
          .single();

      if (mounted) {
        setState(() {
          order = orderData;
          items = orderItems;
          order!['addresses'] =
              addressData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(
        "Error loading order details: $e",
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= ADDRESS =================

  String _getSafeAddress(
    Map<String, dynamic> addr,
  ) {
    List<String> addressParts = [
      addr['house_no']
              ?.toString() ??
          '',
      addr['area']?.toString() ??
          '',
      addr['landmark']
              ?.toString() ??
          '',
    ];

    addressParts.removeWhere(
      (e) =>
          e.trim().isEmpty ||
          e.toLowerCase() ==
              'null' ||
          e.toUpperCase() == 'n/a',
    );

    String streetPart =
        addressParts.isNotEmpty
            ? "${addressParts.join(', ')}\n"
            : "";

    return "$streetPart${addr['city'] ?? ''} - ${addr['pincode'] ?? ''}";
  }

  // ================= STATUS COLOR =================

  Color _getStatusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.orange;

      case 'preparing':
        return Colors.orange;

      case 'ready':
        return green;

      case 'completed':
        return darkGreen;

      default:
        return green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: lightGreen,
        body: Center(
          child:
              CircularProgressIndicator(
            color: green,
          ),
        ),
      );
    }

    if (order == null) {
      return const Scaffold(
        backgroundColor: lightGreen,
        body: Center(
          child: Text(
            "Failed to load order",
            style: TextStyle(
              color: darkGreen,
            ),
          ),
        ),
      );
    }

    final address =
        order!['addresses'];

    final statusColor =
        _getStatusColor(
      order!['status'] ?? 'Placed',
    );

    return Scaffold(
      backgroundColor: lightGreen,

      body: Stack(
        children: [

          // ================= ANIMATED BG =================

          AnimatedBuilder(
            animation:
                _animationController,
            builder:
                (context, child) {
              return Stack(
                children: [

                  Positioned(
                    top:
                        -120 +
                            (_animationController.value *
                                40),
                    left:
                        -80 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 260,
                      width: 260,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: green
                            .withOpacity(
                          0.18,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom:
                        -140 +
                            (_animationController.value *
                                40),
                    right:
                        -100 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 300,
                      width: 300,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: green
                            .withOpacity(
                          0.12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ================= CONTENT =================

          SafeArea(
            child: ListView(
              physics:
                  const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                20,
              ),
              children: [

                // ================= TOP =================

                Row(
                  children: [

                    _glassIcon(
                      Icons
                          .arrow_back_ios_new_rounded,
                      onTap: () {
                        Navigator.pop(
                            context);
                      },
                    ),

                    const Spacer(),

                    const Text(
                      "Order Details",
                      style: TextStyle(
                        color:
                            darkGreen,
                        fontSize: 24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const Spacer(),

                    const SizedBox(
                      width: 52,
                    ),
                  ],
                ),

                const SizedBox(
                    height: 28),

                // ================= STATUS CARD =================

                _glassCard(
                  child: Column(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor
                                  .withOpacity(
                            0.15,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                        child: Text(
                          (order!['status'] ??
                                  'Placed')
                              .toString()
                              .toUpperCase(),
                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontWeight:
                                FontWeight
                                    .w700,
                            letterSpacing:
                                1,
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      Text(
                        "Order #${order!['id'].toString().substring(0, 8).toUpperCase()}",
                        style: TextStyle(
                          color: darkGreen
                              .withOpacity(
                            0.6,
                          ),
                          fontSize: 13,
                          letterSpacing:
                              1,
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      Text(
                        "₹${order!['total_amount']}",
                        style:
                            const TextStyle(
                          color:
                              darkGreen,
                          fontSize: 40,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        "${items.length} Items",
                        style: TextStyle(
                          color: darkGreen
                              .withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 20),

                // ================= ITEMS =================

                _glassCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      const Row(
                        children: [

                          Icon(
                            Icons
                                .shopping_bag_rounded,
                            color:
                                green,
                            size: 20,
                          ),

                          SizedBox(
                              width:
                                  10),

                          Text(
                            "Items Ordered",
                            style:
                                TextStyle(
                              color: darkGreen,
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 24),

                      ...items.map(
                        (item) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom:
                                  18,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(
                                14,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: green
                                    .withOpacity(
                                  0.05,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                                border:
                                    Border.all(
                                  color: green
                                      .withOpacity(
                                    0.08,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [

                                  Container(
                                    height:
                                        42,
                                    width:
                                        42,
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                      gradient:
                                          const LinearGradient(
                                        colors: [
                                          green,
                                          darkGreen,
                                        ],
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .eco_rounded,
                                      color:
                                          Colors.white,
                                      size:
                                          20,
                                    ),
                                  ),

                                  const SizedBox(
                                      width:
                                          14),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          item['products']['name'] ??
                                              'Item',
                                          style:
                                              const TextStyle(
                                            color:
                                                darkGreen,
                                            fontSize:
                                                15,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                6),

                                        Text(
                                          "Quantity : ${item['quantity']}",
                                          style:
                                              TextStyle(
                                            color: darkGreen
                                                .withOpacity(
                                              0.6,
                                            ),
                                            fontSize:
                                                13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    "₹${item['price']}",
                                    style:
                                        const TextStyle(
                                      color:
                                          green,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Divider(
                        color: green
                            .withOpacity(
                          0.15,
                        ),
                      ),

                      const SizedBox(
                          height: 14),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [

                          Text(
                            "Total Amount",
                            style: TextStyle(
                              color: darkGreen
                                  .withOpacity(
                                0.7,
                              ),
                              fontSize: 15,
                            ),
                          ),

                          Text(
                            "₹${order!['total_amount']}",
                            style:
                                const TextStyle(
                              color:
                                  green,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 20),

                // ================= ADDRESS =================

                _glassCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      const Row(
                        children: [

                          Icon(
                            Icons
                                .location_on_rounded,
                            color:
                                green,
                            size: 20,
                          ),

                          SizedBox(
                              width:
                                  10),

                          Text(
                            "Delivery Details",
                            style:
                                TextStyle(
                              color: darkGreen,
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 22),

                      Container(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: green
                              .withOpacity(
                            0.05,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              address['name'] ??
                                  'Customer',
                              style:
                                  const TextStyle(
                                color:
                                    darkGreen,
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                                height: 12),

                            Text(
                              _getSafeAddress(
                                  address),
                              style:
                                  TextStyle(
                                color: darkGreen
                                    .withOpacity(
                                  0.7,
                                ),
                                fontSize:
                                    14,
                                height:
                                    1.6,
                              ),
                            ),

                            const SizedBox(
                                height: 18),

                            Row(
                              children: [

                                Container(
                                  height:
                                      34,
                                  width:
                                      34,
                                  decoration:
                                      BoxDecoration(
                                    color: green
                                        .withOpacity(
                                      0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .call_rounded,
                                    color:
                                        green,
                                    size:
                                        18,
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        12),

                                Text(
                                  address['phone'] ??
                                      'N/A',
                                  style:
                                      const TextStyle(
                                    color:
                                        darkGreen,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= GLASS CARD =================

  Widget _glassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(
            22,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.75),
            borderRadius:
                BorderRadius.circular(
              30,
            ),
            border: Border.all(
              color: green
                  .withOpacity(
                0.10,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: green
                    .withOpacity(0.08),
                blurRadius: 20,
                offset:
                    const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ================= GLASS ICON =================

  Widget _glassIcon(
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            height: 52,
            width: 52,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(
                0.75,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: green
                    .withOpacity(
                  0.10,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: darkGreen,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
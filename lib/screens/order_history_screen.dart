import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({
    super.key,
  });

  @override
  State<OrderHistoryScreen>
      createState() =>
          _OrderHistoryScreenState();
}

class _OrderHistoryScreenState
    extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  List<dynamic> orders = [];
  bool isLoading = true;

  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color green =
      Color(0xFF22C55E);

  static const Color lightGreen =
      Color(0xFFDCFCE7);

  static const Color white =
      Colors.white;

  static const Color darkGreen =
      Color(0xFF15803D);

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10),
    )..repeat(reverse: true);

    loadOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= LOAD ORDERS =================

  Future<void> loadOrders() async {
    final user =
        supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order(
          'created_at',
          ascending: false,
        );

    if (mounted) {
      setState(() {
        orders = data;
        isLoading = false;
      });
    }
  }

  // ================= SHORT ID =================

  String _getShortOrderId(
    String uuid,
  ) {
    if (uuid.length < 8) {
      return uuid.toUpperCase();
    }

    return uuid
        .substring(0, 8)
        .toUpperCase();
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
        return green;

      default:
        return green;
    }
  }

  // ================= DATE =================

  String _formatDate(
    String isoString,
  ) {
    try {
      final date =
          DateTime.parse(
        isoString,
      ).toLocal();

      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Date unavailable";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      body: Stack(
        children: [

          // ================= BACKGROUND =================

          AnimatedBuilder(
            animation:
                _animationController,
            builder:
                (context, child) {
              return Stack(
                children: [

                  Positioned(
                    top:
                        -140 +
                            (_animationController.value *
                                40),
                    left:
                        -100 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 280,
                      width: 280,
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
                        -160 +
                            (_animationController.value *
                                40),
                    right:
                        -120 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 320,
                      width: 320,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: lightGreen
                            .withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ================= MAIN =================

          SafeArea(
            child: Column(
              children: [

                // ================= TOP BAR =================

                Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Row(
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
                        "My Orders",
                        style:
                            TextStyle(
                          color:
                              darkGreen,
                          fontSize:
                              24,
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
                ),

                // ================= BODY =================

                Expanded(
                  child: isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                green,
                          ),
                        )
                      : orders.isEmpty
                          ? Center(
                              child:
                                  Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  Icon(
                                    Icons
                                        .receipt_long_rounded,
                                    color:
                                        green
                                            .withOpacity(
                                      0.5,
                                    ),
                                    size: 70,
                                  ),

                                  const SizedBox(
                                      height:
                                          18),

                                  const Text(
                                    "No Orders Found",
                                    style:
                                        TextStyle(
                                      color:
                                          darkGreen,
                                      fontSize:
                                          20,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics:
                                  const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                30,
                              ),
                              itemCount:
                                  orders.length,
                              separatorBuilder:
                                  (
                                context,
                                index,
                              ) =>
                                      const SizedBox(
                                height:
                                    18,
                              ),
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final order =
                                    orders[
                                        index];

                                final statusColor =
                                    _getStatusColor(
                                  order['status'] ??
                                      'Placed',
                                );

                                return GestureDetector(
                                  onTap:
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                OrderDetailsScreen(
                                          orderId:
                                              order['id'],
                                        ),
                                      ),
                                    );
                                  },

                                  child:
                                      _glassCard(
                                    child:
                                        Column(
                                      children: [

                                        // ================= TOP =================

                                        Row(
                                          children: [

                                            Container(
                                              height:
                                                  56,
                                              width:
                                                  56,
                                              decoration:
                                                  BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  18,
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
                                                    .shopping_bag_rounded,
                                                color:
                                                    Colors.white,
                                              ),
                                            ),

                                            const SizedBox(
                                                width:
                                                    16),

                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [

                                                  Text(
                                                    "Order #${_getShortOrderId(order['id'])}",
                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          darkGreen,
                                                      fontSize:
                                                          16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height:
                                                          6),

                                                  Text(
                                                    _formatDate(
                                                      order['created_at'],
                                                    ),
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.black54,
                                                      fontSize:
                                                          13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    14,
                                                vertical:
                                                    8,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    statusColor.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  30,
                                                ),
                                              ),
                                              child:
                                                  Text(
                                                (order['status'] ??
                                                        'Placed')
                                                    .toString()
                                                    .toUpperCase(),
                                                style:
                                                    TextStyle(
                                                  color:
                                                      statusColor,
                                                  fontSize:
                                                      11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  letterSpacing:
                                                      1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                            height:
                                                24),

                                        Divider(
                                          color:
                                              green
                                                  .withOpacity(
                                            0.15,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                18),

                                        // ================= PRICE =================

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "Total Amount",
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.black54,
                                                    fontSize:
                                                        13,
                                                  ),
                                                ),

                                                const SizedBox(
                                                    height:
                                                        6),

                                                Text(
                                                  "₹${order['total_amount']}",
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        darkGreen,
                                                    fontSize:
                                                        28,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    18,
                                                vertical:
                                                    12,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  18,
                                                ),
                                              ),
                                              child:
                                                  Row(
                                                children: [

                                                  const Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    color:
                                                        green,
                                                    size:
                                                        16,
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          8),

                                                  const Text(
                                                    "View",
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          darkGreen,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
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
          BorderRadius.circular(
        30,
      ),
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
                .withOpacity(
              0.75,
            ),
            borderRadius:
                BorderRadius.circular(
              30,
            ),
            border: Border.all(
              color: green
                  .withOpacity(
                0.15,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    green.withOpacity(
                  0.08,
                ),
                blurRadius: 18,
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

  // ================= ICON =================

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
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color:
                    green.withOpacity(
                  0.15,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      green.withOpacity(
                    0.08,
                  ),
                  blurRadius: 10,
                ),
              ],
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
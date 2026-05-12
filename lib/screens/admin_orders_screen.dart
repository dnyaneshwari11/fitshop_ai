import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends State<AdminOrdersScreen>
    with TickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  List orders = [];
  bool isLoading = true;

  // ✅ FIXED ERROR
  late final AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color orange =
      Color(0xFFFF8A00);

  static const Color lightOrange =
      Color(0xFFFFB347);

  static const Color green =
      Color(0xFF34C759);

  @override
  void initState() {
    super.initState();

    // ✅ INITIALIZED PROPERLY
    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 8),
    )..repeat(reverse: true);

    fetchOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final data = await supabase
        .from('orders')
        .select()
        .order(
          'created_at',
          ascending: false,
        );

    if (!mounted) return;

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  Future<void> updateStatus(
    String id,
    String status,
  ) async {
    await supabase
        .from('orders')
        .update({
          'status': status,
        })
        .eq('id', id);

    fetchOrders();
  }

  Future<void> deleteOrder(
    String id,
  ) async {
    await supabase
        .from('orders')
        .delete()
        .eq('id', id);

    fetchOrders();
  }

  Color getStatusColor(
    String status,
  ) {
    switch (status) {
      case "Completed":
        return green;

      case "Cancelled":
        return Colors.red;

      case "Processing":
        return Colors.blue;

      default:
        return orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAF5),

      body: Stack(
        children: [

          // ================= ANIMATED BACKGROUND =================

          AnimatedBuilder(
            animation:
                _animationController,

            builder:
                (
                  context,
                  child,
                ) {
              return Stack(
                children: [

                  Positioned(
                    top:
                        -120 +
                            (_animationController.value *
                                40),

                    left:
                        -90 +
                            (_animationController.value *
                                30),

                    child: Container(
                      height: 260,
                      width: 260,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            orange
                                .withOpacity(
                          0.15,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 220,

                    right:
                        -80 +
                            (_animationController.value *
                                20),

                    child: Container(
                      height: 220,
                      width: 220,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            green
                                .withOpacity(
                          0.10,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom:
                        -140 +
                            (_animationController.value *
                                30),

                    right:
                        -100 +
                            (_animationController.value *
                                20),

                    child: Container(
                      height: 300,
                      width: 300,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            lightOrange
                                .withOpacity(
                          0.14,
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

                // ================= HEADER =================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),

                  child: Row(
                    children: [

                      // BACK BUTTON

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child:
                            _glassIcon(
                          Icons
                              .arrow_back_ios_new_rounded,
                        ),
                      ),

                      const Spacer(),

                      // TITLE

                      Column(
                        children: [

                          Container(
                            height: 58,
                            width: 58,

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
                                  BorderRadius.circular(
                                18,
                              ),

                              boxShadow: [

                                BoxShadow(
                                  color: orange
                                      .withOpacity(
                                    0.25,
                                  ),

                                  blurRadius: 18,
                                  offset:
                                      const Offset(
                                    0,
                                    8,
                                  ),
                                ),
                              ],
                            ),

                            child:
                                const Icon(
                              Icons
                                  .receipt_long_rounded,

                              color:
                                  Colors.white,

                              size: 30,
                            ),
                          ),

                          const SizedBox(
                              height: 14),

                          const Text(
                            "Manage Orders",

                            style:
                                TextStyle(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              color:
                                  Colors.black,
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          Text(
                            "Track customer orders professionally",

                            style:
                                TextStyle(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.55,
                              ),

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      _glassIcon(
                        Icons
                            .shopping_bag_rounded,
                      ),
                    ],
                  ),
                ),

                // ================= BODY =================

                Expanded(
                  child:
                      isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    green,
                              ),
                            )
                          : orders
                                  .isEmpty
                              ? _emptyWidget()
                              : ListView.builder(
                                  physics:
                                      const BouncingScrollPhysics(),

                                  padding:
                                      const EdgeInsets.only(
                                    left:
                                        20,
                                    right:
                                        20,
                                    bottom:
                                        30,
                                  ),

                                  itemCount:
                                      orders.length,

                                  itemBuilder:
                                      (
                                        context,
                                        index,
                                      ) {
                                    final order =
                                        orders[index];

                                    final status =
                                        order['status'] ??
                                            "Placed";

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom:
                                            20,
                                      ),

                                      child:
                                          _orderCard(
                                        order:
                                            order,
                                        status:
                                            status,
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

  // ================= ORDER CARD =================

  Widget _orderCard({
    required Map order,
    required String status,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder:
                (_) =>
                    AdminOrderDetailsScreen(
              order: order,
            ),
          ),
        );
      },

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          30,
        ),

        child: BackdropFilter(
          filter:
              ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),

          child: Container(
            padding:
                const EdgeInsets.all(
              24,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                0.78,
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              border: Border.all(
                color:
                    Colors.white
                        .withOpacity(
                  0.8,
                ),
              ),

              boxShadow: [

                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.05,
                  ),

                  blurRadius: 18,

                  offset:
                      const Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),

            child: Column(
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
                            BorderRadius.circular(
                          24,
                        ),
                      ),

                      child:
                          const Icon(
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

                          Text(
                            "Order #${order['id'].toString().substring(0, 6)}",

                            style:
                                const TextStyle(
                              fontSize:
                                  19,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          Text(
                            "₹${order['total_amount']}",

                            style:
                                TextStyle(
                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight
                                      .w600,

                              color: Colors
                                  .black
                                  .withOpacity(
                                0.65,
                              ),
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
                            getStatusColor(
                          status,
                        ).withOpacity(
                          0.14,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Text(
                        status,

                        style:
                            TextStyle(
                          color:
                              getStatusColor(
                            status,
                          ),

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 24),

                Row(
                  children: [

                    Expanded(
                      child:
                          PopupMenuButton<
                              String>(
                        onSelected:
                            (
                              value,
                            ) {
                          updateStatus(
                            order['id'],
                            value,
                          );
                        },

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),

                        child:
                            Container(
                          height: 54,

                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                green,
                                Color(
                                  0xFF67D67C,
                                ),
                              ],
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),

                          child:
                              const Center(
                            child:
                                Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons
                                      .edit_rounded,

                                  color:
                                      Colors.white,

                                  size:
                                      20,
                                ),

                                SizedBox(
                                    width:
                                        10),

                                Text(
                                  "Update Status",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        itemBuilder:
                            (
                              context,
                            ) => const [

                          PopupMenuItem(
                            value:
                                "Placed",
                            child: Text(
                              "Placed",
                            ),
                          ),

                          PopupMenuItem(
                            value:
                                "Processing",
                            child: Text(
                              "Processing",
                            ),
                          ),

                          PopupMenuItem(
                            value:
                                "Completed",
                            child: Text(
                              "Completed",
                            ),
                          ),

                          PopupMenuItem(
                            value:
                                "Cancelled",
                            child: Text(
                              "Cancelled",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        width: 14),

                    GestureDetector(
                      onTap: () {
                        deleteOrder(
                          order['id'],
                        );
                      },

                      child: Container(
                        height: 54,
                        width: 58,

                        decoration:
                            BoxDecoration(
                          color: Colors.red
                              .withOpacity(
                            0.10,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .delete_outline_rounded,

                          color:
                              Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Container(
            height: 120,
            width: 120,

            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  orange
                      .withOpacity(
                    0.15,
                  ),

                  green
                      .withOpacity(
                    0.10,
                  ),
                ],
              ),

              shape:
                  BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .shopping_bag_outlined,

              size: 60,

              color: orange,
            ),
          ),

          const SizedBox(
              height: 24),

          const Text(
            "No Orders Found",

            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
              height: 10),

          Text(
            "Orders will appear here once customers place orders.",

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: Colors.black
                  .withOpacity(
                0.55,
              ),

              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ICON =================

  Widget _glassIcon(
    IconData icon,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        18,
      ),

      child: BackdropFilter(
        filter:
            ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),

        child: Container(
          height: 54,
          width: 54,

          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(
              0.72,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border: Border.all(
              color: Colors.white
                  .withOpacity(
                0.7,
              ),
            ),
          ),

          child: Icon(
            icon,

            color: orange,

            size: 24,
          ),
        ),
      ),
    );
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';

import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'login.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  int totalProducts = 0;
  int totalOrders = 0;
  double totalRevenue = 0;

  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color orange =
      Color(0xFFFF8A00);

  static const Color lightOrange =
      Color(0xFFFFB347);

  static const Color green =
      Color(0xFF34C759);

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

    loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    final products =
        await supabase
            .from('products')
            .select();

    final orders =
        await supabase
            .from('orders')
            .select();

    double revenue = 0;

    for (var order in orders) {
      revenue +=
          (order['total_price'] ?? 0);
    }

    if (!mounted) return;

    setState(() {
      totalProducts =
          products.length;

      totalOrders =
          orders.length;

      totalRevenue = revenue;
    });
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
                (context, child) {
              return Stack(
                children: [

                  Positioned(
                    top:
                        -120 +
                            (_animationController.value *
                                30),

                    left:
                        -80 +
                            (_animationController.value *
                                20),

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
                          0.18,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 220,

                    right:
                        -70 +
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
                                40),

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
                          0.16,
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
            child:
                SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                22,
              ),

              child: Column(
                children: [

                  // ================= TOP BAR =================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      // LEFT SPACE
                      const SizedBox(
                        width: 54,
                      ),

                      // CENTER HEADING

                      Expanded(
                        child: Column(
                          children: [

                            Container(
                              height: 74,
                              width: 74,

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

                                boxShadow: [

                                  BoxShadow(
                                    color: orange
                                        .withOpacity(
                                      0.30,
                                    ),

                                    blurRadius:
                                        25,

                                    offset:
                                        const Offset(
                                      0,
                                      10,
                                    ),
                                  ),
                                ],
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .storefront_rounded,

                                color:
                                    Colors.white,

                                size: 38,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    16),

                            const Text(
                              "PURE LEAF",

                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  TextStyle(
                                color:
                                    Colors.black,

                                fontSize:
                                    30,

                                fontWeight:
                                    FontWeight
                                        .w900,

                                letterSpacing:
                                    1,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    8),

                            Text(
                              "Admin Dashboard",

                              style:
                                  TextStyle(
                                color:
                                    Colors.black
                                        .withOpacity(
                                  0.55,
                                ),

                                fontSize:
                                    15,

                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LOGOUT

                      GestureDetector(
                        onTap: () async {
                          await context
                              .read<
                                  AuthProvider>()
                              .logout();

                          if (!context
                              .mounted) {
                            return;
                          }

                          Navigator.pushAndRemoveUntil(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      LoginScreen(),
                            ),

                            (
                              route,
                            ) =>
                                false,
                          );
                        },

                        child:
                            _glassIcon(
                          Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 34),

                  // ================= HERO CARD =================

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      34,
                    ),

                    child:
                        BackdropFilter(
                      filter:
                          ImageFilter.blur(
                        sigmaX: 20,
                        sigmaY: 20,
                      ),

                      child: Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          28,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              orange,
                              lightOrange,
                            ],

                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            34,
                          ),

                          boxShadow: [

                            BoxShadow(
                              color: orange
                                  .withOpacity(
                                0.25,
                              ),

                              blurRadius:
                                  30,

                              offset:
                                  const Offset(
                                0,
                                12,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Row(
                              children: [

                                Container(
                                  height:
                                      72,

                                  width:
                                      72,

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white
                                            .withOpacity(
                                      0.22,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      24,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .insights_rounded,

                                    color:
                                        Colors.white,

                                    size:
                                        36,
                                  ),
                                ),

                                const Spacer(),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        16,

                                    vertical:
                                        10,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white
                                            .withOpacity(
                                      0.20,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      30,
                                    ),
                                  ),

                                  child:
                                      const Row(
                                    children: [

                                      Icon(
                                        Icons
                                            .verified_rounded,

                                        size:
                                            16,

                                        color:
                                            Colors.white,
                                      ),

                                      SizedBox(
                                          width:
                                              8),

                                      Text(
                                        "ACTIVE",

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
                              ],
                            ),

                            const SizedBox(
                                height:
                                    28),

                            const Text(
                              "Welcome Back ",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    20,

                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    12),

                            const Text(
                              "Monitor products, manage orders and track business revenue in one beautiful dashboard.",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                height:
                                    1.6,

                                fontSize:
                                    15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // ================= STATS =================

                  _premiumCard(
                    title:
                        "Total Products",

                    value:
                        totalProducts
                            .toString(),

                    icon:
                        Icons
                            .inventory_2_rounded,

                    iconColor:
                        orange,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const AdminProductsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                      height: 22),

                  _premiumCard(
                    title:
                        "Total Orders",

                    value:
                        totalOrders
                            .toString(),

                    icon:
                        Icons
                            .shopping_bag_rounded,

                    iconColor:
                        green,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  const AdminOrdersScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                      height: 22),

                  _premiumCard(
                    title:
                        "Total Revenue",

                    value:
                        "₹${totalRevenue.toStringAsFixed(2)}",

                    icon:
                        Icons
                            .payments_rounded,

                    iconColor:
                        orange,
                  ),

                  const SizedBox(
                      height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PREMIUM CARD =================

  Widget _premiumCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

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
                0.80,
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              border: Border.all(
                color:
                    Colors.white
                        .withOpacity(
                  0.7,
                ),
              ),

              boxShadow: [

                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.04,
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

            child: Row(
              children: [

                Container(
                  height: 72,
                  width: 72,

                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        iconColor
                            .withOpacity(
                          0.95,
                        ),

                        iconColor
                            .withOpacity(
                          0.75,
                        ),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child: Icon(
                    icon,

                    color:
                        Colors.white,

                    size: 34,
                  ),
                ),

                const SizedBox(
                    width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        title,

                        style:
                            TextStyle(
                          color: Colors
                              .black
                              .withOpacity(
                            0.55,
                          ),

                          fontSize:
                              15,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                          height:
                              8),

                      Text(
                        value,

                        style:
                            const TextStyle(
                          color:
                              Colors.black,

                          fontSize:
                              28,

                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons
                      .arrow_forward_ios_rounded,

                  color:
                      Colors.black
                          .withOpacity(
                    0.35,
                  ),

                  size: 18,
                ),
              ],
            ),
          ),
        ),
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
              0.7,
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
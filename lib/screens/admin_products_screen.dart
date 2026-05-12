import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'product_form_screen.dart';

class AdminProductsScreen
    extends StatefulWidget {
  const AdminProductsScreen({
    super.key,
  });

  @override
  State<AdminProductsScreen>
      createState() =>
          _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends State<
            AdminProductsScreen>
    with SingleTickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  List products = [];

  late AnimationController
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

    // ✅ FIXED ANIMATION CONTROLLER

    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10),
    )..repeat(reverse: true);

    fetchProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= FETCH PRODUCTS =================

  Future<void> fetchProducts() async {
    final data =
        await supabase
            .from('products')
            .select()
            .order('created_at');

    if (!mounted) return;

    setState(() {
      products = data;
    });
  }

  // ================= DELETE PRODUCT =================

  Future<void> deleteProduct(
    String id,
  ) async {
    await supabase
        .from('products')
        .delete()
        .eq('id', id);

    fetchProducts();
  }

  // ================= OPEN FORM =================

  void openProductForm({
    Map? product,
  }) async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) => ProductFormScreen(
          product: product,
        ),
      ),
    );

    fetchProducts();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAF5),

      // ================= FLOATING BUTTON =================

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: orange,
        elevation: 8,

        onPressed:
            () => openProductForm(),

        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),

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
                          0.16,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 250,

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
                          0.14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ================= MAIN UI =================

          SafeArea(
            child: Column(
              children: [

                // ================= HEADER =================

                Padding(
                  padding:
                      const EdgeInsets.all(
                    22,
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

                      // CENTER TITLE

                      Expanded(
                        child: Column(
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

                                boxShadow: [

                                  BoxShadow(
                                    color: orange
                                        .withOpacity(
                                      0.30,
                                    ),

                                    blurRadius:
                                        24,

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
                                    .inventory_2_rounded,

                                color:
                                    Colors.white,

                                size:
                                    36,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    14),

                            const Text(
                              "Manage Products",

                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  TextStyle(
                                fontSize:
                                    28,

                                fontWeight:
                                    FontWeight
                                        .w900,

                                color:
                                    Colors.black,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    6),

                            Text(
                              "Add, edit & manage your healthy products",

                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  TextStyle(
                                color:
                                    Colors.black
                                        .withOpacity(
                                  0.55,
                                ),

                                fontSize:
                                    14,

                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // RIGHT SPACE

                      const SizedBox(
                        width: 54,
                      ),
                    ],
                  ),
                ),

                // ================= PRODUCT LIST =================

                Expanded(
                  child:
                      products.isEmpty
                          ? Center(
                              child:
                                  Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [

                                  Container(
                                    height:
                                        120,

                                    width:
                                        120,

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          orange.withOpacity(
                                        0.12,
                                      ),

                                      borderRadius:
                                          BorderRadius.circular(
                                        30,
                                      ),
                                    ),

                                    child:
                                        Icon(
                                      Icons
                                          .inventory_2_outlined,

                                      color:
                                          orange,

                                      size:
                                          60,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          24),

                                  const Text(
                                    "No Products Found",

                                    style:
                                        TextStyle(
                                      fontSize:
                                          22,

                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  Text(
                                    "Start adding premium healthy products",

                                    style:
                                        TextStyle(
                                      color:
                                          Colors.black.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics:
                                  const BouncingScrollPhysics(),

                              padding:
                                  const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 100,
                              ),

                              itemCount:
                                  products.length,

                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                final item =
                                    products[
                                        index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom:
                                        18,
                                  ),

                                  child:
                                      _productCard(
                                    item,
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

  // ================= PRODUCT CARD =================

  Widget _productCard(
    dynamic item,
  ) {
    return ClipRRect(
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
            20,
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

              // ================= PRODUCT ICON =================

              Container(
                height: 90,
                width: 90,

                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      orange
                          .withOpacity(
                        0.9,
                      ),

                      lightOrange
                          .withOpacity(
                        0.8,
                      ),
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

                  size: 40,
                ),
              ),

              const SizedBox(
                  width: 18),

              // ================= PRODUCT DETAILS =================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      item['name'] ??
                          "",

                      maxLines: 1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        fontSize:
                            20,

                        fontWeight:
                            FontWeight
                                .w800,

                        color:
                            Colors.black,
                      ),
                    ),

                    const SizedBox(
                        height:
                            10),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            12,

                        vertical:
                            8,
                      ),

                      decoration:
                          BoxDecoration(
                        color: green
                            .withOpacity(
                          0.10,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: Text(
                        item['goal'] ??
                            "",

                        style:
                            const TextStyle(
                          color:
                              green,

                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height:
                            14),

                    Text(
                      "₹${item['price']}",

                      style:
                          const TextStyle(
                        fontSize:
                            24,

                        fontWeight:
                            FontWeight
                                .w900,

                        color:
                            orange,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= ACTION BUTTONS =================

              Column(
                children: [

                  GestureDetector(
                    onTap:
                        () =>
                            openProductForm(
                      product:
                          item,
                    ),

                    child:
                        _actionButton(
                      Icons
                          .edit_rounded,

                      green,
                    ),
                  ),

                  const SizedBox(
                      height:
                          14),

                  GestureDetector(
                    onTap:
                        () =>
                            deleteProduct(
                      item['id'],
                    ),

                    child:
                        _actionButton(
                      Icons
                          .delete_rounded,

                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ACTION BUTTON =================

  Widget _actionButton(
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 48,
      width: 48,

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.12,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  // ================= GLASS ICON =================

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
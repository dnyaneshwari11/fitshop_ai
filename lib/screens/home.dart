import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'fitness_coach_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_tile.dart';
import 'cart.dart';
import 'order_history_screen.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;

  bool _isListening = false;
  String _voiceText = "";
  bool _showIntro = true;

  late AnimationController
      _backgroundController;

  // ================= COLORS =================

  static const Color green =
      Color(0xFF35C759);

  static const Color orange =
      Color(0xFFFF8A2B);

  static const Color dark =
      Color(0xFF0F1115);

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    _backgroundController =
        AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    Timer(
      const Duration(milliseconds: 2400),
      () {
        if (mounted) {
          setState(() {
            _showIntro = false;
          });
        }
      },
    );

    Future.microtask(() {
      context
          .read<ProductProvider>()
          .fetchProducts();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  // ================= VOICE =================

  void _startListening() async {
    bool available =
        await _speech.initialize();

    if (!available) {
      setState(() {
        _voiceText =
            "Voice search works on mobile devices";
        _isListening = false;
      });

      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = "Listening...";
    });

    _speech.listen(
      localeId: 'en_IN',
      listenFor:
          const Duration(seconds: 5),
      onResult: (result) {
        setState(() {
          _voiceText =
              result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() {
            _isListening = false;
          });

          _applyVoiceSearch(
            _voiceText,
          );
        }
      },
    );
  }

  void _applyVoiceSearch(
    String query,
  ) {
    final provider =
        context.read<ProductProvider>();

    query = query.toLowerCase();

    provider.resetProducts();

    if (query.contains("weight loss") ||
        query.contains("slim")) {
      provider.filterByGoal(
          "weight loss");
    } else if (query.contains(
            "weight gain") ||
        query.contains("bulk")) {
      provider.filterByGoal(
          "weight gain");
    } else {
      provider.searchProducts(query);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthProvider>();

    final cart =
        context.watch<CartProvider>();

    final productProvider =
        context.watch<ProductProvider>();

    final products =
        productProvider.products;

    final recommended =
        auth.goal == null
            ? []
            : products
                .where(
                  (p) =>
                      p.goal ==
                      auth.goal,
                )
                .toList();

    // ===== SHOW RECOMMENDED FIRST =====

    final displayProducts = [
      ...recommended,
      ...products.where(
        (p) =>
            !recommended.contains(p),
      ),
    ];

    return AnimatedSwitcher(
      duration:
          const Duration(milliseconds: 700),

      child: _showIntro
          ? _buildIntro()
          : Scaffold(
              backgroundColor: dark,

              floatingActionButton:
                  FloatingActionButton(
                elevation: 0,
                backgroundColor:
                    _isListening
                        ? Colors.redAccent
                        : green,
                onPressed:
                    _startListening,
                child: Icon(
                  _isListening
                      ? Icons.mic
                      : Icons
                          .mic_none_rounded,
                  color: Colors.white,
                ),
              ),

              body: Stack(
                children: [

                  // ================= BACKGROUND =================

                  AnimatedBuilder(
                    animation:
                        _backgroundController,
                    builder:
                        (context, child) {
                      return Stack(
                        children: [

                          Positioned(
                            top:
                                -150 +
                                    (_backgroundController.value *
                                        50),
                            left:
                                -120 +
                                    (_backgroundController.value *
                                        40),
                            child:
                                Container(
                              height: 320,
                              width: 320,
                              decoration:
                                  BoxDecoration(
                                shape: BoxShape
                                    .circle,
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
                                    (_backgroundController.value *
                                        50),
                            right:
                                -120 +
                                    (_backgroundController.value *
                                        30),
                            child:
                                Container(
                              height: 360,
                              width: 360,
                              decoration:
                                  BoxDecoration(
                                shape: BoxShape
                                    .circle,
                                color: orange
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
                    child:
                        CustomScrollView(
                      physics:
                          const BouncingScrollPhysics(),

                      slivers: [

                        // ================= APP BAR =================

                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),

                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                // ================= LOGO =================

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    const Text(
                                      "PURE LEAF",
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            24,
                                        fontWeight:
                                            FontWeight.w900,
                                        letterSpacing:
                                            4,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            4),

                                    Text(
                                      "Healthy lifestyle",
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .white
                                            .withOpacity(
                                          0.55,
                                        ),
                                        fontSize:
                                            11,
                                      ),
                                    ),
                                  ],
                                ),

                                // ================= RIGHT NAVBAR =================

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        12,
                                    vertical:
                                        10,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.06,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      24,
                                    ),

                                    border:
                                        Border.all(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.08,
                                      ),
                                    ),
                                  ),

                                  child: Row(
                                    children: [

                                      // CHATBOT

                                      _navIcon(
                                        icon: Icons
                                            .smart_toy_rounded,
                                        color:
                                            green,
                                        onTap:
                                            () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const FitnessCoachScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(
                                          width:
                                              12),

                                      // ORDER HISTORY

                                      _navIcon(
                                        icon: Icons
                                            .receipt_long_rounded,
                                        color:
                                            orange,
                                        onTap:
                                            () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const OrderHistoryScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(
                                          width:
                                              12),

                                      // CART

                                      Stack(
                                        clipBehavior:
                                            Clip.none,
                                        children: [

                                          _navIcon(
                                            icon: Icons
                                                .shopping_bag_rounded,
                                            color:
                                                green,
                                            onTap:
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const CartScreen(),
                                                ),
                                              );
                                            },
                                          ),

                                          if (cart
                                                  .totalItems >
                                              0)
                                            Positioned(
                                              right:
                                                  -4,
                                              top:
                                                  -4,

                                              child:
                                                  Container(
                                                height:
                                                    20,
                                                width:
                                                    20,

                                                decoration:
                                                    const BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  color:
                                                      orange,
                                                ),

                                                child:
                                                    Center(
                                                  child:
                                                      Text(
                                                    cart.totalItems
                                                        .toString(),

                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.white,
                                                      fontSize:
                                                          10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(
                                          width:
                                              12),

                                      // LOGOUT

                                      _navIcon(
                                        icon: Icons
                                            .logout_rounded,
                                        color: Colors
                                            .redAccent,
                                        onTap:
                                            () async {

                                          await context
                                              .read<AuthProvider>()
                                              .logout();

                                          if (!mounted) {
                                            return;
                                          }

                                          Navigator.pushAndRemoveUntil(
                                            context,

                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      LoginScreen(),
                                            ),

                                            (route) =>
                                                false,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ================= HERO =================

                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),

                            child:
                                Container(
                              padding:
                                  const EdgeInsets.all(
                                24,
                              ),

                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                  30,
                                ),

                                gradient:
                                    LinearGradient(
                                  colors: [
                                    green
                                        .withOpacity(
                                      0.22,
                                    ),
                                    orange
                                        .withOpacity(
                                      0.12,
                                    ),
                                  ],
                                ),
                              ),

                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  const Text(
                                    "Fresh Healthy Products",
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          28,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  Text(
                                    "Premium grocery • Fitness • Fast delivery",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.7,
                                      ),
                                      height:
                                          1.5,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          24),

                                  // SEARCH

                                  Container(
                                    height:
                                        60,

                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.08,
                                      ),

                                      borderRadius:
                                          BorderRadius.circular(
                                        20,
                                      ),
                                    ),

                                    child:
                                        TextField(
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                      ),

                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "Search healthy products...",
                                        hintStyle:
                                            TextStyle(
                                          color: Colors
                                              .white
                                              .withOpacity(
                                            0.45,
                                          ),
                                        ),

                                        prefixIcon:
                                            const Icon(
                                          Icons
                                              .search_rounded,
                                          color:
                                              Colors.white70,
                                        ),

                                        border:
                                            InputBorder.none,
                                      ),

                                      onChanged:
                                          (
                                        v,
                                      ) {
                                        context
                                            .read<ProductProvider>()
                                            .searchProducts(
                                              v,
                                            );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ================= SECTION =================

                        _sectionTitle(
                          "Recommended For You",
                        ),

                        // ================= PRODUCTS =================

                        productProvider
                                .isLoading
                            ? const SliverFillRemaining(
                                child:
                                    Center(
                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        green,
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      20,
                                ),

                                sliver:
                                    SliverList(
                                  delegate:
                                      SliverChildBuilderDelegate(
                                    (
                                      context,
                                      index,
                                    ) {
                                      final product =
                                          displayProducts[
                                              index];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          bottom:
                                              18,
                                        ),

                                        child:
                                            ProductTile(
                                          product:
                                              product,
                                        ),
                                      );
                                    },

                                    childCount:
                                        displayProducts
                                            .length,
                                  ),
                                ),
                              ),

                        const SliverToBoxAdapter(
                          child:
                              SizedBox(
                            height: 120,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= INTRO =================

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: dark,

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              height: 120,
              width: 120,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  40,
                ),

                gradient:
                    const LinearGradient(
                  colors: [
                    orange,
                    green,
                  ],
                ),
              ),

              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 58,
              ),
            ),

            const SizedBox(height: 34),

            const Text(
              "PURE LEAF",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          22,
          30,
          22,
          18,
        ),

        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ================= NAV ICON =================

  Widget _navIcon({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 48,
        width: 48,

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.22),
              color.withOpacity(0.10),
            ],
          ),

          border: Border.all(
            color:
                color.withOpacity(0.25),
          ),
        ),

        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
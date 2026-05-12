import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductFormScreen extends StatefulWidget {
  final Map? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final supabase =
      Supabase.instance.client;

  final _formKey =
      GlobalKey<FormState>();

  // ================= CONTROLLERS =================

  final nameCtrl =
      TextEditingController();

  final caloriesCtrl =
      TextEditingController();

  final proteinCtrl =
      TextEditingController();

  final priceCtrl =
      TextEditingController();

  final goalCtrl =
      TextEditingController();

  // ================= STATES =================

  bool isEdit = false;
  bool isLoading = false;

  // ✅ FIXED ERROR
  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color orange =
      Color(0xFFFF8A00);

  static const Color lightOrange =
      Color(0xFFFFB347);

  static const Color green =
      Color(0xFF34C759);

  static const Color bg =
      Color(0xFFFFFAF5);

  @override
  void initState() {
    super.initState();

    // ✅ INITIALIZED PROPERLY
    _animationController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10),
    )..repeat(reverse: true);

    if (widget.product != null) {
      isEdit = true;

      nameCtrl.text =
          widget.product!['name'] ?? '';

      caloriesCtrl.text =
          widget.product!['calories']
                  ?.toString() ??
              '';

      proteinCtrl.text =
          widget.product!['protein']
                  ?.toString() ??
              '';

      priceCtrl.text =
          widget.product!['price']
                  ?.toString() ??
              '';

      goalCtrl.text =
          widget.product!['goal'] ?? '';
    }
  }

  @override
  void dispose() {
    // ✅ DISPOSE FIX
    _animationController.dispose();

    nameCtrl.dispose();
    caloriesCtrl.dispose();
    proteinCtrl.dispose();
    priceCtrl.dispose();
    goalCtrl.dispose();

    super.dispose();
  }

  // ================= SAVE PRODUCT =================

  Future<void> saveProduct() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = {
      "name":
          nameCtrl.text.trim(),

      "calories": int.parse(
        caloriesCtrl.text.trim(),
      ),

      "protein": int.parse(
        proteinCtrl.text.trim(),
      ),

      "price": double.parse(
        priceCtrl.text.trim(),
      ),

      "goal":
          goalCtrl.text.trim(),
    };

    if (isEdit) {
      await supabase
          .from('products')
          .update(data)
          .eq(
            'id',
            widget.product!['id'],
          );
    } else {
      await supabase
          .from('products')
          .insert(data);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ================= INPUT FIELD =================

  Widget buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard =
        TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 20,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Padding(
            padding:
                const EdgeInsets.only(
              left: 6,
              bottom: 10,
            ),

            child: Text(
              label,

              style: TextStyle(
                color: Colors.black
                    .withOpacity(
                  0.75,
                ),

                fontWeight:
                    FontWeight.w700,

                fontSize: 14,
              ),
            ),
          ),

          Container(
            decoration:
                BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.05,
                  ),

                  blurRadius: 12,

                  offset:
                      const Offset(
                    0,
                    5,
                  ),
                ),
              ],
            ),

            child: TextFormField(
              controller:
                  controller,

              keyboardType:
                  keyboard,

              validator: (
                value,
              ) {
                if (value ==
                        null ||
                    value
                        .trim()
                        .isEmpty) {
                  return "$label is required";
                }

                if (keyboard ==
                    TextInputType
                        .number) {
                  if (double.tryParse(
                          value) ==
                      null) {
                    return "Enter valid number";
                  }
                }

                return null;
              },

              style:
                  const TextStyle(
                color:
                    Colors.black,
                fontWeight:
                    FontWeight.w600,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    "Enter $label",

                hintStyle:
                    TextStyle(
                  color: Colors
                      .grey
                      .shade500,
                ),

                prefixIcon:
                    Icon(
                  icon,
                  color: green,
                ),

                border:
                    InputBorder.none,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

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
                    top: 260,

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
                        -150 +
                            (_animationController.value *
                                40),

                    right:
                        -110 +
                            (_animationController.value *
                                20),

                    child: Container(
                      height: 320,
                      width: 320,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            lightOrange
                                .withOpacity(
                          0.15,
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

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,

                            color:
                                Colors.black,
                            size: 20,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Column(
                        children: [

                          Text(
                            isEdit
                                ? "EDIT PRODUCT"
                                : "ADD PRODUCT",

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight.w900,

                              color:
                                  Colors.black,
                            ),
                          ),

                          const SizedBox(
                              height:
                                  6),

                          Text(
                            "Pure Leaf Admin",

                            style:
                                TextStyle(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.45,
                              ),

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        height: 52,
                        width: 52,

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
                        ),

                        child: const Icon(
                          Icons
                              .inventory_2_rounded,

                          color:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 34),

                  // ================= HERO CARD =================

                  Container(
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

                    child: Row(
                      children: [

                        Container(
                          height: 74,
                          width: 74,

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
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
                                .restaurant_menu_rounded,

                            color:
                                Colors.white,

                            size: 38,
                          ),
                        ),

                        const SizedBox(
                            width:
                                20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                isEdit
                                    ? "Update Product"
                                    : "Create Product",

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,

                                  fontSize:
                                      22,

                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      8),

                              const Text(
                                "Manage healthy products with premium dashboard UI 🚀",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,

                                  height:
                                      1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // ================= FORM =================

                  Container(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),

                      boxShadow: [

                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            0.05,
                          ),

                          blurRadius:
                              18,

                          offset:
                              const Offset(
                            0,
                            10,
                          ),
                        ),
                      ],
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        children: [

                          buildField(
                            "Product Name",
                            nameCtrl,

                            icon:
                                Icons
                                    .fastfood_rounded,
                          ),

                          buildField(
                            "Calories",
                            caloriesCtrl,

                            keyboard:
                                TextInputType.number,

                            icon:
                                Icons
                                    .local_fire_department_rounded,
                          ),

                          buildField(
                            "Protein (g)",
                            proteinCtrl,

                            keyboard:
                                TextInputType.number,

                            icon:
                                Icons
                                    .fitness_center_rounded,
                          ),

                          buildField(
                            "Price",
                            priceCtrl,

                            keyboard:
                                TextInputType.number,

                            icon:
                                Icons
                                    .currency_rupee_rounded,
                          ),

                          buildField(
                            "Goal",
                            goalCtrl,

                            icon:
                                Icons
                                    .flag_rounded,
                          ),

                          const SizedBox(
                              height:
                                  10),

                          // ================= BUTTON =================

                          SizedBox(
                            width:
                                double.infinity,

                            height: 60,

                            child:
                                ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    green,

                                elevation:
                                    0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                              ),

                              onPressed:
                                  isLoading
                                      ? null
                                      : saveProduct,

                              child:
                                  isLoading
                                      ? const CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                        )
                                      : Text(
                                          isEdit
                                              ? "UPDATE PRODUCT"
                                              : "SAVE PRODUCT",

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,

                                            fontSize:
                                                16,

                                            fontWeight:
                                                FontWeight.w800,

                                            letterSpacing:
                                                1.1,
                                          ),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
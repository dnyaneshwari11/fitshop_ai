// ================= SIGNUP SCREEN =================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'profile.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color green =
      Color(0xFF32D74B);

  static const Color dark =
      Color(0xFF0B0D0F);

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: dark,

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
                        -140 +
                            (_animationController.value *
                                40),
                    left:
                        -100 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 320,
                      width: 320,
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
                        -180 +
                            (_animationController.value *
                                40),
                    right:
                        -120 +
                            (_animationController.value *
                                30),
                    child: Container(
                      height: 360,
                      width: 360,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: Colors.white
                            .withOpacity(
                          0.06,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 260,
                    right: -40,
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: green
                            .withOpacity(
                          0.08,
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
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),

              child: ConstrainedBox(
                constraints:
                    BoxConstraints(
                  minHeight:
                      screenHeight - 60,
                ),

                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      const Spacer(),

                      // ================= LOGO =================

                      Container(
                        height: 110,
                        width: 110,

                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            34,
                          ),

                          gradient:
                              LinearGradient(
                            colors: [
                              green,
                              green
                                  .withOpacity(
                                0.7,
                              ),
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: green
                                  .withOpacity(
                                0.35,
                              ),
                              blurRadius:
                                  30,
                              spreadRadius:
                                  2,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.eco_rounded,
                          color:
                              Colors.white,
                          size: 56,
                        ),
                      ),

                      const SizedBox(
                          height: 34),

                      // ================= TITLE =================

                      const Text(
                        "Create Account",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color: white,
                          fontSize: 34,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              0.5,
                        ),
                      ),

                      const SizedBox(
                          height: 14),

                      Text(
                        "Join Pure Leaf and order healthy products smarter & faster",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(
                            0.6,
                          ),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(
                          height: 42),

                      // ================= GLASS CARD =================

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
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.06,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                34,
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

                            child: Column(
                              children: [

                                // ================= EMAIL =================

                                _buildFieldLabel(
                                  "Email Address",
                                ),

                                const SizedBox(
                                    height:
                                        12),

                                _glassField(
                                  controller:
                                      emailCtrl,

                                  hint:
                                      "Enter your email",

                                  icon:
                                      Icons.email_outlined,
                                ),

                                const SizedBox(
                                    height:
                                        24),

                                // ================= PASSWORD =================

                                _buildFieldLabel(
                                  "Password",
                                ),

                                const SizedBox(
                                    height:
                                        12),

                                _glassField(
                                  controller:
                                      passCtrl,

                                  hint:
                                      "Create password",

                                  icon:
                                      Icons.lock_outline_rounded,

                                  obscure:
                                      obscurePassword,

                                  suffix:
                                      IconButton(
                                    onPressed:
                                        () {
                                      setState(
                                        () {
                                          obscurePassword =
                                              !obscurePassword;
                                        },
                                      );
                                    },

                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,

                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        34),

                                // ================= BUTTON =================

                                SizedBox(
                                  width:
                                      double.infinity,
                                  height: 60,

                                  child:
                                      ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(
                                      elevation:
                                          0,

                                      backgroundColor:
                                          green,

                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          22,
                                        ),
                                      ),
                                    ),

                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                                final email =
                                                    emailCtrl
                                                        .text
                                                        .trim();

                                                final password =
                                                    passCtrl
                                                        .text
                                                        .trim();

                                                if (email
                                                        .isEmpty ||
                                                    password
                                                        .isEmpty) {
                                                  ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content:
                                                          Text(
                                                        "Enter email & password",
                                                      ),
                                                    ),
                                                  );

                                                  return;
                                                }

                                                setState(
                                                  () {
                                                    isLoading =
                                                        true;
                                                  },
                                                );

                                                try {
                                                  final authService =
                                                      AuthService();

                                                  final userService =
                                                      UserService();

                                                  final userId =
                                                      await authService.signUp(
                                                    email,
                                                    password,
                                                  );

                                                  if (userId !=
                                                      null) {
                                                    await userService
                                                        .createUserProfile(
                                                      userId,
                                                      email,
                                                    );

                                                    if (!context
                                                        .mounted) {
                                                      return;
                                                    }

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) =>
                                                                const ProfileScreen(),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text(
                                                        "Error: $e",
                                                      ),
                                                    ),
                                                  );
                                                }

                                                setState(
                                                  () {
                                                    isLoading =
                                                        false;
                                                  },
                                                );
                                              },

                                    child:
                                        isLoading
                                            ? const CircularProgressIndicator(
                                                color:
                                                    Colors.white,
                                              )
                                            : const Text(
                                                "CREATE ACCOUNT",

                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.white,
                                                  fontSize:
                                                      16,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  letterSpacing:
                                                      1.2,
                                                ),
                                              ),
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        24),

                                // ================= INFO =================

                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                    16,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: green
                                        .withOpacity(
                                      0.08,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),

                                    border:
                                        Border.all(
                                      color: green
                                          .withOpacity(
                                        0.12,
                                      ),
                                    ),
                                  ),

                                  child: Row(
                                    children: [

                                      Container(
                                        padding:
                                            const EdgeInsets.all(
                                          12,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              green,

                                          borderRadius:
                                              BorderRadius.circular(
                                            14,
                                          ),
                                        ),

                                        child:
                                            const Icon(
                                          Icons.eco_rounded,
                                          color: Colors
                                              .white,
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              14),

                                      Expanded(
                                        child:
                                            Text(
                                          "Healthy lifestyle products delivered instantly 🚀",

                                          style:
                                              TextStyle(
                                            color: Colors
                                                .white
                                                .withOpacity(
                                              0.8,
                                            ),

                                            fontWeight:
                                                FontWeight.w500,

                                            height:
                                                1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      // ================= LOGIN =================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Text(
                            "Already have an account?",

                            style: TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.5,
                              ),

                              fontSize: 14,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const LoginScreen(),
                                ),
                              );
                            },

                            child: const Text(
                              "Login",

                              style: TextStyle(
                                color: green,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIELD LABEL =================

  Widget _buildFieldLabel(
    String title,
  ) {
    return Align(
      alignment:
          Alignment.centerLeft,

      child: Text(
        title,

        style: const TextStyle(
          color: Colors.white,
          fontWeight:
              FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // ================= GLASS FIELD =================

  Widget _glassField({
    required TextEditingController
        controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.05,
        ),

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color:
              Colors.white.withOpacity(
            0.06,
          ),
        ),
      ),

      child: TextField(
        controller: controller,
        obscureText: obscure,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color:
                Colors.white.withOpacity(
              0.4,
            ),
          ),

          prefixIcon: Icon(
            icon,
            color: green,
          ),

          suffixIcon: suffix,

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
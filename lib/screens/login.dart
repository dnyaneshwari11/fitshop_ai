// ================= LOGIN SCREEN =================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import 'profile.dart';
import 'home.dart';
import 'admin_dashboard.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl =
      TextEditingController();

  final passCtrl =
      TextEditingController();

  bool obscurePassword = true;

  late AnimationController
      _animationController;

  // ================= COLORS =================

  static const Color green =
      Color(0xFF22C55E);

  static const Color dark =
      Color(0xFF07120C);

  static const Color darkCard =
      Color(0xFF101A13);

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
    emailCtrl.dispose();
    passCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,

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
                        -150 +
                            (_animationController.value *
                                40),

                    left:
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
                        -140 +
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
                          0.05,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 240,
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
                vertical: 20,
              ),

              child: ConstrainedBox(
                constraints:
                    BoxConstraints(
                  minHeight:
                      MediaQuery.of(
                            context,
                          ).size.height -
                          40,
                ),

                child: Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      const SizedBox(
                          height: 20),

                      // ================= LOGO =================

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          32,
                        ),

                        child:
                            BackdropFilter(
                          filter:
                              ImageFilter.blur(
                            sigmaX: 18,
                            sigmaY: 18,
                          ),

                          child: Container(
                            height: 110,
                            width: 110,

                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                32,
                              ),

                              gradient:
                                  LinearGradient(
                                colors: [
                                  green
                                      .withOpacity(
                                    0.95,
                                  ),

                                  Colors.greenAccent
                                      .withOpacity(
                                    0.85,
                                  ),
                                ],
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

                            child:
                                const Icon(
                              Icons
                                  .eco_rounded,

                              color:
                                  Colors.white,

                              size: 56,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 32),

                      // ================= TITLE =================

                      const Text(
                        "PURE LEAF",

                        style: TextStyle(
                          color:
                              Colors.white,

                          fontSize: 34,

                          fontWeight:
                              FontWeight
                                  .w900,

                          letterSpacing:
                              5,
                        ),
                      ),

                      const SizedBox(
                          height: 14),

                      Text(
                        "Healthy products & smart deliveries",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color: Colors
                              .white
                              .withOpacity(
                            0.6,
                          ),

                          fontSize: 15,

                          height: 1.6,
                        ),
                      ),

                      const SizedBox(
                          height: 45),

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
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Center(
                                  child: Text(
                                    "Welcome Back",

                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .white,

                                      fontSize:
                                          28,

                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        10),

                                Center(
                                  child: Text(
                                    "Login to continue your healthy journey",

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.55,
                                      ),

                                      fontSize:
                                          14,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        34),

                                // ================= EMAIL =================

                                _buildInputField(
                                  controller:
                                      emailCtrl,

                                  hint:
                                      "Email Address",

                                  icon:
                                      Icons.email_outlined,
                                ),

                                const SizedBox(
                                    height:
                                        20),

                                // ================= PASSWORD =================

                                _buildPasswordField(),

                                const SizedBox(
                                    height:
                                        34),

                                // ================= LOGIN BUTTON =================

                                Consumer<
                                    AuthProvider>(
                                  builder:
                                      (
                                    context,
                                    authProvider,
                                    child,
                                  ) {

                                    return SizedBox(
                                      width:
                                          double.infinity,

                                      height:
                                          60,

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
                                              20,
                                            ),
                                          ),
                                        ),

                                        onPressed:
                                            authProvider.isLoading
                                                ? null
                                                : () async {

                                                    final email =
                                                        emailCtrl.text.trim();

                                                    final password =
                                                        passCtrl.text.trim();

                                                    if (email.isEmpty ||
                                                        password.isEmpty) {
                                                      return;
                                                    }

                                                    try {

                                                      final success =
                                                          await context
                                                              .read<AuthProvider>()
                                                              .login(
                                                                email,
                                                                password,
                                                              );

                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      if (success) {

                                                        final role =
                                                            context
                                                                .read<AuthProvider>()
                                                                .role;

                                                        final isCompleted =
                                                            context
                                                                .read<AuthProvider>()
                                                                .profileCompleted;

                                                        // ADMIN

                                                        if (role ==
                                                            'admin') {

                                                          Navigator.pushReplacement(
                                                            context,

                                                            MaterialPageRoute(
                                                              builder:
                                                                  (_) =>
                                                                      const AdminDashboard(),
                                                            ),
                                                          );
                                                        }

                                                        // USER

                                                        else {

                                                          if (isCompleted) {

                                                            Navigator.pushReplacement(
                                                              context,

                                                              MaterialPageRoute(
                                                                builder:
                                                                    (_) =>
                                                                        const HomeScreen(),
                                                              ),
                                                            );
                                                          } else {

                                                            Navigator.pushReplacement(
                                                              context,

                                                              MaterialPageRoute(
                                                                builder:
                                                                    (_) =>
                                                                        const ProfileScreen(),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }

                                                    } catch (e) {

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.redAccent,

                                                          content:
                                                              Text(
                                                            "$e",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },

                                        child:
                                            authProvider.isLoading
                                                ? const CircularProgressIndicator(
                                                    color:
                                                        Colors.white,
                                                  )
                                                : const Text(
                                                    "LOGIN",

                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.white,

                                                      fontSize:
                                                          17,

                                                      fontWeight:
                                                          FontWeight.bold,

                                                      letterSpacing:
                                                          1.2,
                                                    ),
                                                  ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(
                                    height:
                                        28),

                                // ================= INFO =================

                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                    18,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: green
                                        .withOpacity(
                                      0.08,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      22,
                                    ),

                                    border:
                                        Border.all(
                                      color: green
                                          .withOpacity(
                                        0.15,
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
                                          Icons
                                              .eco_rounded,

                                          color:
                                              Colors
                                                  .white,
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              16),

                                      Expanded(
                                        child:
                                            Text(
                                          "Fresh healthy products delivered instantly 🚀",

                                          style:
                                              TextStyle(
                                            color:
                                                Colors
                                                    .white
                                                    .withOpacity(
                                              0.82,
                                            ),

                                            fontWeight:
                                                FontWeight
                                                    .w600,

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
                          height: 28),

                      // ================= SIGNUP =================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Text(
                            "New to Pure Leaf?",

                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.6,
                              ),

                              fontSize: 15,
                            ),
                          ),

                          TextButton(
                            onPressed: () {

                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const SignupScreen(),
                                ),
                              );
                            },

                            child: const Text(
                              "Create Account",

                              style:
                                  TextStyle(
                                color:
                                    green,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize:
                                    15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 20),
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

  // ================= INPUT FIELD =================

  Widget _buildInputField({
    required TextEditingController
        controller,

    required String hint,

    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: Colors.white
              .withOpacity(0.06),
        ),
      ),

      child: TextField(
        controller: controller,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color: Colors.white
                .withOpacity(0.4),
          ),

          prefixIcon: Icon(
            icon,
            color: green,
          ),

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.05,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: Colors.white
              .withOpacity(0.06),
        ),
      ),

      child: TextField(
        controller: passCtrl,

        obscureText:
            obscurePassword,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          hintText: "Password",

          hintStyle: TextStyle(
            color: Colors.white
                .withOpacity(0.4),
          ),

          prefixIcon: const Icon(
            Icons.lock_outline,
            color: green,
          ),

          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons
                      .visibility_off
                  : Icons.visibility,

              color: Colors.white
                  .withOpacity(0.6),
            ),

            onPressed: () {
              setState(() {
                obscurePassword =
                    !obscurePassword;
              });
            },
          ),

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
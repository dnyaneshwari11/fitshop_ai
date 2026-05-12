import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_dashboard.dart';
import 'home.dart';
import 'profile.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  late AnimationController _animationController;

  static const Color greenColor = Color(0xFF35C759);
  static const Color orangeColor = Color(0xFFFF8A2B);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();

    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();

    super.dispose();
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.65),
        fontSize: 14,
      ),

      prefixIcon: Icon(
        icon,
        color: Colors.white.withOpacity(0.75),
        size: 20,
      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.white.withOpacity(0.08),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: orangeColor.withOpacity(0.9),
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget authField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      obscureText: obscure,

      keyboardType: keyboardType,

      cursorColor: orangeColor,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),

      decoration: fieldDecoration(
        hint: hint,
        icon: icon,
        suffixIcon: suffixIcon,
      ),

      validator: validator,
    );
  }

  Future<void> handleAuth() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    try {
      setState(() {
        isLoading = true;
      });

      // LOGIN

      if (isLogin) {
        final response =
            await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null && mounted) {
          final data = await supabase
              .from('profiles')
              .select('profile_completed, role')
              .eq('id', response.user!.id)
              .maybeSingle();

          final bool profileCompleted =
              data?['profile_completed'] == true;

          final String role =
              data?['role'] ?? 'user';

          if (!mounted) return;

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AdminDashboard(),
              ),
            );
          } else if (profileCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const HomeScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProfileScreen(),
              ),
            );
          }
        }
      }

      // SIGNUP

      else {
        final response =
            await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null && mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Account created successfully",
              ),
              backgroundColor: greenColor,
            ),
          );

          setState(() {
            isLogin = true;
          });

          confirmPassCtrl.clear();
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> forgotPassword() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter email first",
          ),
        ),
      );

      return;
    }

    try {
      await supabase.auth
          .resetPasswordForEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset email sent",
          ),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081C15),

      body: Stack(
        children: [

          // MAIN GREEN BACKGROUND

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Color(0xFF081C15),
                  Color(0xFF0F2D24),
                  Color(0xFF143D2F),
                ],
              ),
            ),
          ),

          // GREEN GLOW

          AnimatedBuilder(
            animation: _animationController,

            builder: (context, child) {
              return Positioned(
                top:
                    -100 +
                    (_animationController.value * 40),

                left: -80,

                child: Container(
                  height: 300,
                  width: 300,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: greenColor.withOpacity(
                      0.22,
                    ),
                  ),
                ),
              );
            },
          ),

          // ORANGE GLOW

          AnimatedBuilder(
            animation: _animationController,

            builder: (context, child) {
              return Positioned(
                bottom: -120,

                right:
                    -80 +
                    (_animationController.value * 35),

                child: Container(
                  height: 280,
                  width: 280,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: orangeColor.withOpacity(
                      0.18,
                    ),
                  ),
                ),
              );
            },
          ),

          // SMALL GREEN DOT

          Positioned(
            top: 140,
            right: 40,

            child: Container(
              height: 16,
              width: 16,

              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // SMALL ORANGE DOT

          Positioned(
            bottom: 180,
            left: 50,

            child: Container(
              height: 12,
              width: 12,

              decoration: BoxDecoration(
                color: orangeColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // MAIN UI

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(34),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),

                    child: Container(
                      padding: const EdgeInsets.all(
                        30,
                      ),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          34,
                        ),

                        color: Colors.white
                            .withOpacity(0.08),

                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.08),
                        ),
                      ),

                      child: Form(
                        key: _formKey,

                        child: Column(
                          children: [

                            // LOGO

                            Container(
                              height: 95,
                              width: 95,

                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                  30,
                                ),

                                gradient:
                                    const LinearGradient(
                                  colors: [
                                    greenColor,
                                    orangeColor,
                                  ],
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: greenColor
                                        .withOpacity(
                                      0.30,
                                    ),

                                    blurRadius: 30,
                                    offset:
                                        const Offset(
                                      0,
                                      14,
                                    ),
                                  ),
                                ],
                              ),

                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 46,
                              ),
                            ),

                            const SizedBox(height: 34),

                            // TITLE

                            Text(
                              isLogin
                                  ? "Welcome Back"
                                  : "Create Account",

                              textAlign:
                                  TextAlign.center,

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              isLogin
                                  ? "Login to continue your healthy lifestyle"
                                  : "Create your premium organic account",

                              textAlign:
                                  TextAlign.center,

                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(
                                  0.68,
                                ),

                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 34),

                            // EMAIL

                            authField(
                              controller: emailCtrl,

                              hint: "Email Address",

                              icon:
                                  Icons.email_outlined,

                              keyboardType:
                                  TextInputType
                                      .emailAddress,

                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return "Enter email";
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // PASSWORD

                            authField(
                              controller: passCtrl,

                              hint: "Password",

                              icon:
                                  Icons.lock_outline,

                              obscure:
                                  obscurePassword,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                        !obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                          .visibility_off
                                      : Icons
                                          .visibility,

                                  color: Colors.white
                                      .withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return "Enter password";
                                }

                                if (value.length <
                                    6) {
                                  return "Minimum 6 characters";
                                }

                                return null;
                              },
                            ),

                            // FORGOT PASSWORD

                            if (isLogin)
                              Align(
                                alignment:
                                    Alignment
                                        .centerRight,

                                child: TextButton(
                                  onPressed:
                                      forgotPassword,

                                  child: const Text(
                                    "Forgot Password?",

                                    style: TextStyle(
                                      color:
                                          orangeColor,

                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ),
                              ),

                            // CONFIRM PASSWORD

                            if (!isLogin) ...[
                              const SizedBox(
                                height: 20,
                              ),

                              authField(
                                controller:
                                    confirmPassCtrl,

                                hint:
                                    "Confirm Password",

                                icon: Icons
                                    .lock_reset_outlined,

                                obscure:
                                    obscureConfirmPassword,

                                suffixIcon:
                                    IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirmPassword =
                                          !obscureConfirmPassword;
                                    });
                                  },

                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons
                                            .visibility_off
                                        : Icons
                                            .visibility,

                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),

                                validator: (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .isEmpty) {
                                    return "Confirm password";
                                  }

                                  if (value.trim() !=
                                      passCtrl.text
                                          .trim()) {
                                    return "Passwords do not match";
                                  }

                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 34),

                            // BUTTON

                            SizedBox(
                              width: double.infinity,
                              height: 60,

                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : handleAuth,

                                style:
                                    ElevatedButton.styleFrom(
                                  elevation: 0,

                                  backgroundColor:
                                      Colors.transparent,

                                  shadowColor:
                                      Colors.transparent,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                ),

                                child: Ink(
                                  decoration:
                                      BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),

                                    gradient:
                                        const LinearGradient(
                                      colors: [
                                        greenColor,
                                        orangeColor,
                                      ],
                                    ),
                                  ),

                                  child: Container(
                                    alignment:
                                        Alignment.center,

                                    child: isLoading
                                        ? const SizedBox(
                                            height:
                                                24,
                                            width:
                                                24,

                                            child:
                                                CircularProgressIndicator(
                                              color:
                                                  Colors
                                                      .white,

                                              strokeWidth:
                                                  2.4,
                                            ),
                                          )
                                        : Text(
                                            isLogin
                                                ? "LOGIN"
                                                : "CREATE ACCOUNT",

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors
                                                      .white,

                                              fontWeight:
                                                  FontWeight
                                                      .w700,

                                              letterSpacing:
                                                  1,

                                              fontSize:
                                                  15,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // SWITCH

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [
                                Text(
                                  isLogin
                                      ? "Don't have account?"
                                      : "Already have account?",

                                  style: TextStyle(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.68,
                                    ),
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogin =
                                          !isLogin;
                                    });
                                  },

                                  child: Text(
                                    isLogin
                                        ? "Sign Up"
                                        : "Login",

                                    style:
                                        const TextStyle(
                                      color:
                                          orangeColor,

                                      fontWeight:
                                          FontWeight
                                              .w700,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
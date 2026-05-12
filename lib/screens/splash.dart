import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_dashboard.dart';
import 'auth_screen.dart';
import 'home.dart';
import 'profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;

  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // ================= LOGO =================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // ================= TEXT =================

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ================= FLOATING =================

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: const Offset(0, -0.025),
    ).animate(
      CurvedAnimation(
        parent: _loaderController,
        curve: Curves.easeInOut,
      ),
    );

    _logoController.forward();

    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          _textController.forward();
        }
      },
    );

    _checkUser();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  // ================= CHECK USER =================

  Future<void> _checkUser() async {

    // EXTRA PREMIUM SPLASH TIME

    await Future.delayed(
      const Duration(seconds: 8),
    );

    final user = supabase.auth.currentUser;

    if (!mounted) return;

    // ================= NOT LOGGED IN =================

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
      return;
    }

    try {

      final data = await supabase
          .from('profiles')
          .select('profile_completed, role')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final bool profileCompleted =
          data?['profile_completed'] == true;

      final String role =
          data?['role'] ?? 'user';

      // ================= ADMIN =================

      if (role == 'admin') {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AdminDashboard(),
          ),
        );

        return;
      }

      // ================= USER =================

      if (profileCompleted) {

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

    } catch (e) {

      debugPrint("Splash Error: $e");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFFF8A2B),

      body: Stack(
        children: [

          // ================= TOP GLOW =================

          Positioned(
            top: -130,
            right: -80,
            child: Container(
              height: 320,
              width: 320,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color:
                    Colors.white.withOpacity(
                  0.08,
                ),
              ),
            ),
          ),

          // ================= BIG GREEN GLOW =================

          Positioned(
            bottom: -180,
            left: -120,
            child: Container(
              height: 420,
              width: 420,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color:
                    const Color(0xFF35C759)
                        .withOpacity(0.28),
              ),
            ),
          ),

          // ================= EXTRA GREEN GLOW =================

          Positioned(
            top: 120,
            right: -70,
            child: Container(
              height: 180,
              width: 180,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color:
                    const Color(0xFF35C759)
                        .withOpacity(0.10),
              ),
            ),
          ),

          // ================= SMALL GREEN DOT =================

          Positioned(
            top: 150,
            left: 42,
            child: Container(
              height: 20,
              width: 20,

              decoration: BoxDecoration(
                color:
                    const Color(0xFF35C759)
                        .withOpacity(0.95),

                shape: BoxShape.circle,
              ),
            ),
          ),

          // ================= SMALL WHITE DOT =================

          Positioned(
            bottom: 190,
            right: 48,
            child: Container(
              height: 15,
              width: 15,

              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.85,
                ),

                shape: BoxShape.circle,
              ),
            ),
          ),

          // ================= MAIN CONTENT =================

          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  // ================= FLOATING LOGO =================

                  SlideTransition(
                    position:
                        _floatingAnimation,

                    child: ScaleTransition(
                      scale:
                          _logoAnimation,

                      child: Container(
                        height: 138,
                        width: 138,

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            38,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                0.18,
                              ),

                              blurRadius: 32,

                              offset:
                                  const Offset(
                                0,
                                16,
                              ),
                            ),
                          ],
                        ),

                        child: Stack(
                          alignment:
                              Alignment.center,

                          children: [

                            // ================= ORANGE GLOW =================

                            Container(
                              height: 100,
                              width: 100,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,

                                gradient:
                                    RadialGradient(
                                  colors: [

                                    const Color(
                                      0xFFFFB067,
                                    ).withOpacity(
                                      0.45,
                                    ),

                                    Colors
                                        .transparent,
                                  ],
                                ),
                              ),
                            ),

                            // ================= GREEN GLOW =================

                            Container(
                              height: 78,
                              width: 78,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,

                                color:
                                    const Color(
                                  0xFF35C759,
                                ).withOpacity(
                                  0.18,
                                ),
                              ),
                            ),

                            // ================= ICON =================

                            const Icon(
                              Icons.eco_rounded,

                              color:
                                  Color(
                                0xFF35C759,
                              ),

                              size: 62,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 46),

                  // ================= APP NAME =================

                  FadeTransition(
                    opacity:
                        _textAnimation,

                    child: const Text(
                      "PURE LEAF",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 42,

                        fontWeight:
                            FontWeight.w900,

                        letterSpacing: 2.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= TAGLINE =================

                  FadeTransition(
                    opacity:
                        _textAnimation,

                    child: Text(
                      "Healthy products delivered instantly",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(
                          0.93,
                        ),

                        fontSize: 16,

                        height: 1.6,

                        letterSpacing:
                            0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 68),

                  // ================= LOADER =================

                  SizedBox(
                    width: 210,

                    child: AnimatedBuilder(
                      animation:
                          _loaderController,

                      builder:
                          (context, child) {

                        return LinearProgressIndicator(
                          value:
                              _loaderController
                                  .value,

                          minHeight: 8,

                          borderRadius:
                              BorderRadius
                                  .circular(40),

                          backgroundColor:
                              Colors.white
                                  .withOpacity(
                            0.18,
                          ),

                          valueColor:
                              const AlwaysStoppedAnimation<
                                  Color>(
                            Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= LOADING TEXT =================

                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.4,
                      end: 1,
                    ),

                    duration:
                        const Duration(
                      milliseconds: 1500,
                    ),

                    curve:
                        Curves.easeInOut,

                    builder:
                        (context, value, child) {

                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },

                    child: Text(
                      "Preparing your healthy journey...",

                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(
                          0.88,
                        ),

                        fontSize: 13,

                        letterSpacing:
                            0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SUPABASE INIT
  await Supabase.initialize(
    url: 'https://hmpxwluykwtorveufgux.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtcHh3bHV5a3d0b3J2ZXVmZ3V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwNTEwNDQsImV4cCI6MjA4NjYyNzA0NH0.wU4FAl3NC5bwKvE-H303P6nscO_bvaw8kpjd1G1SwcQ',
  );

  runApp(const FitShopAI());
}

class FitShopAI extends StatelessWidget {
  const FitShopAI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// ✅ AUTH PROVIDER
        ChangeNotifierProvider(
          create: (_) {
            final auth = AuthProvider();
            auth.checkSession(); // VERY IMPORTANT
            return auth;
          },
        ),

        /// ✅ CART
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        /// ✅ PRODUCTS
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],

      /// ✅ MATERIAL APP
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "FitShop AI",

        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
          ),
        ),

        home: const SplashScreen(),
      ),
    );
  }
}

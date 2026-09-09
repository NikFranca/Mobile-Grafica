import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/cadastro_screen.dart';
import 'features/products/presentation/screens/product_register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const CadastroScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/product_register': (context) => const ProductRegisterScreen(),
      },
    );
  }
}

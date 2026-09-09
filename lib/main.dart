import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/cadastro_screen.dart';
import 'features/home/presentation/screens/HomeScreen.dart';
import 'features/home/presentation/screens/edicao_screen.dart';
import 'features/home/presentation/screens/addProdutos.dart';
import 'features/home/presentation/screens/FiltrosProduto.dart';
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

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CadastroScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/edicao': (context) => const edicaoScreen(),
        '/addProduto': (context) => const addProdutos(),
        '/filtros': (context) => const Filtrosproduto(),
        '/ProdutoRegistro': (context) => const ProductRegisterScreen(),
      },
    );
  }
}
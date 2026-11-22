import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/cadastro_screen.dart';
import 'features/home/presentation/screens/HomeScreen.dart';
import 'features/home/presentation/screens/FiltrosProduto.dart';
import 'features/products/presentation/screens/product_register_screen.dart';

class AuthSession {
  static bool isAuthenticated = false;

  static void login() {
    isAuthenticated = true;
  }

  static void logout(BuildContext context) {
    isAuthenticated = false;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CadastroScreen(),
        '/home': (context) => const AuthGuard(child: HomeScreen()),
        '/filtros': (context) => const AuthGuard(child: FiltrosProduto()),
        '/addProduto': (context) => const AuthGuard(child: ProductRegisterScreen()),
        '/ProdutoRegistro': (context) => const AuthGuard(child: ProductRegisterScreen()),
      },
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}
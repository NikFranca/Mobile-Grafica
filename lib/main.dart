import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/cadastro_screen.dart'; // Importa a tela de cadastro

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const CadastroScreen(), // <-- Cadastra '/register' aqui
        '/cadastro': (context) => const CadastroScreen(), // <-- Deixa esse também por segurança
      },
    );
  }
}
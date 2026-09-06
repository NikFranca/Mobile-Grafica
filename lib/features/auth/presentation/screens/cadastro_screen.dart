// Importa a biblioteca principal do Flutter baseada em Material Design para usar widgets como Scaffold, Text, etc.
import 'package:flutter/material.dart';

// Importa o pacote HTTP para permitir que o aplicativo faça requisições web (POST, GET) para a API.
// import 'package:http/http.dart' as http;

// Importa a biblioteca de conversão para transformar dados em formato JSON e vice-versa.
// import 'dart:convert';

// Define a classe CadastroScreen que herda de StatefulWidget porque ela possui estados que mudam (como o loading e os textos).
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

// Classe de estado correspondente à CadastroScreen, onde toda a lógica e a interface residem.
class _CadastroScreenState extends State<CadastroScreen> {
  
  // Método obrigatório que constrói visualmente os elementos da interface da tela de cadastro.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo padrão da tela inteira (combinando com o padrão do app).
      backgroundColor: const Color(0xFF0B132B),
      // Garante que o conteúdo não fique sobreposto à barra de status.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2FE).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tela de Cadastro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Aqui você colocará os campos de texto e o botão de cadastro futuramente
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
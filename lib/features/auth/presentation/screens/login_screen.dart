import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _fazerLogin() async {
    if (_isLoading) return;
    if (_formKey.currentState?.validate() != true) return;

    final email = _emailController.text.trim();

    // A senha deve ser enviada exatamente como foi digitada.
    final senha = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final client = http.Client();
    var autenticado = false;

    try {
      final resposta = await client
          .post(
            Uri.parse('http://localhost:8081/api/admin/login'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (!mounted) return;

      debugPrint('Login: HTTP ${resposta.statusCode}');

      Map<String, dynamic> dados = {};

      try {
        final recebido = jsonDecode(
          utf8.decode(resposta.bodyBytes),
        );

        if (recebido is Map<String, dynamic>) {
          dados = recebido;
        }
      } on FormatException {
        // A resposta pode não conter JSON.
      }

      if (resposta.statusCode != 200) {
        final mensagem = dados['mensagem'];

        _mostrarMensagem(
          mensagem is String && mensagem.trim().isNotEmpty
              ? mensagem
              : resposta.statusCode == 401
                  ? 'E-mail ou senha inválidos.'
                  : 'Não foi possível concluir o login.',
        );
        return;
      }

      if (dados['sucesso'] != true) {
        _mostrarMensagem(
          'O servidor não confirmou o login.',
        );
        return;
      }

      autenticado = true;
    } on TimeoutException {
      if (mounted) {
        _mostrarMensagem(
          'O servidor demorou para responder. Tente novamente.',
        );
      }
    } catch (erro) {
      debugPrint('Erro no login: $erro');

      if (mounted) {
        _mostrarMensagem(
          'Não foi possível conectar ao servidor.',
        );
      }
    } finally {
      client.close();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (!mounted || !autenticado) return;

    // A Home está registrada na rota "/".
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  InputDecoration _decoracao(String titulo) {
    return InputDecoration(
      labelText: titulo,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E2FE).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _decoracao('Gmail:'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite seu e-mail';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      decoration: _decoracao('Senha:'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite sua senha';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _fazerLogin(),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  '/cadastro',
                                );
                              },
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _fazerLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0D7E2),
                            foregroundColor: Colors.black87,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
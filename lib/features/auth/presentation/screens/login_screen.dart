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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final client = http.Client();
    var autenticado = false;

    try {
      final resposta = await client
          .post(
            Uri.parse(
              'http://localhost:8081/api/admin/login',
            ),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'senha': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (!mounted) return;

      debugPrint('Login: HTTP ${resposta.statusCode}');

      final recebido = jsonDecode(
        utf8.decode(resposta.bodyBytes),
      );

      if (recebido is! Map<String, dynamic>) {
        throw const FormatException(
          'Resposta inválida do servidor.',
        );
      }

      final dados = recebido;

      if (resposta.statusCode != 200) {
        final mensagem = dados['mensagem'] ??
            dados['erro'] ??
            dados['error'];

        _mostrarMensagem(
          mensagem is String && mensagem.trim().isNotEmpty
              ? mensagem
              : 'Não foi possível realizar o login. '
                  'HTTP ${resposta.statusCode}.',
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
      if (!mounted) return;

      _mostrarMensagem(
        'O servidor demorou para responder. Tente novamente.',
      );
    } on FormatException {
      if (!mounted) return;

      _mostrarMensagem(
        'O servidor retornou uma resposta inválida.',
      );
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao fazer login: $erro');

      _mostrarMensagem(
        'Não foi possível conectar ao servidor.',
      );
    } finally {
      client.close();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (!mounted || !autenticado) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  InputDecoration _decoracao(String titulo) {
    return InputDecoration(
      labelText: titulo,
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
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
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E2FE)
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration: _decoracao('Gmail:'),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Por favor, digite seu e-mail';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _decoracao('Password:'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }

                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/cadastro',
                              );
                            },
                            child: const Text(
                              'Create account',
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
                              onPressed:
                                  _isLoading ? null : _fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFD0D7E2),
                                foregroundColor: Colors.black87,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
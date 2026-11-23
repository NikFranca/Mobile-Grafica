// Importa a biblioteca principal do Flutter baseada em Material Design para usar widgets como Scaffold, Text, etc.
import 'package:flutter/material.dart';

// Importa o pacote HTTP para permitir que o aplicativo faça requisições web (POST, GET) para a API.
import 'package:http/http.dart' as http;

// Importa a biblioteca de conversão para transformar dados em formato JSON e vice-versa.
import 'dart:convert';

// Define a classe LoginScreen que herda de StatefulWidget porque ela possui estados que mudam (como o loading e os textos).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Classe de estado correspondente à LoginScreen, onde toda a lógica e a interface interativa residem.
class _LoginScreenState extends State<LoginScreen> {
  // Controlador para monitorar e capturar o que o usuário digita no campo de e-mail.
  final _emailController = TextEditingController();

  // Controlador para monitorar e capturar o que o usuário digita no campo de senha.
  final _passwordController = TextEditingController();

  // Chave global usada para identificar, gerenciar e disparar as validações do formulário.
  final _formKey = GlobalKey<FormState>();

  // Variável booleana para controlar quando o botão deve exibir o indicador de carregamento (spinner).
  bool _isLoading = false;

  // Método executado automaticamente quando a tela é destruída, limpando os controladores da memória para evitar vazamentos.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função assíncrona responsável por validar os campos locais e enviar a requisição de login para a API.
  Future<void> _fazerLogin() async {
    // Verifica se todos os validadores dos campos do formulário retornaram sucesso (sem erros).
    if (_formKey.currentState!.validate()) {
      // Atualiza o estado da tela para ativar o carregamento e desativar o botão.
      setState(() {
        _isLoading = true;
      });

      // Remove espaços extras e armazena o texto digitado no campo de e-mail.
      final String email = _emailController.text.trim();
      
      // Remove espaços extras e armazena o texto digitado no campo de senha.
      final String password = _passwordController.text.trim();

      // Define o endereço da rota da API que vai receber os dados de login.
      final Uri url = Uri.parse('http://localhost:5000/api/usuarios/login');

      try {
        // Dispara uma requisição HTTP do tipo POST para a API enviando os dados em JSON.
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        // Verifica se o widget ainda está montado na tela antes de continuar, prevenindo erros de contexto assíncrono.
        if (!mounted) return;

        // Se a API retornar código 200 (OK) ou 201 (Criado/Autorizado), o login deu certo.
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Exibe uma barra de notificação (SnackBar) informando o sucesso ao usuário.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );

          // Redireciona para a rota 'home' e remove a tela de login atual da pilha de navegação.
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Caso a API retorne um código de erro (credenciais inválidas), exibe uma mensagem de falha.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-mail ou senha inválidos.')),
          );
        }
      } catch (e) {
        // Se ocorrer um erro de rede (ex: API desligada), captura a exceção e avisa o usuário.
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
        );
      } finally {
        // Bloco executado sempre ao final (com sucesso ou erro), desativando o estado de carregamento.
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Método que constrói visualmente os elementos da interface da tela de login.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo padrão da tela inteira.
      backgroundColor: const Color(0xFF0B132B),
      // Garante que o conteúdo não fique sobreposto à barra de status ou entalhes físicos do aparelho.
      body: SafeArea(
        child: Center(
          // Permite que o conteúdo role caso o teclado virtual cubra a tela.
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Caixa centralizada que abriga o formulário de login com bordas arredondadas e sombra.
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
                  // Agrupa os campos de entrada de dados sob validação controlada pela chave.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo de texto para digitar o e-mail.
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Gmail:',
                            labelStyle: const TextStyle(color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          // Validador local para garantir que o campo não esteja vazio.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu e-mail';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Campo de texto para digitar a senha (com caracteres ocultos).
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password:',
                            labelStyle: const TextStyle(color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          // Validador local para checar se a senha preenche os requisitos mínimos.
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
                        // Botão em formato de texto para redirecionar o usuário para a tela de cadastro.
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              // Comando de navegação para abrir a tela de registro/criação de usuário.
                              Navigator.pushNamed(context, '/cadastro');
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
                        // Botão principal de confirmação ("Sign In").
                        Center(
                          child: SizedBox(
                            width: 140,
                            child: ElevatedButton(
                              // Se estiver carregando (_isLoading = true), o botão fica desativado (null).
                              onPressed: _isLoading ? null : _fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD0D7E2),
                                foregroundColor: Colors.black87,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              // Mostra um ícone circular de carregamento se estiver processando, ou o texto padrão.
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Sign In',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
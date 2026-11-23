// Importa a biblioteca principal do Flutter baseada em Material Design para usar componentes visuais (Scaffold, Text, etc.).
import 'package:flutter/material.dart';

// Importa o pacote HTTP para permitir que o aplicativo realize requisições web (como POST para a API em C#).
import 'package:http/http.dart' as http;

// Importa a biblioteca de conversão para lidar com a formatação e tradução de dados em JSON.
import 'dart:convert';

// Define a classe CadastroScreen como um StatefulWidget por gerenciar estados mutáveis (como campos de texto e carregamento).
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

// Classe de estado correspondente à CadastroScreen, onde toda a lógica e a interface interativa residem.
class _CadastroScreenState extends State<CadastroScreen> {
  // Controlador para monitorar, capturar e manipular o texto digitado no campo de nome.
  final _nomeController = TextEditingController();

  // Controlador para monitorar, capturar e manipular o texto digitado no campo de e-mail.
  final _emailController = TextEditingController();

  // Controlador para monitorar, capturar e manipular o texto digitado no campo de CPF.
  final _cpfController = TextEditingController();

  // Controlador para monitorar, capturar e manipular o texto digitado no campo de senha.
  final _passwordController = TextEditingController();

  // Controlador para monitorar, capturar e manipular o texto digitado no campo de confirmação de senha.
  final _confirmPasswordController = TextEditingController();

  // Chave global utilizada para identificar e disparar as validações do formulário de cadastro.
  final _formKey = GlobalKey<FormState>();

  // Variável booleana para gerenciar quando o botão de criar conta deve exibir o indicador de progresso (spinner).
  bool _isLoading = false;

  // Método executado automaticamente quando a tela é descartada da memória, limpando todos os controladores para evitar vazamentos.
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função assíncrona responsável por validar os campos locais, conferir as senhas e enviar a requisição HTTP para a API.
  Future<void> _fazerCadastro() async {
    // Verifica se todos os validadores dos campos do formulário retornaram sem erros.
    if (_formKey.currentState!.validate()) {
      // Checa se a senha digitada é exatamente igual à senha de confirmação.
      if (_passwordController.text != _confirmPasswordController.text) {
        // Exibe uma mensagem flutuante (SnackBar) alertando que as senhas não coincidem.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem.')),
        );
        // Interrompe a execução caso as senhas estejam diferentes.
        return;
      }

      // Altera o estado para ativar o indicador de carregamento e desativar o botão de envio.
      setState(() {
        _isLoading = true;
      });

      // Define a rota e o endereço da API C#/.NET que vai receber os dados de registro.
      final Uri url = Uri.parse('http://localhost:5000/api/usuarios/registrar');

      try {
        // Dispara uma requisição POST assíncrona para a API enviando os dados mapeados em JSON.
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': _nomeController.text.trim(),
            'email': _emailController.text.trim(),
            'cpf': _cpfController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        // Verifica se o widget ainda continua ativo na árvore de elementos antes de interagir com o contexto.
        if (!mounted) return;

        // Verifica se a API retornou código de sucesso (200 OK ou 201 Created).
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Exibe uma notificação de sucesso informando que a conta foi criada.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso!')),
          );
          // Remove a tela de cadastro atual da pilha e retorna para a tela anterior (login).
          Navigator.pop(context);
        } else {
          // Caso a API recuse o cadastro, exibe uma mensagem de falha genérica.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao criar conta. Verifique os dados.')),
          );
        }
      } catch (e) {
        // Captura exceções de rede (como servidor desligado ou falha de conexão).
        if (!mounted) return;
        // Informa o usuário sobre o problema de conectividade com o servidor.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
        );
      } finally {
        // Bloco executado independentemente de sucesso ou falha para restaurar o estado padrão do botão.
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Método responsável por construir e renderizar a interface gráfica da tela de cadastro.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo padrão para toda a tela.
      backgroundColor: const Color(0xFF0B132B),
      // Garante que o conteúdo respeite as áreas seguras do dispositivo (evitando entalhes e barras do sistema).
      body: SafeArea(
        child: Center(
          // Permite que a tela inteira role caso o teclado virtual cubra os inputs.
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container centralizado com cantos arredondados, preenchimento e sombra estilizada.
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
                  // Agrupa os campos de texto sob a validação estruturada do formulário.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo de texto dedicado à inserção do nome do usuário.
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
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
                          // Valida se o campo de nome foi preenchido corretamente.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Campo de texto dedicado à inserção do e-mail.
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
                          // Valida se o campo de e-mail está vazio.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu e-mail';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Campo de texto dedicado à inserção do CPF.
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CPF:',
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
                          // Valida se o campo de CPF está preenchido.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu CPF';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Campo de texto dedicado à inserção da senha (com caracteres ocultos).
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha:',
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
                          // Valida se a senha está vazia ou possui menos de 6 caracteres.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }
                            if (value.length < 6) {
                              return 'Mínimo de 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Campo de texto dedicado à confirmação da senha (com caracteres ocultos).
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha:',
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
                          // Valida se a confirmação de senha foi preenchida.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Alinha o botão de texto para retornar à tela de login no centro.
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            // Ao pressionar, remove a tela de cadastro e volta para o login.
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login account',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Centraliza e define as dimensões do botão principal de ação ("Criar").
                        Center(
                          child: SizedBox(
                            width: 140,
                            child: ElevatedButton(
                              // Se estiver carregando (_isLoading = true), o botão é desativado atribuindo null ao onPressed.
                              onPressed: _isLoading ? null : _fazerCadastro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD0D7E2),
                                foregroundColor: Colors.black87,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              // Alterna entre o indicador circular de progresso e o texto padrão do botão dependendo do estado de carregamento.
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Criar',
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
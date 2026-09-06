// Importa o pacote de componentes visuais do Flutter baseados no Material Design.
import 'package:flutter/material.dart';

// Declara um widget com estado (StatefulWidget) chamado LoginScreen para a tela de login.
class LoginScreen extends StatefulWidget {
  // Construtor da classe, aceitando opcionalmente uma chave (key) para identificação na árvore de widgets.
  const LoginScreen({super.key});

  // Cria o estado interno associado a esta tela, instanciando a classe _LoginScreenState.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Classe que gerencia o estado e a lógica da tela de login.
class _LoginScreenState extends State<LoginScreen> {
  // Controlador para gerenciar e capturar o texto digitado no campo de e-mail.
  final _emailController = TextEditingController();
  
  // Controlador para gerenciar e capturar o texto digitado no campo de senha.
  final _passwordController = TextEditingController();
  
  // Chave global usada para identificar e validar o formulário.
  final _formKey = GlobalKey<FormState>();

  // Método executado quando o widget é destruído da árvore, liberando recursos da memória.
  @override
  void dispose() {
    // Descarta o controlador de e-mail para evitar vazamento de memória.
    _emailController.dispose();
    
    // Descarta o controlador de senha para evitar vazamento de memória.
    _passwordController.dispose();
    
    // Chama o método dispose da classe pai (State).
    super.dispose();
  }

  // Função chamada ao tentar realizar o login.
  void _fazerLogin() {
    // Verifica se todos os validadores dos campos do formulário passaram com sucesso.
    if (_formKey.currentState!.validate()) {
      // Armazena o texto atual do campo de e-mail na variável 'email'.
      String email = _emailController.text;
      
      // Exibe uma mensagem no console simulando a tentativa de login com o e-mail informado.
      print('Tentando logar com: $email');
    }
  }

  // Método principal que constrói a interface gráfica (UI) da tela.
  @override
  Widget build(BuildContext context) {
    // Retorna a estrutura visual padrão de uma página do Flutter (Scaffold).
    return Scaffold(
      // Define a cor de fundo da tela inteira como um azul escuro personalizado.
      backgroundColor: const Color(0xFF0B132B), 
      
      // Restringe o conteúdo para que ele não fique sobre áreas de interrupção do celular (como entalhes ou barras de navegação).
      body: SafeArea(
        // Centraliza o conteúdo filho na tela.
        child: Center(
          // Permite que a tela seja rolável caso o conteúdo ultrapasse a altura da tela (útil quando o teclado abre).
          child: SingleChildScrollView(
            // Adiciona um espaçamento interno horizontal de 24 pixels nas bordas.
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            
            // Organiza os elementos filhos verticalmente em uma coluna.
            child: Column(
              // Alinha os elementos verticalmente no centro da coluna.
              mainAxisAlignment: MainAxisAlignment.center,
              
              // Lista de componentes exibidos dentro da coluna.
              children: [
                
                // Alinha o widget filho dentro dele.
                Align(
                  // Posiciona o elemento no canto superior direito do espaço disponível.
                  alignment: Alignment.topRight,
                  
                  // Adiciona espaçamento interno ou externo ao redor do filho.
                  child: Padding(
                    // Aplica margem inferior de 40 pixels e margem à direita de 8 pixels.
                    padding: const EdgeInsets.only(bottom: 40.0, right: 8.0),
                    
                    // Caixa invisível ou estilizável usada para definir dimensões para a logo em texto.
                    child: Container(
                      // Define a altura do container como 40 pixels.
                      height: 40,
                      
                      // Define a largura do container como 80 pixels.
                      width: 80,
                      
                      // Deixa a cor do container transparente.
                      color: Colors.transparent,
                      
                      // Centraliza o texto "CSV" dentro do container.
                      child: const Center(
                        // Exibe o texto simulando a logo.
                        child: Text(
                          'CSV',
                          // Estilização do texto da logo.
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Container centralizado com bordas arredondadas e efeito de cartão para os inputs.
                Container(
                  // Adiciona preenchimento interno de 24 pixels em todos os lados.
                  padding: const EdgeInsets.all(24.0),
                  
                  // Decoração visual do container (cor translúcida, bordas e sombras).
                  decoration: BoxDecoration(
                    // Define a cor de fundo do cartão como um azul claro com opacidade.
                    color: const Color(0xFFD6E2FE).withValues(alpha: 0.85),
                    
                    // Arredonda as pontas do container em 24 pixels.
                    borderRadius: BorderRadius.circular(24.0),
                    
                    // Adiciona uma lista de sombras ao redor do container.
                    boxShadow: [
                      BoxShadow(
                        // Define a cor da sombra baseada em ciano com transparência.
                        color: Colors.cyan..withValues(alpha: 0.85),
                        
                        // Define o raio de desfoque da sombra.
                        blurRadius: 20,
                        
                        // Define o quanto a sombra se espalha.
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  
                  // Agrupa os campos de texto em um formulário para gerenciar validações.
                  child: Form(
                    // Associa a chave global de formulário criada anteriormente.
                    key: _formKey,
                    
                    // Organiza os campos de entrada verticalmente dentro do formulário.
                    child: Column(
                      // Estica os filhos horizontalmente para preencherem a largura do container.
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      
                      // Faz a coluna ocupar apenas o espaço vertical necessário para seus filhos.
                      mainAxisSize: MainAxisSize.min,
                      
                      // Lista de elementos de entrada do formulário.
                      children: [
                        
                        // Campo de texto interativo específico para o e-mail.
                        TextFormField(
                          // Conecta o campo ao controlador de e-mail.
                          controller: _emailController,
                          
                          // Altera o teclado do celular para o layout focado em endereços de e-mail.
                          keyboardType: TextInputType.emailAddress,
                          
                          // Configura a aparência visual do input.
                          decoration: InputDecoration(
                            // Texto flutuante/rótulo do campo.
                            labelText: 'Gmail:',
                            
                            // Estilização da cor do texto do rótulo.
                            labelStyle: const TextStyle(color: Colors.black54),
                            
                            // Ativa o preenchimento de cor no fundo do input.
                            filled: true,
                            
                            // Cor de fundo do campo de texto com opacidade.
                            fillColor: Colors.white.withValues(alpha: 0.85),
                            
                            // Define a borda do campo de texto.
                            border: OutlineInputBorder(
                              // Arredonda as bordas do input em 12 pixels.
                              borderRadius: BorderRadius.circular(12.0),
                              
                              // Remove a linha padrão de contorno da borda.
                              borderSide: BorderSide.none,
                            ),
                            
                            // Espaçamento interno do texto digitado dentro do input.
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          
                          // Função de validação executada ao disparar a validação do formulário.
                          validator: (value) {
                            // Verifica se o texto está nulo ou vazio.
                            if (value == null || value.isEmpty) {
                              // Retorna mensagem de erro se o campo estiver vazio.
                              return 'Por favor, digite seu e-mail';
                            }
                            // Retorna nulo se estiver tudo correto (sem erros).
                            return null;
                          },
                        ),
                        
                        // Caixa invisível usada para criar um espaçamento vertical de 16 pixels.
                        const SizedBox(height: 16),
                        
                        // Campo de texto interativo específico para a senha.
                        TextFormField(
                          // Conecta o campo ao controlador de senha.
                          controller: _passwordController,
                          
                          // Oculta os caracteres digitados (substituindo por pontos) para segurança.
                          obscureText: true,
                          
                          // Configura a aparência visual do input de senha.
                          decoration: InputDecoration(
                            // Rótulo do campo.
                            labelText: 'Password:',
                            
                            // Estilização do rótulo.
                            labelStyle: const TextStyle(color: Colors.black54),
                            
                            // Ativa o preenchimento de cor de fundo.
                            filled: true,
                            
                            // Cor de fundo esbranquiçada com opacidade.
                            fillColor: Colors.white.withValues(alpha: 0.85),
                            
                            // Configuração da borda arredondada sem linha de contorno.
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            
                            // Espaçamento interno do input.
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          
                          // Função de validação para a senha.
                          validator: (value) {
                            // Verifica se está vazio.
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }
                            // Verifica se a senha possui menos de 6 caracteres.
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            // Retorna nulo se passou por todas as validações.
                            return null;
                          },
                        ),
                        
                        // Espaçamento vertical de 12 pixels.
                        const SizedBox(height: 12),
                        
                        // Alinha o botão de texto para criar conta.
                        Align(
                          // Centraliza o link horizontalmente.
                          alignment: Alignment.center,
                          
                          // Botão com visual semelhante a um texto simples (clicável).
                          child: TextButton(
                            // Ação executada ao pressionar o botão de criar conta.
                            onPressed: () {
                              // Exemplo de navegação para uma página vazia/outra tela usando rotas nomeadas.
                              // Substitua '/register' pela rota da sua página de cadastro.
                              // Navigator.pushNamed(context, '/register');
                              
                              // Alternativa direta com MaterialPageRoute (caso não use rotas nomeadas):
                              /*
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                              */
                            },
                            
                            // O texto exibido no botão.
                            child: const Text(
                              'Create account',
                              // Estilização do texto indicando que é um link clicável azul.
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        // Espaçamento vertical de 12 pixels.
                        const SizedBox(height: 12),
                        
                        // Centraliza o botão de Sign In.
                        Center(
                          // Restringe a largura do botão para 140 pixels.
                          child: SizedBox(
                            width: 140,
                            
                            // Botão elevado padrão do Material Design.
                            child: ElevatedButton(
                              // Associa a função de clique ao método de login criado na classe.
                              onPressed: _fazerLogin,
                              
                              // Estilização avançada do botão (cores, sombras e bordas).
                              style: ElevatedButton.styleFrom(
                                // Cor de fundo cinza-azulado claro do botão.
                                backgroundColor: const Color(0xFFD0D7E2),
                                
                                // Cor do texto/ícone de primeiro plano.
                                foregroundColor: Colors.black87,
                                
                                // Elevação da sombra do botão.
                                elevation: 4,
                                
                                // Formato das bordas do botão (totalmente arredondadas).
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                
                                // Preenchimento interno vertical do botão.
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              
                              // Texto exibido na parte interna do botão.
                              child: const Text(
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
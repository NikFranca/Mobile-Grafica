import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  // ============================================================
  // CONTROLADORES DOS CAMPOS
  // ============================================================

  // Guarda o que foi digitado no campo Nome
  final nomeController = TextEditingController();

  // Guarda o que foi digitado no campo Preço
  final precoController = TextEditingController();

  // Guarda o que foi digitado no campo Descrição
  final descricaoController = TextEditingController();

  // ============================================================
  // IMAGEM
  // ============================================================

  // Guarda a imagem selecionada pelo usuário.
  // O "?" significa que ela pode começar sem nenhuma imagem.
  PlatformFile? imagemSelecionada;

  // Função responsável por abrir o seletor de imagens
  Future<void> selecionarImagem() async {
    // Abre o seletor de arquivos.
    // FileType.image permite selecionar somente imagens.
    final resultado = await FilePicker.pickFiles(type: FileType.image);

    // Verifica se o usuário realmente escolheu alguma imagem.
    if (resultado != null && resultado.isNotEmpty) {
      setState(() {
        // Guarda a primeira imagem escolhida.
        imagemSelecionada = resultado.first;
      });

      // Mostra no terminal o nome da imagem selecionada.
      debugPrint('Imagem selecionada: ${imagemSelecionada!.name}');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  // Quando a tela for fechada, libera os controladores da memória.
  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    descricaoController.dispose();

    super.dispose();
  }

  // ============================================================
  // INTERFACE DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor azul escura do fundo.
      backgroundColor: const Color(0xFF081129),

      body: SafeArea(
        child: Column(
          children: [
            // Expanded faz o conteúdo ocupar o espaço disponível.
            Expanded(
              // Permite rolar a tela caso não caiba tudo.
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),

                child: Column(
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 45,
                          height: 45,

                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),

                          // Ícone provisório do logo.
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // Espaço entre o logo e o campo Nome.
                    const SizedBox(height: 30),

                    // ==================================================
                    // CAMPO NOME
                    // ==================================================
                    TextField(
                      // Liga o campo ao controlador do nome.
                      controller: nomeController,

                      // Centraliza o texto.
                      textAlign: TextAlign.center,

                      decoration: InputDecoration(
                        // Texto mostrado quando o campo está vazio.
                        hintText: 'Nome',

                        // Ativa uma cor de fundo no campo.
                        filled: true,

                        // Cor azul clara.
                        fillColor: const Color(0xFF8FA8E8),

                        // Configuração da borda.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // CAMPO PREÇO
                    // ==================================================
                    TextField(
                      // Liga o campo ao controlador do preço.
                      controller: precoController,

                      // Centraliza o texto.
                      textAlign: TextAlign.center,

                      // No celular, solicita o teclado numérico.
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      // Impede que letras sejam digitadas.
                      //
                      // Permitidos:
                      // números 0-9
                      // vírgula
                      // ponto
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],

                      decoration: InputDecoration(
                        hintText: 'Preço',

                        // Coloca "R$" antes do valor.
                        prefixText: 'R\$ ',

                        filled: true,
                        fillColor: const Color(0xFF8FA8E8),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // SELEÇÃO DA IMAGEM
                    // ==================================================
                    InkWell(
                      // Quando clicar no quadrado,
                      // executa selecionarImagem().
                      onTap: selecionarImagem,

                      child: Container(
                        width: double.infinity,
                        height: 160,

                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE8F5),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Center(
                          // Se nenhuma imagem foi escolhida,
                          // mostra o símbolo de "+".
                          //
                          // Se uma imagem foi escolhida,
                          // mostra o nome do arquivo.
                          child: imagemSelecionada == null
                              ? const Icon(
                                  Icons.add,
                                  size: 70,
                                  color: Color(0xFF9BE5BB),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 45,
                                      color: Colors.green,
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      'Imagem selecionada',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // Mostra o nome do arquivo escolhido.
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        imagemSelecionada!.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // CAMPO DESCRIÇÃO
                    // ==================================================
                    TextField(
                      // Liga o campo ao controlador da descrição.
                      controller: descricaoController,

                      // Permite que o campo tenha várias linhas.
                      maxLines: 3,

                      textAlign: TextAlign.center,

                      decoration: InputDecoration(
                        hintText: 'Descrição',

                        filled: true,
                        fillColor: const Color(0xFFDCE8F5),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // BOTÃO ENVIAR
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton(
                        onPressed: () {
                          // Por enquanto o botão apenas mostra
                          // os dados no terminal.

                          debugPrint('Nome: ${nomeController.text}');

                          debugPrint('Preço: R\$ ${precoController.text}');

                          debugPrint('Descrição: ${descricaoController.text}');

                          // Verifica se uma imagem foi escolhida.
                          if (imagemSelecionada != null) {
                            debugPrint('Imagem: ${imagemSelecionada!.name}');
                          } else {
                            debugPrint('Nenhuma imagem selecionada');
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          // Cor verde do botão.
                          backgroundColor: const Color(0xFF13C28A),

                          // Cor do texto.
                          foregroundColor: Colors.white,

                          // Deixa o botão arredondado.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),

                        child: const Text(
                          'Enviar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // BARRA DE NAVEGAÇÃO INFERIOR
            // ==========================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 12),

              child: Container(
                height: 55,

                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    // ==================================================
                    // HOME
                    // ==================================================

                    IconButton(
                      onPressed: () {
                        debugPrint('Home');
                      },

                      icon: const Icon(Icons.home, size: 34),
                    ),

                    // ==================================================
                    // PESQUISAR
                    // ==================================================
                    IconButton(
                      onPressed: () {
                        debugPrint('Pesquisar');
                      },

                      icon: const Icon(Icons.search, size: 34),
                    ),

                    // ==================================================
                    // ADICIONAR
                    // ==================================================
                    IconButton(
                      onPressed: () {
                        debugPrint('Adicionar');
                      },

                      icon: const Icon(Icons.add_circle_outline, size: 34),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

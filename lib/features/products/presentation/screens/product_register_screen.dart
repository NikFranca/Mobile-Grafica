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

  final nomeController = TextEditingController();
  final precoController = TextEditingController();
  final descricaoController = TextEditingController();

  // ============================================================
  // IMAGEM
  // ============================================================

  // Guarda a imagem selecionada pelo usuário
  PlatformFile? imagemSelecionada;

  // Função responsável por abrir o seletor de imagens
  Future<void> selecionarImagem() async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);

    // Verifica se o usuário realmente selecionou uma imagem
    if (resultado != null && resultado.isNotEmpty) {
      setState(() {
        imagemSelecionada = resultado.first;
      });

      debugPrint('Imagem selecionada: ${imagemSelecionada!.name}');
    }
  }

  // ============================================================
  // LIBERA OS CONTROLADORES
  // ============================================================

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    descricaoController.dispose();

    super.dispose();
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: const Color(0xFF081129),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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

                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // CAMPO NOME
                    // ==================================================
                    TextField(
                      controller: nomeController,

                      textAlign: TextAlign.center,

                      decoration: InputDecoration(
                        hintText: 'Nome',

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
                    // CAMPO PREÇO
                    // ==================================================
                    TextField(
                      controller: precoController,

                      textAlign: TextAlign.center,

                      // Abre teclado numérico no celular
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      // Permite somente:
                      // números
                      // vírgula
                      // ponto
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],

                      decoration: InputDecoration(
                        hintText: 'Preço',

                        // Adiciona R$ antes do valor
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
                    // SELECIONAR IMAGEM
                    // ==================================================
                    InkWell(
                      // Ao clicar, abre os arquivos
                      onTap: selecionarImagem,

                      child: Container(
                        width: double.infinity,
                        height: 160,

                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE8F5),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Center(
                          // Se nenhuma imagem foi selecionada,
                          // mostra o +
                          child: imagemSelecionada == null
                              ? const Icon(
                                  Icons.add,
                                  size: 70,
                                  color: Color(0xFF9BE5BB),
                                )
                              // Se já existe uma imagem,
                              // mostra confirmação
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
                      controller: descricaoController,

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
                          // Mostra os dados no terminal
                          debugPrint('Nome: ${nomeController.text}');

                          debugPrint('Preço: R\$ ${precoController.text}');

                          debugPrint('Descrição: ${descricaoController.text}');

                          // Verifica se existe uma imagem
                          if (imagemSelecionada != null) {
                            debugPrint('Imagem: ${imagemSelecionada!.name}');
                          } else {
                            debugPrint('Nenhuma imagem selecionada');
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF13C28A),

                          foregroundColor: Colors.white,

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
            // BARRA INFERIOR
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
                    // BOTÃO HOME
                    // ==================================================

                    IconButton(
                      onPressed: () {
                        // Abre a rota /home.
                        //
                        // pushReplacementNamed substitui a tela atual
                        // pela Home.
                        Navigator.pushReplacementNamed(context, '/home');
                      },

                      icon: const Icon(Icons.home, size: 34),
                    ),

                    // ==================================================
                    // BOTÃO PESQUISAR
                    // ==================================================
                    IconButton(
                      onPressed: () {
                        // Ainda não possui navegação
                        debugPrint('Pesquisar');
                      },

                      icon: const Icon(Icons.search, size: 34),
                    ),

                    // ==================================================
                    // BOTÃO ADICIONAR
                    // ==================================================
                    IconButton(
                      onPressed: () {
                        // Você já está na tela de adicionar produto
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

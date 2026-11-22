import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

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
  final categoriaController = TextEditingController();
  final ProdutoApi _produtoApi = ProdutoApi();

  bool _enviando = false;
  bool produtoAtivo = true;

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _enviarProduto() async {
    if (_enviando) return;

    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final categoria = categoriaController.text.trim();
    final ativo = produtoAtivo;

    final preco = double.tryParse(
      precoController.text.trim().replaceAll(',', '.'),
    );

    if (nome.isEmpty || descricao.isEmpty || categoria.isEmpty) {
      _mostrarMensagem('Preencha nome, descrição e categoria.');
      return;
    }

    if (preco == null || !preco.isFinite || preco <= 0) {
      _mostrarMensagem('Informe um preço maior que zero, como 25,90.');
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      await _produtoApi.cadastrarProduto(
        nome: nome,
        descricao: descricao,
        preco: preco,
        categoria: categoria,
        ativo: ativo,
      );

      if (!mounted) return;

      _mostrarMensagem('Produto cadastrado com sucesso!');
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao cadastrar produto: $erro');

      _mostrarMensagem(erro.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  // ============================================================
  // IMAGEM
  // ============================================================

  // Guarda a imagem selecionada pelo usuário
  PlatformFile? imagemSelecionada;

  get bottomNavigationBar => const AppBottomBar(selectedIndex: 2);

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
    categoriaController.dispose();

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
                    // CAMPO CATEGORIA
                    // ==================================================
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: const Text('Selecione uma categoria'),
                      dropdownColor: const Color(0xFF8FA8E8),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        color: Color(0xFF081129),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF8FA8E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: CategoriaProduto.values.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria.titulo,
                          child: Text(categoria.titulo),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        categoriaController.text = valor ?? '';
                      },
                    ),

                    const SizedBox(height: 16),

                    // INTERRUPTOR ATIVO
                    Material(
                      color: const Color(0xFFDCE8F5),
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: const Text(
                          'Produto ativo',
                          style: TextStyle(
                            color: Color(0xFF081129),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(produtoAtivo ? 'Ativado' : 'Desativado'),
                        activeTrackColor: const Color(0xFF13C28A),
                        value: produtoAtivo,
                        onChanged: (valor) {
                          setState(() {
                            produtoAtivo = valor;
                          });
                        },
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
                        onPressed: _enviando ? null : _enviarProduto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF13C28A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF13C28A)
                              .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _enviando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Enviar',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // O widget daBARRA INFERIOR
            bottomNavigationBar,
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() =>
      _ProductRegisterScreenState();
}

class _ProductRegisterScreenState
    extends State<ProductRegisterScreen> {
  final nomeController = TextEditingController();
  final precoController = TextEditingController();
  final descricaoController = TextEditingController();
  final categoriaController = TextEditingController();

  final ProdutoApi _produtoApi = const ProdutoApi();

  bool _enviando = false;
  bool _selecionandoImagem = false;
  bool produtoAtivo = true;

  Uint8List? _imagemBytes;
  String? _nomeImagem;
  String? _imagemUrlEnviada;

  bool get _ocupado => _enviando || _selecionandoImagem;

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> selecionarImagem() async {
    if (_ocupado) return;

    setState(() {
      _selecionandoImagem = true;
    });

    try {
      final arquivos = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (!mounted || arquivos.isEmpty) return;

      final arquivo = arquivos.first;
      final bytes = await arquivo.readAsBytes();

      if (!mounted) return;

      if (bytes.isEmpty) {
        throw Exception('A imagem está vazia.');
      }

      if (bytes.length > ProdutoApi.limiteImagemBytes) {
        throw Exception('Escolha uma imagem de até 5 MB.');
      }

      setState(() {
        _imagemBytes = bytes;
        _nomeImagem = arquivo.name;
        _imagemUrlEnviada = null;
      });
    } catch (erro) {
      _mostrarMensagem(
        erro.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _selecionandoImagem = false;
        });
      }
    }
  }

  Future<void> _enviarProduto() async {
    if (_ocupado) return;

    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final categoria = categoriaController.text.trim();
    final ativo = produtoAtivo;
    final bytes = _imagemBytes;

    final preco = double.tryParse(
      precoController.text.trim().replaceAll(',', '.'),
    );

    if (nome.isEmpty || descricao.isEmpty || categoria.isEmpty) {
      _mostrarMensagem(
        'Preencha nome, descrição e categoria.',
      );
      return;
    }

    if (preco == null || !preco.isFinite || preco <= 0) {
      _mostrarMensagem(
        'Informe um preço maior que zero, como 25,90.',
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      var imagemUrl = _imagemUrlEnviada;

      // Primeiro envia a foto e recebe sua URL pública.
      if (bytes != null && imagemUrl == null) {
        imagemUrl = await _produtoApi.enviarImagem(bytes);

        // Reaproveita a URL se o cadastro precisar ser repetido.
        _imagemUrlEnviada = imagemUrl;
      }

      // Depois grava os dados e a URL no produto.
      await _produtoApi.cadastrarProduto(
        nome: nome,
        descricao: descricao,
        preco: preco,
        categoria: categoria,
        ativo: ativo,
        imagem: imagemUrl,
      );

      _mostrarMensagem(
        'Produto cadastrado com sucesso!',
      );
    } catch (erro) {
      debugPrint('Erro ao cadastrar produto: $erro');

      _mostrarMensagem(
        erro.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  InputDecoration _decoracao(
    String titulo, {
    Color cor = const Color(0xFF8FA8E8),
  }) {
    return InputDecoration(
      hintText: titulo,
      filled: true,
      fillColor: cor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    descricaoController.dispose();
    categoriaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    TextField(
                      controller: nomeController,
                      enabled: !_ocupado,
                      textAlign: TextAlign.center,
                      decoration: _decoracao('Nome'),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: precoController,
                      enabled: !_ocupado,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9,.]'),
                        ),
                      ],
                      decoration: _decoracao('Preço').copyWith(
                        prefixText: 'R\$ ',
                      ),
                    ),
                    const SizedBox(height: 30),
                    Material(
                      color: const Color(0xFFDCE8F5),
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _ocupado ? null : selecionarImagem,
                        child: SizedBox(
                          width: double.infinity,
                          height: 170,
                          child: _selecionandoImagem
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _imagemBytes == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 60,
                                          color: Color(0xFF13C28A),
                                        ),
                                        Text('Adicionar foto'),
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Image.memory(
                                              _imagemBytes!,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, erro, stack) {
                                                return const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 48,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _nomeImagem ??
                                                'Imagem selecionada',
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PNG, JPG ou WebP. Até 5 MB.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: descricaoController,
                      enabled: !_ocupado,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      decoration: _decoracao(
                        'Descrição',
                        cor: const Color(0xFFDCE8F5),
                      ),
                    ),
                    const SizedBox(height: 22),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: const Text('Selecione uma categoria'),
                      dropdownColor: const Color(0xFF8FA8E8),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: _decoracao('Categoria'),
                      items: CategoriaProduto.values.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria.titulo,
                          child: Text(categoria.titulo),
                        );
                      }).toList(),
                      onChanged: _ocupado
                          ? null
                          : (valor) {
                              categoriaController.text = valor ?? '';
                            },
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: const Color(0xFFDCE8F5),
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        title: const Text('Produto ativo'),
                        subtitle: Text(
                          produtoAtivo ? 'Ativado' : 'Desativado',
                        ),
                        activeTrackColor: const Color(0xFF13C28A),
                        value: produtoAtivo,
                        onChanged: _ocupado
                            ? null
                            : (valor) {
                                setState(() {
                                  produtoAtivo = valor;
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _ocupado ? null : _enviarProduto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF13C28A),
                          foregroundColor: Colors.white,
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
                            : const Text('Enviar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppBottomBar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}
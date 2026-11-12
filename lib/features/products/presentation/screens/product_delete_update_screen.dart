import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ResultadoEdicaoProduto {
  final Produto? produto;
  final bool foiExcluido;

  const ResultadoEdicaoProduto.salvo(Produto produto)
      : produto = produto,
        foiExcluido = false;

  const ResultadoEdicaoProduto.excluido()
      : produto = null,
        foiExcluido = true;
}

class ProductDeleteUpdateScreen extends StatefulWidget {
  final Produto produto;

  const ProductDeleteUpdateScreen({
    super.key,
    required this.produto,
  });

  @override
  State<ProductDeleteUpdateScreen> createState() =>
      _ProductDeleteUpdateScreenState();
}

class _ProductDeleteUpdateScreenState
    extends State<ProductDeleteUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _descricaoController;

  Uint8List? _imagemBytes;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(
      text: widget.produto.nome,
    );
    _precoController = TextEditingController(
      text: widget.produto.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    _descricaoController = TextEditingController(
      text: widget.produto.descricao,
    );
    _imagemBytes = widget.produto.imagemBytes;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  double? _lerPreco(String texto) {
    final normalizado = texto.trim().replaceAll(',', '.');

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalizado)) {
      return null;
    }

    final valor = double.tryParse(normalizado);

    if (valor == null || !valor.isFinite || valor < 0) {
      return null;
    }

    return valor;
  }

  Future<void> _selecionarImagem() async {
    try {
      final arquivos = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (arquivos.isEmpty) return;

      final bytes = await arquivos.first.readAsBytes();

      if (!mounted) return;

      if (bytes.isEmpty) {
        throw const FormatException('Imagem vazia.');
      }

      setState(() {
        _imagemBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir essa imagem.'),
        ),
      );
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final atualizado = Produto(
      nome: _nomeController.text.trim(),
      preco: _lerPreco(_precoController.text)!,
      categoria: widget.produto.categoria,
      descricao: _descricaoController.text.trim(),
      imagem: widget.produto.imagem,
      imagemBytes: _imagemBytes,
    );

    Navigator.pop(
      context,
      ResultadoEdicaoProduto.salvo(atualizado),
    );
  }

  Future<void> _deletar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deletar produto?'),
          content: Text(
            'Deseja deletar "${widget.produto.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmou != true) return;

    Navigator.pop(
      context,
      const ResultadoEdicaoProduto.excluido(),
    );
  }

  InputDecoration _decoracao(String titulo) {
    return InputDecoration(
      hintText: titulo,
      filled: true,
      fillColor: const Color(0xFF91A9E8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? imagem = _imagemBytes != null
        ? MemoryImage(_imagemBytes!)
        : widget.produto.imagem != null
            ? AssetImage(widget.produto.imagem!)
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF081129),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Editar produto'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (bodyContext) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.paddingOf(bodyContext).bottom + 16,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      decoration: _decoracao('Nome'),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o nome do produto.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
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
                      validator: (valor) {
                        if (_lerPreco(valor ?? '') == null) {
                          return 'Informe um preço como 10,50.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Toque para escolher ou trocar a imagem.
                    Material(
                      color: const Color(0xFFE5EDF9),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _selecionarImagem,
                        child: SizedBox(
                          height: 170,
                          child: imagem == null
                              ? const Icon(
                                  Icons.add,
                                  size: 64,
                                  color: Color(0xFF9BE5BB),
                                )
                              : Image(
                                  image: imagem,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: _decoracao('Descrição').copyWith(
                        fillColor: const Color(0xFFE5EDF9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _salvar,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: const Color(0xFF081129),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Salvar alterações'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _deletar,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Deletar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        selectedIndex: 1,
      ),
    );
  }
}
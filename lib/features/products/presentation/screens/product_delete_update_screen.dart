import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';
import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';

class ResultadoEdicaoProduto {
  final Produto? produto;
  final bool foiExcluido;

  const ResultadoEdicaoProduto.salvo(Produto produto)
    : produto = produto,
      foiExcluido = false;

  const ResultadoEdicaoProduto.excluido() : produto = null, foiExcluido = true;
}

class ProductDeleteUpdateScreen extends StatefulWidget {
  final Produto produto;

  const ProductDeleteUpdateScreen({super.key, required this.produto});

  @override
  State<ProductDeleteUpdateScreen> createState() =>
      _ProductDeleteUpdateScreenState();
}

class _ProductDeleteUpdateScreenState extends State<ProductDeleteUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProdutoApi _produtoApi = const ProdutoApi();

  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _descricaoController;

  Uint8List? _imagemBytes;
  CategoriaProduto? _categoriaSelecionada;

  bool _ativo = true;
  bool _salvando = false;
  bool _fotoAlterada = false;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.produto.nome);

    _precoController = TextEditingController(
      text: widget.produto.preco.toStringAsFixed(2).replaceAll('.', ','),
    );

    _descricaoController = TextEditingController(
      text: widget.produto.descricao,
    );

    _categoriaSelecionada = widget.produto.categoria;
    _ativo = widget.produto.ativo;
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

    if (valor == null || !valor.isFinite || valor <= 0) {
      return null;
    }

    return valor;
  }

  Future<void> _selecionarImagem() async {
    if (_salvando) return;

    try {
      final arquivos = await FilePicker.pickFiles(type: FileType.image);

      if (!mounted || _salvando || arquivos.isEmpty) return;

      final bytes = await arquivos.first.readAsBytes();

      if (!mounted || _salvando) return;

      if (bytes.isEmpty) {
        throw const FormatException('Imagem vazia.');
      }

      setState(() {
        _imagemBytes = bytes;
        _fotoAlterada = true;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir essa imagem.')),
      );
    }
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    if (!_formKey.currentState!.validate()) return;

    final categoria = _categoriaSelecionada!;
    final fotoFoiTrocada = _fotoAlterada;

    final atualizado = Produto(
      id: widget.produto.id,
      nome: _nomeController.text.trim(),
      preco: _lerPreco(_precoController.text)!,
      descricao: _descricaoController.text.trim(),
      categoria: categoria,
      categoriaApi: categoria.titulo,
      ativo: _ativo,
      imagem: widget.produto.imagem,
    );

    setState(() {
      _salvando = true;
    });

    try {
      final salvo = await _produtoApi.atualizarProduto(atualizado);

      if (!mounted) return;

      final mensageiro = ScaffoldMessenger.of(context);

      Navigator.pop(context, ResultadoEdicaoProduto.salvo(salvo));

      if (fotoFoiTrocada) {
        mensageiro.showSnackBar(
          const SnackBar(
            content: Text(
              'Dados salvos. A foto não foi alterada; '
              'o envio de imagens ainda não está disponível.',
            ),
          ),
        );
      }
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao editar produto: $erro');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Future<void> _deletar() async {
    if (_salvando) return;

    final id = widget.produto.id?.trim();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este produto não possui um ID válido para exclusão.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Deletar produto?'),
            content: Text('Deseja deletar "${widget.produto.nome}"?'),
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

      await _produtoApi.excluirProduto(id);

      if (!mounted) return;

      Navigator.pop(context, const ResultadoEdicaoProduto.excluido());
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao excluir produto: $erro');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  InputDecoration _decoracao(String titulo) {
    return InputDecoration(
      hintText: titulo,
      filled: true,
      fillColor: const Color(0xFF91A9E8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _imagemBytes;
    final caminho = widget.produto.imagem?.trim();

    ImageProvider<Object>? imagem;

    if (bytes != null && bytes.isNotEmpty) {
      imagem = MemoryImage(bytes);
    } else if (caminho != null && caminho.isNotEmpty) {
      final uri = Uri.tryParse(caminho);

      final imagemRemota =
          uri != null &&
          uri.host.isNotEmpty &&
          (uri.scheme == 'http' || uri.scheme == 'https');

      if (imagemRemota) {
        imagem = NetworkImage(caminho);
      } else {
        imagem = AssetImage(caminho);
      }
    }

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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.paddingOf(bodyContext).bottom + 16,
              ),
              child: AbsorbPointer(
                absorbing: _salvando,
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        decoration: _decoracao('Preço')
                            .copyWith(prefixText: 'R\$ '),
                        validator: (valor) {
                          if (_lerPreco(valor ?? '') == null) {
                            return 'Informe um preço maior que zero, como 10,50.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: const Color(0xFFE5EDF9),
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _salvando ? null : _selecionarImagem,
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
                                    errorBuilder: (context, error, stackTrace) {
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
                        decoration: _decoracao('Descrição')
                            .copyWith(fillColor: const Color(0xFFE5EDF9)),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CategoriaProduto>(
                        initialValue: _categoriaSelecionada,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF91A9E8),
                        decoration: _decoracao('Categoria'),
                        hint: const Text('Selecione uma categoria'),
                        items: CategoriaProduto.values.map((categoria) {
                          return DropdownMenuItem<CategoriaProduto>(
                            value: categoria,
                            child: Text(categoria.titulo),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            _categoriaSelecionada = valor;
                          });
                        },
                        validator: (valor) {
                          if (valor == null) {
                            return 'Selecione uma categoria.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: const Color(0xFFE5EDF9),
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: SwitchListTile(
                          title: const Text(
                            'Produto ativo',
                            style: TextStyle(
                              color: Color(0xFF081129),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(_ativo ? 'Ativado' : 'Desativado'),
                          activeTrackColor: const Color(0xFF13C28A),
                          value: _ativo,
                          onChanged: (valor) {
                            setState(() {
                              _ativo = valor;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8800),
                          foregroundColor: const Color(0xFF081129),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _salvando ? 'Salvando...' : 'Salvar alterações',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _salvando ? null : _deletar,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Deletar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomBar(selectedIndex: 1),
    );
  }
}

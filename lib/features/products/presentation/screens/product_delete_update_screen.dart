import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';

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
  final _produtoApi = const ProdutoApi();

  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _descricaoController;

  CategoriaProduto? _categoriaSelecionada;
  Uint8List? _imagemBytes;
  String? _nomeImagem;
  String? _novaImagemUrl;

  bool _imagemAlterada = false;
  bool _ativo = true;
  bool _salvando = false;
  bool _excluindo = false;
  bool _lendoImagem = false;

  bool get _ocupado => _salvando || _excluindo || _lendoImagem;

  @override
  void initState() {
    super.initState();

    final produto = widget.produto;

    _nomeController = TextEditingController(text: produto.nome);
    _precoController = TextEditingController(
      text: produto.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    _descricaoController = TextEditingController(
      text: produto.descricao,
    );

    _categoriaSelecionada = produto.categoria;
    _imagemBytes = produto.imagemBytes;
    _ativo = produto.ativo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  double? _lerPreco(String texto) {
    final normalizado = texto.trim().replaceAll(',', '.');

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalizado)) {
      return null;
    }

    final valor = double.tryParse(normalizado);
    return valor != null && valor.isFinite && valor > 0 ? valor : null;
  }

  Future<void> _selecionarImagem() async {
    if (_ocupado) return;

    setState(() => _lendoImagem = true);

    try {
      final arquivos = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (!mounted || arquivos.isEmpty) return;

      final arquivo = arquivos.first;
      final bytes = await arquivo.readAsBytes();

      if (!mounted) return;

      if (bytes.isEmpty || bytes.length > ProdutoApi.limiteImagemBytes) {
        throw const ProdutoApiException(
          'Selecione uma imagem válida de até 5 MB.',
        );
      }

      setState(() {
        _imagemBytes = bytes;
        _nomeImagem = arquivo.name;
        _imagemAlterada = true;
        _novaImagemUrl = null;
      });
    } catch (erro) {
      if (mounted) _mostrarMensagem(erro.toString());
    } finally {
      if (mounted) setState(() => _lendoImagem = false);
    }
  }

  Future<void> _salvar() async {
    if (_ocupado) return;
    if (_formKey.currentState?.validate() != true) return;

    final id = widget.produto.id;

    if (id == null || id.trim().isEmpty) {
      _mostrarMensagem('Produto sem ID. Atualize a listagem.');
      return;
    }

    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final preco = _lerPreco(_precoController.text)!;
    final categoria = _categoriaSelecionada!;
    final ativo = _ativo;
    final foto = _imagemBytes;

    setState(() => _salvando = true);

    Produto? salvo;

    try {
      if (_imagemAlterada && foto != null && _novaImagemUrl == null) {
        final url = await _produtoApi.enviarImagem(
          bytes: foto,
          nomeArquivo: _nomeImagem ?? nome,
        );

        if (!mounted) return;
        _novaImagemUrl = url;
      }

      final atualizado = Produto(
        id: id,
        nome: nome,
        preco: preco,
        descricao: descricao,
        categoria: categoria,
        categoriaApi: categoria.titulo,
        ativo: ativo,
        imagem: _novaImagemUrl ?? widget.produto.imagem,
      );

      salvo = await _produtoApi.atualizarProduto(atualizado);
    } catch (erro) {
      debugPrint('Erro ao editar produto: $erro');
      if (mounted) _mostrarMensagem(erro.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }

    if (!mounted || salvo == null) return;

    Navigator.pop(
      context,
      ResultadoEdicaoProduto.salvo(salvo),
    );
  }

  Future<void> _deletar() async {
    if (_ocupado) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deletar produto?'),
        content: Text(
          'Deseja deletar "${widget.produto.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;

    setState(() => _excluindo = true);

    var removido = false;

    try {
      await _produtoApi.excluirProduto(widget.produto.id);
      removido = true;
    } catch (erro) {
      debugPrint('Erro ao excluir produto: $erro');
      if (mounted) _mostrarMensagem(erro.toString());
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }

    if (!mounted || !removido) return;

    Navigator.pop(
      context,
      const ResultadoEdicaoProduto.excluido(),
    );
  }

  ImageProvider<Object>? _imagemAtual() {
    final bytes = _imagemBytes;

    if (bytes != null && bytes.isNotEmpty) {
      return MemoryImage(bytes);
    }

    final caminho = widget.produto.imagem?.trim();

    if (caminho == null || caminho.isEmpty) return null;

    final uri = Uri.tryParse(caminho);

    if (uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(caminho);
    }

    return AssetImage(caminho);
  }

  InputDecoration _decoracao(
    String titulo, {
    bool preco = false,
    bool descricao = false,
  }) {
    return InputDecoration(
      hintText: titulo,
      prefixText: preco ? 'R\$ ' : null,
      filled: true,
      fillColor: descricao
          ? const Color(0xFFE5EDF9)
          : const Color(0xFF91A9E8),
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

  Widget _campo(
    TextEditingController controller,
    String titulo, {
    bool preco = false,
    int linhas = 1,
    bool obrigatorio = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_ocupado,
      textAlign: linhas == 1 ? TextAlign.center : TextAlign.start,
      maxLines: linhas,
      keyboardType: preco
          ? const TextInputType.numberWithOptions(decimal: true)
          : linhas > 1
              ? TextInputType.multiline
              : TextInputType.text,
      inputFormatters: preco
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))]
          : null,
      decoration: _decoracao(
        titulo,
        preco: preco,
        descricao: linhas > 1,
      ),
      validator: (valor) {
        if (obrigatorio && (valor == null || valor.trim().isEmpty)) {
          return 'Informe $titulo.';
        }

        if (preco && _lerPreco(valor ?? '') == null) {
          return 'Informe um preço maior que zero, como 25,90.';
        }

        return null;
      },
    );
  }

  Widget _conteudoBotao(String texto, bool carregando) {
    if (!carregando) return Text(texto);

    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagem = _imagemAtual();

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
          builder: (bodyContext) => SingleChildScrollView(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _campo(_nomeController, 'Nome'),
                  const SizedBox(height: 16),
                  _campo(_precoController, 'Preço', preco: true),
                  const SizedBox(height: 16),

                  Material(
                    color: const Color(0xFFE5EDF9),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _ocupado ? null : _selecionarImagem,
                      child: SizedBox(
                        height: 170,
                        child: _lendoImagem
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : imagem == null
                                ? const Icon(
                                    Icons.add,
                                    size: 64,
                                    color: Color(0xFF9BE5BB),
                                  )
                                : Image(
                                    image: imagem,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                    ),
                                  ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _campo(
                    _descricaoController,
                    'Descrição',
                    linhas: 4,
                    obrigatorio: false,
                  ),
                  const SizedBox(height: 16),

                  if (_categoriaSelecionada == null &&
                      widget.produto.categoriaApi?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Categoria atual: ${widget.produto.categoriaApi}. '
                        'Escolha uma das opções abaixo.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),

                  DropdownButtonFormField<CategoriaProduto>(
                    initialValue: _categoriaSelecionada,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF91A9E8),
                    decoration: _decoracao('Categoria'),
                    hint: const Text('Selecione uma categoria'),
                    items: CategoriaProduto.values.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.titulo),
                      );
                    }).toList(),
                    onChanged: _ocupado
                        ? null
                        : (valor) => setState(
                              () => _categoriaSelecionada = valor,
                            ),
                    validator: (valor) =>
                        valor == null ? 'Selecione uma categoria.' : null,
                  ),

                  const SizedBox(height: 16),

                  Material(
                    color: const Color(0xFFE5EDF9),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: SwitchListTile(
                      title: const Text('Produto ativo'),
                      subtitle: Text(_ativo ? 'Ativado' : 'Desativado'),
                      activeTrackColor: const Color(0xFF13C28A),
                      value: _ativo,
                      onChanged: _ocupado
                          ? null
                          : (valor) => setState(() => _ativo = valor),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: _ocupado ? null : _salvar,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8800),
                      foregroundColor: const Color(0xFF081129),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: _conteudoBotao(
                      'Salvar alterações',
                      _salvando,
                    ),
                  ),

                  const SizedBox(height: 12),

                  FilledButton(
                    onPressed: _ocupado ? null : _deletar,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: _conteudoBotao('Deletar', _excluindo),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: IgnorePointer(
        ignoring: _ocupado,
        child: const AppBottomBar(selectedIndex: 1),
      ),
    );
  }
}
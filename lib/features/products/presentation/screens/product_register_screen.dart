import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() =>
      _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _produtoApi = const ProdutoApi();

  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _descricaoController = TextEditingController();

  CategoriaProduto? _categoria;
  Uint8List? _imagemBytes;
  String? _nomeImagem;
  String? _imagemUrlEnviada;

  bool _ativo = true;
  bool _enviando = false;
  bool _lendoImagem = false;

  bool get _ocupado => _enviando || _lendoImagem;

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
        _imagemUrlEnviada = null;
      });
    } catch (erro) {
      if (mounted) _mostrarMensagem(erro.toString());
    } finally {
      if (mounted) setState(() => _lendoImagem = false);
    }
  }

  Future<void> _enviarProduto() async {
    if (_ocupado) return;
    if (_formKey.currentState?.validate() != true) return;

    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final preco = _lerPreco(_precoController.text)!;
    final categoria = _categoria!.titulo;
    final ativo = _ativo;
    final foto = _imagemBytes;
    final nomeFoto = _nomeImagem ?? nome;

    setState(() => _enviando = true);

    var cadastrado = false;

    try {
      if (foto != null && _imagemUrlEnviada == null) {
        final url = await _produtoApi.enviarImagem(
          bytes: foto,
          nomeArquivo: nomeFoto,
        );

        if (!mounted) return;
        _imagemUrlEnviada = url;
      }

      await _produtoApi.cadastrarProduto(
        nome: nome,
        descricao: descricao,
        preco: preco,
        categoria: categoria,
        ativo: ativo,
        imagem: _imagemUrlEnviada,
      );

      cadastrado = true;
    } catch (erro) {
      debugPrint('Erro ao cadastrar produto: $erro');
      if (mounted) _mostrarMensagem(erro.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }

    if (!mounted || !cadastrado) return;

    _mostrarMensagem('Produto cadastrado com sucesso!');
    Navigator.pushReplacementNamed(context, '/filtros');
  }

  InputDecoration _decoracao(
    String titulo, {
    Color cor = const Color(0xFF8FA8E8),
    bool preco = false,
  }) {
    return InputDecoration(
      hintText: titulo,
      prefixText: preco ? 'R\$ ' : null,
      filled: true,
      fillColor: cor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String titulo, {
    bool preco = false,
    int linhas = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_ocupado,
      textAlign: TextAlign.center,
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
        cor: linhas > 1
            ? const Color(0xFFDCE8F5)
            : const Color(0xFF8FA8E8),
      ),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'Informe $titulo.';
        }

        if (preco && _lerPreco(valor) == null) {
          return 'Informe um preço maior que zero, como 25,90.';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _campo(_nomeController, 'Nome'),
                const SizedBox(height: 30),
                _campo(_precoController, 'Preço', preco: true),
                const SizedBox(height: 30),

                Material(
                  color: const Color(0xFFDCE8F5),
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _ocupado ? null : _selecionarImagem,
                    child: SizedBox(
                      height: 160,
                      child: _lendoImagem
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _imagemBytes == null
                              ? const Icon(
                                  Icons.add,
                                  size: 70,
                                  color: Color(0xFF9BE5BB),
                                )
                              : Image.memory(
                                  _imagemBytes!,
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

                const SizedBox(height: 30),
                _campo(_descricaoController, 'Descrição', linhas: 3),
                const SizedBox(height: 22),

                DropdownButtonFormField<CategoriaProduto>(
                  initialValue: _categoria,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF8FA8E8),
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
                      : (valor) => setState(() => _categoria = valor),
                  validator: (valor) =>
                      valor == null ? 'Selecione uma categoria.' : null,
                ),

                const SizedBox(height: 16),

                Material(
                  color: const Color(0xFFDCE8F5),
                  borderRadius: BorderRadius.circular(8),
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

                const SizedBox(height: 22),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _ocupado ? null : _enviarProduto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF13C28A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
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
      ),
      bottomNavigationBar: IgnorePointer(
        ignoring: _ocupado,
        child: const AppBottomBar(selectedIndex: 2),
      ),
    );
  }
}
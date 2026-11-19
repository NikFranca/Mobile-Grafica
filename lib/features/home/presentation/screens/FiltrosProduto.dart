import 'package:flutter/material.dart';

import 'package:crud_mobile_grafica/features/products/models/produto.dart';
import 'package:crud_mobile_grafica/features/products/data/produto_api.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/widgets/painel_filtros_produtos.dart';
import 'package:crud_mobile_grafica/features/products/presentation/screens/product_delete_update_screen.dart';

class FiltrosProduto extends StatefulWidget {
  const FiltrosProduto({super.key});

  @override
  State<FiltrosProduto> createState() => _FiltrosProdutoState();
}

class _FiltrosProdutoState extends State<FiltrosProduto> {
  final ProdutoApi _produtoApi = const ProdutoApi();

  List<Produto> _produtos = [];
  CategoriaProduto? _categoriaSelecionada;

  bool _painelAberto = false;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  //metodo para carregar os produtos da API
  Future<void> _carregarProdutos() async {
    if (_carregando) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      // Faz a consulta real à API pelo serviço ProdutoApi.
      final recebidos = await _produtoApi.listarProdutos();

      if (!mounted) return;

      setState(() {
        _produtos = recebidos;
        _carregando = false;
      });

      debugPrint('API: ${recebidos.length} produtos recebidos.');
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao consultar API: $erro');

      setState(() {
        _carregando = false;
        _erro = 'Não foi possível carregar os produtos da API.';
      });
    }
  }

  void _alternarPainel() {
    setState(() {
      _painelAberto = !_painelAberto;
    });
  }

  void _limparFiltro() {
    setState(() {
      _categoriaSelecionada = null;
    });
  }

  //metodo para abrir a tela de edição/exclusão do produto
  Future<void> _abrirProduto(Produto produto) async {
    final resultado = await Navigator.push<ResultadoEdicaoProduto>(
      context,
      MaterialPageRoute<ResultadoEdicaoProduto>(
        builder: (context) => ProductDeleteUpdateScreen(produto: produto),
      ),
    );

    if (!mounted || resultado == null) return;

    final idOriginal = produto.id;

    final indice = idOriginal == null || idOriginal.trim().isEmpty
        ? _produtos.indexOf(produto)
        : _produtos.indexWhere((item) => item.id == idOriginal);

    if (indice < 0) return;

    setState(() {
      if (resultado.foiExcluido) {
        _produtos.removeAt(indice);
      } else {
        _produtos[indice] = resultado.produto!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtra somente os produtos recebidos da API.
    final produtosFiltrados = _produtos.where((produto) {
      return _categoriaSelecionada == null ||
          produto.categoria == _categoriaSelecionada;
    }).toList();
    //faz a tela de listagem de produtos com filtros e mensagens de erro ou carregamento
    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF081129),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(_categoriaSelecionada?.titulo ?? 'Produtos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar produtos',
            onPressed: _carregando ? null : _carregarProdutos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: _painelAberto ? 'Fechar filtros' : 'Abrir filtros',
            onPressed: _alternarPainel,
            icon: Icon(
              _painelAberto ? Icons.close_rounded : Icons.tune_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      //faz a tela de listagem de produtos com filtros e mensagens de erro ou carregamento
      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (bodyContext) {
            final espacoInferior =
                MediaQuery.paddingOf(bodyContext).bottom + 16;

            if (_carregando) {
              return Padding(
                padding: EdgeInsets.only(bottom: espacoInferior),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (_erro != null) {
              return _mensagemCentral(
                mensagem: _erro!,
                espacoInferior: espacoInferior,
                textoBotao: 'Tentar novamente',
                onPressed: _carregarProdutos,
              );
            }

            if (_produtos.isEmpty) {
              return _mensagemCentral(
                mensagem: 'Nenhum produto cadastrado.',
                espacoInferior: espacoInferior,
                textoBotao: 'Atualizar',
                onPressed: _carregarProdutos,
              );
            }

            if (produtosFiltrados.isEmpty) {
              return _mensagemCentral(
                mensagem: 'Nenhum produto nesta categoria.',
                espacoInferior: espacoInferior,
                textoBotao: 'Mostrar todos',
                onPressed: _limparFiltro,
              );
            }

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, espacoInferior),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 210,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = produtosFiltrados[index];

                return GestureDetector(
                  onTap: () => _abrirProduto(produto),
                  child: _cardProduto(produto),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_painelAberto)
            PainelFiltrosProdutos(
              selecionada: _categoriaSelecionada,
              onSelecionar: (categoria) {
                setState(() {
                  _categoriaSelecionada = categoria;
                });
              },
              onLimpar: _limparFiltro,
            ),
          AppBottomBar(selectedIndex: 1, onSearchDoubleTap: _alternarPainel),
        ],
      ),
    );
  }

  Widget _mensagemCentral({
    required String mensagem,
    required double espacoInferior,
    required String textoBotao,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, espacoInferior),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(textoBotao)),
          ],
        ),
      ),
    );
  }

  Widget _cardProduto(Produto produto) {
    final preco = produto.preco.toStringAsFixed(2).replaceAll('.', ',');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFE5EDF9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _imagemProduto(produto)),
            const SizedBox(height: 8),
            Text(
              produto.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF081129),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (produto.categoriaApi != null) ...[
              const SizedBox(height: 2),
              Text(
                produto.categoriaApi!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'R\$ $preco',
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagemProduto(Produto produto) {
    const placeholder = Icon(
      Icons.image_not_supported_outlined,
      size: 40,
      color: Color(0xFF64748B),
    );

    final url = produto.imagem?.trim();

    if (url == null || url.isEmpty) {
      return placeholder;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return placeholder;
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return placeholder;
      },
    );
  }
}

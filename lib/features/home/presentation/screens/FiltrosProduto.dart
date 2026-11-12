import 'package:flutter/material.dart';
import 'package:crud_mobile_grafica/features/models/produto.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:crud_mobile_grafica/features/data/produtos_exemplo.dart';
import 'package:crud_mobile_grafica/features/widgets/painel_filtros_produtos.dart';

class FiltrosProduto extends StatefulWidget {
  const FiltrosProduto({super.key});

  @override
  State<FiltrosProduto> createState() => _FiltrosProdutoState();
}

class _FiltrosProdutoState extends State<FiltrosProduto> {
  CategoriaProduto? _categoriaSelecionada;
  bool _painelAberto = false;

  void _alternarPainel() {
    setState(() {
      _painelAberto = !_painelAberto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtosFiltrados = produtosExemplo.where((produto) {
      return _categoriaSelecionada == null ||
          produto.categoria == _categoriaSelecionada;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      extendBody: true,

      appBar: AppBar(
        backgroundColor: const Color(0xFF081129),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(_categoriaSelecionada?.titulo ?? 'Produtos'),
        actions: [
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

      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (bodyContext) {
            // Acompanha a altura real do painel e da barra inferior.
            final espacoInferior =
                MediaQuery.paddingOf(bodyContext).bottom + 16;

            if (produtosFiltrados.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: espacoInferior),
                child: const Center(
                  child: Text(
                    'Nenhum produto nesta categoria.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
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
                return _cardProduto(produtosFiltrados[index]);
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
                  _categoriaSelecionada = categoria as CategoriaProduto?;
                });
              },
              onLimpar: () {
                setState(() {
                  _categoriaSelecionada = null;
                });
              },
            ),

          AppBottomBar(selectedIndex: 1, onSearchDoubleTap: _alternarPainel),
        ],
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
            Expanded(
              child: produto.imagem == null
                  ? const Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: Color(0xFF64748B),
                    )
                  : Image.asset(
                      produto.imagem!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF64748B),
                        );
                      },
                    ),
            ),
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
}

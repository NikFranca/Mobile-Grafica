import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crud_mobile_grafica/models/produto.dart';

class PainelFiltrosProdutos extends StatelessWidget {
  final CategoriaProduto? selecionada;
  final ValueChanged<CategoriaProduto> onSelecionar;
  final VoidCallback onLimpar;

  const PainelFiltrosProdutos({
    super.key,
    required this.selecionada,
    required this.onSelecionar,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18,
                  sigmaY: 18,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: const Color(0xBB17233D),
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final larguraBotao = (constraints.maxWidth - 8) / 2;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Categorias',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      selecionada == null ? null : onLimpar,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white38,
                                  ),
                                  child: const Text('Limpar'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final categoria
                                    in CategoriaProduto.values)
                                  SizedBox(
                                    width: larguraBotao,
                                    child: ChoiceChip(
                                      selected: selecionada == categoria,
                                      showCheckmark: false,
                                      onSelected: (_) {
                                        onSelecionar(categoria);
                                      },
                                      backgroundColor:
                                          const Color(0xFFE5EDF9),
                                      selectedColor:
                                          const Color(0xFF2563EB),
                                      side: BorderSide.none,
                                      shape: const StadiumBorder(),
                                      label: Center(
                                        child: Text(
                                          categoria.titulo,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: selecionada == categoria
                                                ? Colors.white
                                                : const Color(0xFF081129),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
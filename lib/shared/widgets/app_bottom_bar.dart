import 'dart:ui';
import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
final int selectedIndex;
final VoidCallback? onSearchDoubleTap;

const AppBottomBar({
  super.key,
  required this.selectedIndex,
  this.onSearchDoubleTap,
});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    const routes = ['/', '/filtros', '/addProduto'];

    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      routes[index],
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(34);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Align(
        heightFactor: 1,
        alignment: Alignment.bottomCenter,
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
                height: 68,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x24FFFFFF),
                      Color(0x0AFFFFFF),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0x26FFFFFF),
                  ),
                ),
                child: Row(
                  children: [
                    _buildButton(
                      context,
                      index: 0,
                      icon: selectedIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      label: 'Início',
                    ),
                    const SizedBox(width: 4),
                    _buildButton(
                      context,
                      index: 1,
                      icon: Icons.search_rounded,
                      label: 'Pesquisar',
                    ),
                    const SizedBox(width: 4),
                    _buildButton(
                      context,
                      index: 2,
                      icon: Icons.add_rounded,
                      label: 'Adicionar',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final radius = BorderRadius.circular(29);

    return Expanded(
      flex: isSelected ? 2 : 1,
      child: Semantics(
        selected: isSelected,
        button: true,
        child: Tooltip(
          message: label,
          excludeFromSemantics: isSelected,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [
                          Color(0x3DFFFFFF),
                          Color(0x14FFFFFF),
                        ]
                      : const [
                          Color(0x0FFFFFFF),
                          Color(0x05FFFFFF),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? const Color(0x4DFFFFFF)
                      : const Color(0x14FFFFFF),
                ),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: () => _navigate(context, index),
                onDoubleTap: index == 1 ? onSearchDoubleTap : null,
                splashColor: const Color(0x30FFFFFF),
                highlightColor: const Color(0x14FFFFFF),
                child: SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 0),
                        Icon(
                          icon,
                          size: 25,
                          color: Colors.white,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
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
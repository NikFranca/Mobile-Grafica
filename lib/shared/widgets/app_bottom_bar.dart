import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomBar({
    super.key,
    required this.selectedIndex,
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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Align(
        heightFactor: 1,
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: 68,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF292929),
                  Color(0xFF191919),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF3A3A3A),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
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
                _buildButton(
                  context,
                  index: 1,
                  icon: Icons.search_rounded,
                  label: 'Pesquisar',
                ),
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
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF4B4B4B),
                          Color(0xFF363636),
                        ],
                      )
                    : null,
                border: isSelected
                    ? Border.all(color: const Color(0xFF595959))
                    : null,
              ),
              child: InkWell(
                onTap: () => _navigate(context, index),
                splashColor: const Color(0x20FFFFFF),
                highlightColor: const Color(0x10FFFFFF),
                child: SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 25,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFE5E5E5),
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
                                letterSpacing: 0.2,
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
import 'package:flutter/material.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';

int pedidos = 777;
int pagos = 390;
int pendentes = 387;
int saldo = -14;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget indicador({
    required String titulo,
    required int valor,
    required IconData icone,
    Color corValor = Colors.green,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDF9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$titulo:',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(width: 5),
            Text(
              '$valor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: corValor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icone, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),

      appBar: AppBar(
        backgroundColor: const Color(0xFF081129),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,

        // Perfil
        leadingWidth: 64,

        leading: Center(
          child: Transform.translate(
            // Offset(horizontal, vertical)
            offset: const Offset(7, 7),

            child: const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person_outline),
            ),
          ),
        ),
      ),

      body: SafeArea(
        
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Primeira linha: pedidos e saldo.
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: indicador(
                      titulo: 'Pedidos',
                      valor: pedidos,
                      icone: Icons.handshake_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDF9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$saldo',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Segunda linha: indicadores com a mesma largura.
              Row(
                children: [
                  Expanded(
                    child: indicador(
                      titulo: 'Pagos',
                      valor: pagos,
                      icone: Icons.payments,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: indicador(
                      titulo: 'Pendente',
                      valor: pendentes,
                      icone: Icons.currency_exchange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomBar(selectedIndex: 0),
    );
  }
}

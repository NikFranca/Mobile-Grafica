import 'package:flutter/material.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';

// Valores de exemplo. Ainda não vêm da API.
int pedidos = 777;
int pagos = 390;
int pendentes = 387;
int cancelados = 0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget indicador({
    required String titulo,
    required int valor,
    required IconData icone,
    required Color corValor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDF9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icone, size: 24, color: corValor),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$valor',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: corValor,
                ),
              ),
            ),
          ),
        ],
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
        leadingWidth: 64,
        leading: Center(
          child: Transform.translate(
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
              // PEDIDOS E PAGOS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: indicador(
                      titulo: 'Pedidos',
                      valor: pedidos,
                      icone: Icons.receipt_long_rounded,
                      corValor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: indicador(
                      titulo: 'Pagos',
                      valor: pagos,
                      icone: Icons.payments_rounded,
                      corValor: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // PENDENTES E CANCELADOS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: indicador(
                      titulo: 'Pendentes',
                      valor: pendentes,
                      icone: Icons.pending_actions_rounded,
                      corValor: const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: indicador(
                      titulo: 'Cancelados',
                      valor: cancelados,
                      icone: Icons.cancel_outlined,
                      corValor: const Color(0xFFDC2626),
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

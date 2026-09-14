import 'package:crud_mobile_grafica/features/home/presentation/screens/FiltrosProduto.dart';
import 'package:crud_mobile_grafica/features/products/presentation/screens/product_register_screen.dart';

import 'package:flutter/material.dart';

int pedidos = 777;
int pagos = 390;
int pendentes = 387;
int saldo = -14;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //indicador reutilizavel(função)
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

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$titulo:',
            style: const TextStyle(fontSize: 25, color: Colors.black),
          ),

          const SizedBox(width: 5),

          Text('$valor', style: TextStyle(fontSize: 25, color: corValor)),

          const SizedBox(width: 8),

          Icon(icone, size: 38, color: Colors.black),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      appBar: AppBar(
        title: const Text('Página Inicial'),
        backgroundColor: const Color(0xFF081129),
        actions: [
          Padding(
            padding: const EdgeInsetsGeometry.only(left: 14),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/personagem.png'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            //aqui tem numeros de pedidos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                indicador(
                  titulo: 'Pedidos',
                  valor: 777,
                  icone: Icons.handshake_rounded,
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EDF9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    //coloquei um numero ficticio
                    '-14',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  indicador(
                    titulo: 'Pagos',
                    valor: pagos,
                    icone: Icons.payments,
                  ),

                  indicador(
                    titulo: 'Pendente',
                    valor: pendentes,
                    icone: Icons.currency_exchange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // PENDENTE
          ],
        ),
      ),

      //aqui fica os botãos de baixo
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(vertical: 0.30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 45, color: Colors.black),
              onPressed: () {
                // Ação do botão Home
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, size: 45, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductRegisterScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                size: 45,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductRegisterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//catalago de itens

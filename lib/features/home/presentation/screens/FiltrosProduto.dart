import 'package:crud_mobile_grafica/shared/widgets/app_bottom_bar.dart';
import 'package:flutter/material.dart';

class Filtrosproduto extends StatelessWidget {
  const Filtrosproduto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),

      // =========================
      // TOPO
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFF081129),
        elevation: 0,
        actions: [
          
        ],
      ),

      // =========================
      // CORPO
      // =========================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              // =========================
              // EMBALAGENS
              // =========================
              categoriaGrande(
                titulo: 'Embalagens',
                imagem: 'assets/images/embalagens.png',
              ),

              const SizedBox(height: 8),

              // =========================
              // MOCHILAS + ESCOLAR
              // =========================
              Row(
                children: [
                  Expanded(
                    child: categoriaPequena(
                      
                      titulo: 'Mochilas',
                    
                      imagem: 'assets/images/mochilas.png',
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: categoriaPequena(
                      titulo: 'Escolar',
                      imagem: 'assets/images/escolar.png',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // CORTES + FOLHAS
              // =========================
              Row(
                children: [
                  Expanded(
                    child: categoriaPequena(
                      titulo: 'Cortes',
                      imagem: 'assets/images/cortes.png',
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: categoriaPequena(
                      titulo: 'Folhas',
                      imagem: 'assets/images/folhas.png',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // ACESSÓRIOS
              // =========================
              categoriaGrande(
                titulo: 'Acessórios',
                imagem: 'assets/images/acessorios.png',
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      // =========================
      // MENU INFERIOR
      // =========================
      bottomNavigationBar: const AppBottomBar(selectedIndex: 3),
    );
  }

  // ==================================================
  // CARD GRANDE
  // ==================================================

  Widget categoriaGrande({
    required String titulo,
    required String imagem,
  }) {
    return Container(
      width: double.infinity,
      height: 115,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE5F0),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMAGEM
          Positioned.fill(
            child: Image.asset(
              imagem,
              fit: BoxFit.cover,
            ),
          ),

          // NOME
          Positioned(
            left: 10,
            top: 4,
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // SETA
          const Positioned(
            right: 8,
            top: 3,
            child: Icon(
              Icons.arrow_forward,
              size: 28,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // CARD PEQUENO
  // ==================================================

  Widget categoriaPequena({
    required String titulo,
    required String imagem,
  }) {
    return Container(
      height: 115,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE5F0),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMAGEM
          Positioned.fill(
            child: Image.asset(
              imagem,
              fit: BoxFit.cover,
            ),
          ),

          // NOME
          Positioned(
            left: 7,
            top: 3,
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // SETA
          const Positioned(
            right: 5,
            top: 3,
            child: Icon(
              Icons.arrow_forward,
              size: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
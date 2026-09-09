import 'package:flutter/material.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final nomeController = TextEditingController();
  final precoController = TextEditingController();
  final descricaoController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    // LOGOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.grey,
                          ),
                        ),

                        Container(
                          width: 65,
                          height: 45,
                          alignment: Alignment.center,
                          child: const Text(
                            'LOGO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // CAMPO NOME
                    TextField(
                      controller: nomeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Nome',
                        filled: true,
                        fillColor: const Color(0xFF8FA8E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // CAMPO PREÇO
                    TextField(
                      controller: precoController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Preço',
                        filled: true,
                        fillColor: const Color(0xFF8FA8E8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ÁREA PARA ADICIONAR IMAGEM
                    InkWell(
                      onTap: () {
                        print('Adicionar imagem');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE8F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 50,
                            color: Color(0xFF9BE5BB),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // DESCRIÇÃO
                    TextField(
                      controller: descricaoController,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        filled: true,
                        fillColor: const Color(0xFFDCE8F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // BOTÃO ENVIAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Nome: ${nomeController.text}');
                          print('Preço: ${precoController.text}');
                          print('Descrição: ${descricaoController.text}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF13C28A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Enviar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BARRA INFERIOR
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 12),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('Home');
                      },
                      icon: const Icon(Icons.home, size: 34),
                    ),

                    IconButton(
                      onPressed: () {
                        print('Pesquisar');
                      },
                      icon: const Icon(Icons.search, size: 34),
                    ),

                    IconButton(
                      onPressed: () {
                        print('Adicionar');
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 34),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

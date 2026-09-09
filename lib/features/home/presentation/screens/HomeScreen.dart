import 'package:crud_mobile_grafica/features/auth/presentation/screens/cadastro_screen.dart';
import 'package:crud_mobile_grafica/features/home/presentation/screens/FiltrosProduto.dart';
import 'package:crud_mobile_grafica/features/home/presentation/screens/addProdutos.dart';
import 'package:crud_mobile_grafica/features/home/presentation/screens/edicao_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página Inicial')),
      body: Center(child: Text("")),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0), //barra das bordas da tela
        padding: const EdgeInsets.symmetric(
          vertical: 0.30,
        ), // Altura interna da barra
        decoration: BoxDecoration(
          // Cria o fundo cinza em gradiente igual ao da imagem
          gradient: LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50.0), //Border circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 3), // Sombra leve abaixo da barra
            ),
          ],
        ),
        child: Row(
          // 🌟 O segredo do alinhamento: distribui os botões com espaços iguais
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botão 1: Home
            IconButton(
              icon: const Icon(Icons.home, size: 45, color: Colors.black),
              onPressed: () {
                // Ação do botão Home
              },
            ),

            // Botão 2: Busca
            IconButton(
              icon: const Icon(Icons.search, size: 45, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Filtrosproduto()),
                );
              },
            ),

            // Botão 3: Adicionar (Mais)
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                size: 45,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const addProdutos()),
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
class ListContents extends StatelessWidget {
  final List<CatalagoItem> secoes = [
    CatalagoItem(
      titulo: 'Widgets de layout',
      icone: Icons.text_fields,
      descricao:
          'Exemplos de widgets de layout basico como text, Image icon...',
      destino: edicaoScreen(),
    ),
    CatalagoItem(
      titulo: 'Widgets de conteudo',
      icone: Icons.text_fields,
      descricao:
          'Exemplos de widgets de conteudo basico como text, Image icon...',
      destino: edicaoScreen(),
    ),
  ];
  ListContents({super.key});
  //fazendo a listagem de itens do catalago
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catalogo de widgets')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.92,
        children: secoes
            //fazendo a listagem de itens do catalago com GestureDetector
            // para navegar para a tela de destino
            .map(
              (item) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.destino),
                ),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          item.icone,
                          size: 48,
                          color: const Color.fromARGB(255, 0, 174, 255),
                        ),
                        //deixando o text centralizado e com maxLines para
                        //não estourar o tamanho do card
                        Text(
                          item.titulo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        //deixando o text centralizado e com maxLines para não
                        // estourar o tamanho do card
                        Text(
                          item.descricao,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CatalagoItem {
  final String titulo;
  final IconData icone;
  final String descricao;
  final Widget destino;

  CatalagoItem({
    required this.titulo,
    required this.icone,
    required this.descricao,
    required this.destino,
  });
}

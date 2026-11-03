import 'package:crud_mobile_grafica/models/produto.dart';

// Dados de demonstração.
const produtosExemplo = <Produto>[
  Produto(
    nome: 'Folha A4',
    preco: 4.99,
    categoria: CategoriaProduto.folhas,
  ),
  Produto(
    nome: 'Embalagem de papel',
    preco: 6.50,
    categoria: CategoriaProduto.embalagens,
  ),
  Produto(
    nome: 'Caderno',
    preco: 25.00,
    categoria: CategoriaProduto.materialEscolar,
  ),
  Produto(
    nome: 'Caneta',
    preco: 3.00,
    categoria: CategoriaProduto.acessorios,
  ),
  Produto(
    nome: 'Mochila',
    preco: 89.90,
    categoria: CategoriaProduto.mochilas,
  ),
  Produto(
    nome: 'Corte simples',
    preco: 1.50,
    categoria: CategoriaProduto.cortes,
  ),
];
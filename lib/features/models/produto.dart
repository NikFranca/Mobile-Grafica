import 'dart:typed_data';

enum CategoriaProduto {
  folhas('Folhas'),
  embalagens('Embalagens'),
  materialEscolar('Material Escolar'),
  acessorios('Acessórios'),
  mochilas('Mochilas'),
  cortes('Cortes');

  const CategoriaProduto(this.titulo);

  final String titulo;
}

class Produto {
  final String nome;
  final double preco;
  final CategoriaProduto categoria;
  final String descricao;
  final String? imagem;
  final Uint8List? imagemBytes;

  const Produto({
    required this.nome,
    required this.preco,
    required this.categoria,
    this.descricao = '',
    this.imagem,
    this.imagemBytes,
  });
}
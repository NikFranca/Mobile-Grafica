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
  final String? imagem;

  const Produto({
    required this.nome,
    required this.preco,
    required this.categoria,
    this.imagem,
  });
}

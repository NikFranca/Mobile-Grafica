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
  final String? id;
  final String nome;
  final double preco;
  final CategoriaProduto? categoria;
  final String? categoriaApi;
  final String descricao;
  final String? imagem;
  final Uint8List? imagemBytes;

  const Produto({
    this.id,
    required this.nome,
    required this.preco,
    required this.categoria,
    this.categoriaApi,
    this.descricao = '',
    this.imagem,
    this.imagemBytes,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    final nome = json['nome'];
    final valor = json['preco'];

    final preco = valor is num
        ? valor.toDouble()
        : double.tryParse(valor?.toString() ?? '');

    if (nome is! String ||
        nome.trim().isEmpty ||
        preco == null ||
        !preco.isFinite ||
        preco < 0) {
      throw const FormatException(
        'Produto com nome ou preço inválido.',
      );
    }

    final categoriaApi = json['categoria']?.toString().trim();

    CategoriaProduto? categoria;

    for (final opcao in CategoriaProduto.values) {
      if (opcao.titulo.toLowerCase() == categoriaApi?.toLowerCase()) {
        categoria = opcao;
        break;
      }
    }

    return Produto(
      id: json['id']?.toString(),
      nome: nome.trim(),
      preco: preco,
      categoria: categoria,
      categoriaApi: categoriaApi,
      descricao: json['descricao']?.toString() ?? '',
      imagem: json['imagem'] is String
          ? json['imagem'] as String
          : null,
    );
  }
}
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
  final bool ativo;

  const Produto({
    this.id,
    required this.nome,
    required this.preco,
    required this.categoria,
    this.categoriaApi,
    this.descricao = '',
    this.imagem,
    this.imagemBytes,
    this.ativo = true,
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
      throw const FormatException('Produto com nome ou preço inválido.');
    }

    final categoriaApi = json['categoria']?.toString().trim();
    CategoriaProduto? categoria;

    for (final opcao in CategoriaProduto.values) {
      if (opcao.titulo.toLowerCase() == categoriaApi?.toLowerCase()) {
        categoria = opcao;
        break;
      }
    }

    final imagemInformada = json.containsKey('imagem')
        ? json['imagem']
        : json['imagemUrl'] ?? json['imagem_url'];

    if (imagemInformada != null && imagemInformada is! String) {
      throw const FormatException('URL de imagem inválida.');
    }

    final ativo = json['ativo'];

    if (ativo != null && ativo is! bool) {
      throw const FormatException('Status do produto inválido.');
    }

    return Produto(
      id: json['id']?.toString(),
      nome: nome.trim(),
      preco: preco,
      categoria: categoria,
      categoriaApi: categoriaApi,
      descricao: json['descricao']?.toString() ?? '',
      imagem: imagemInformada is String ? imagemInformada.trim() : null,
      ativo: ativo as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagem': imagem,
      'categoria': categoria?.titulo ?? categoriaApi,
      'ativo': ativo,
    };
  }
}
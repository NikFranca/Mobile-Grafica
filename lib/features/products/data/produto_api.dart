import 'dart:async';
import 'dart:convert';

import 'package:crud_mobile_grafica/features/auth/data/sessao_app.dart';
import 'package:http/http.dart' as http;
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProdutoApiException implements Exception {
  final String mensagem;

  const ProdutoApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ProdutoApi {
  const ProdutoApi();

  static const String _baseUrl = 'http://localhost:8081';
  static const int limiteImagemBytes = 5 * 1024 * 1024;

  Future<http.Response> _receber(
    http.Client client,
    http.Request request,
  ) async {
    final resposta = await client.send(request);
    return http.Response.fromStream(resposta);
  }

  Future<dynamic> _requisicao(
    String metodo,
    String caminho, {
    Map<String, dynamic>? dados,
  }) async {
    final client = http.Client();

    try {
      final request = http.Request(metodo, Uri.parse('$_baseUrl$caminho'));

      if (const {
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      }.contains(metodo.toUpperCase())) {
        final token = SessaoApp.token;

        if (token == null || token.isEmpty) {
          throw const ProdutoApiException(
            'Faça login novamente para continuar.',
          );
        }

        request.headers['Authorization'] = 'Bearer $token';
      }

      if (dados != null) {
        request.headers['Content-Type'] = 'application/json; charset=utf-8';
        request.body = jsonEncode(dados);
      }

      final resposta = await _receber(
        client,
        request,
      ).timeout(const Duration(seconds: 90));

      final sucessoHttp =
          resposta.statusCode >= 200 && resposta.statusCode < 300;

      dynamic recebido;

      if (resposta.bodyBytes.isNotEmpty) {
        try {
          recebido = jsonDecode(utf8.decode(resposta.bodyBytes));
        } on FormatException {
          if (sucessoHttp) {
            throw const ProdutoApiException(
              'A API retornou uma resposta inválida. '
              'Atualize a lista para conferir a operação.',
            );
          }
        }
      }

      final recusado =
          recebido is Map<String, dynamic> && recebido['sucesso'] == false;

      if (!sucessoHttp || recusado) {
        var mensagem = 'Não foi possível concluir a operação.';

        if (recebido is Map<String, dynamic>) {
          final detalhe =
              recebido['mensagem'] ??
              recebido['erro'] ??
              recebido['message'] ??
              recebido['error'];

          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = detalhe;
          }
        }

        throw ProdutoApiException('$mensagem (HTTP ${resposta.statusCode})');
      }

      return recebido;
    } on TimeoutException {
      throw ProdutoApiException(
        metodo == 'GET'
            ? 'O servidor demorou para responder. Tente novamente.'
            : 'O servidor demorou para confirmar. '
                  'Atualize a lista antes de repetir a operação.',
      );
    } on http.ClientException {
      throw const ProdutoApiException('Não foi possível conectar ao servidor.');
    } finally {
      client.close();
    }
  }

  void _validarDados(String nome, double preco, String categoria) {
    if (nome.trim().isEmpty) {
      throw const ProdutoApiException('Informe o nome do produto.');
    }

    if (!preco.isFinite || preco <= 0) {
      throw const ProdutoApiException('Informe um preço maior que zero.');
    }

    if (categoria.trim().isEmpty) {
      throw const ProdutoApiException('Selecione uma categoria.');
    }
  }

  Produto _produtoDaResposta(dynamic dados) {
    final recebido = dados is Map<String, dynamic> ? dados['produto'] : null;

    if (recebido is! Map<String, dynamic>) {
      throw const ProdutoApiException(
        'A API não retornou o produto gravado. '
        'Atualize a lista para conferir.',
      );
    }

    final produto = Produto.fromJson(recebido);
    final id = produto.id;

    if (id == null || id.trim().isEmpty) {
      throw const ProdutoApiException('A API retornou um produto sem ID.');
    }

    return produto;
  }

  String _idValido(String? id) {
    if (id == null || id.trim().isEmpty) {
      throw const ProdutoApiException('Este produto não possui um ID válido.');
    }

    return Uri.encodeComponent(id.trim());
  }

  Future<List<Produto>> listarProdutos() async {
    final dados = await _requisicao('GET', '/api/produtos');

    if (dados is! List) {
      throw const ProdutoApiException(
        'A API não retornou uma lista de produtos.',
      );
    }

    return dados.map<Produto>((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Produto inválido na resposta.');
      }

      return Produto.fromJson(item);
    }).toList();
  }

  Future<String> enviarImagem({
    required List<int> bytes,
    String nomeArquivo = 'produto',
  }) async {
    if (bytes.isEmpty) {
      throw const ProdutoApiException('A imagem está vazia.');
    }

    if (bytes.length > limiteImagemBytes) {
      throw const ProdutoApiException('Selecione uma imagem de até 5 MB.');
    }

    final dados = await _requisicao(
      'POST',
      '/api/produtos/imagem',
      dados: {'nomeArquivo': nomeArquivo, 'imagemBase64': base64Encode(bytes)},
    );

    final imagem = dados is Map<String, dynamic> ? dados['imagem'] : null;

    if (imagem is! String || imagem.trim().isEmpty) {
      throw const ProdutoApiException(
        'O servidor não retornou o link da imagem.',
      );
    }

    return imagem;
  }

  Future<Produto> cadastrarProduto({
    required String nome,
    required String descricao,
    required double preco,
    required String categoria,
    required bool ativo,
    String? imagem,
  }) async {
    _validarDados(nome, preco, categoria);

    final dados = await _requisicao(
      'POST',
      '/api/produtos',
      dados: {
        'nome': nome.trim(),
        'descricao': descricao.trim(),
        'preco': preco,
        'imagem': imagem,
        'categoria': categoria.trim(),
        'ativo': ativo,
      },
    );

    return _produtoDaResposta(dados);
  }

  Future<Produto> atualizarProduto(Produto produto) async {
    final id = _idValido(produto.id);

    _validarDados(
      produto.nome,
      produto.preco,
      produto.categoria?.titulo ?? produto.categoriaApi ?? '',
    );

    final dados = await _requisicao(
      'PUT',
      '/api/produtos/$id',
      dados: produto.toJson(),
    );

    return _produtoDaResposta(dados);
  }

  Future<void> excluirProduto(String? produtoId) async {
    final id = _idValido(produtoId);

    await _requisicao('DELETE', '/api/produtos/$id');
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProdutoApi {
  Future<void> excluirProduto(String id) async {
    final produtoId = id.trim();

    if (produtoId.isEmpty) {
      throw Exception('O produto não possui um ID válido.');
    }

    final client = http.Client();

    try {
      final resposta = await client
          .delete(
            Uri.parse(
              '$_baseUrl/api/produtos/'
              '${Uri.encodeComponent(produtoId)}',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 90));

      dynamic dados;

      try {
        dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      } on FormatException {
        throw Exception(
          'O servidor retornou uma resposta inválida. '
          'HTTP ${resposta.statusCode}.',
        );
      }

      if (resposta.statusCode != 200 ||
          dados is! Map<String, dynamic> ||
          dados['sucesso'] != true) {
        var mensagem = 'Não foi possível excluir o produto.';

        if (dados is Map<String, dynamic>) {
          final detalhe = dados['mensagem'] ?? dados['erro'];

          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = detalhe;
          }
        }

        throw Exception('$mensagem (HTTP ${resposta.statusCode})');
      }

      if (dados['id'] != produtoId) {
        throw const FormatException(
          'O servidor não confirmou o ID do produto excluído.',
        );
      }
    } on TimeoutException {
      throw Exception(
        'A confirmação da exclusão demorou. '
        'Atualize a lista antes de tentar novamente.',
      );
    } finally {
      client.close();
    }
  }

  const ProdutoApi();

  static const String _baseUrl = 'http://localhost:8081';

  Future<List<Produto>> listarProdutos() async {
    final client = http.Client();

    try {
      final resposta = await client
          .get(
            Uri.parse('$_baseUrl/api/produtos'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 90));

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro ao buscar produtos: HTTP ${resposta.statusCode}.',
        );
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! List) {
        throw const FormatException(
          'A API não retornou uma lista de produtos.',
        );
      }

      return dados.map<Produto>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Produto inválido.');
        }

        return Produto.fromJson(item);
      }).toList();
    } on TimeoutException {
      throw Exception('O servidor demorou para responder. Tente novamente.');
    } finally {
      client.close();
    }
  }

  Future<void> cadastrarProduto({
    required String nome,
    required String descricao,
    required double preco,
    required String categoria,
    required bool ativo,
  }) async {
    final client = http.Client();

    try {
      final resposta = await client
          .post(
            Uri.parse('$_baseUrl/api/produtos'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nome': nome,
              'descricao': descricao,
              'preco': preco,
              'imagem': null,
              'categoria': categoria,
              'ativo': ativo,
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        return;
      }

      var mensagem = 'Erro ao cadastrar: HTTP ${resposta.statusCode}.';

      try {
        final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

        if (dados is Map<String, dynamic>) {
          final detalhe =
              dados['mensagem'] ?? dados['message'] ?? dados['error'];

          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = '$mensagem $detalhe';
          }
        }
      } on FormatException {
        // Mantém a mensagem com o status HTTP.
      }

      throw Exception(mensagem);
    } on TimeoutException {
      throw Exception(
        'O cadastro demorou para confirmar. '
        'Confira a lista antes de enviar novamente.',
      );
    } finally {
      client.close();
    }
  }

  Future<Produto> atualizarProduto(Produto produto) async {
    final id = produto.id?.trim();

    if (id == null || id.isEmpty) {
      throw Exception('Este produto não possui um ID válido para edição.');
    }

    final client = http.Client();

    try {
      final resposta = await client
          .put(
            Uri.parse('$_baseUrl/api/produtos/${Uri.encodeComponent(id)}'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nome': produto.nome,
              'descricao': produto.descricao,
              'preco': produto.preco,
              'categoria': produto.categoria?.titulo ?? produto.categoriaApi,
              'ativo': produto.ativo,
            }),
          )
          .timeout(const Duration(seconds: 90));

      dynamic dados;

      try {
        dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      } on FormatException {
        throw Exception(
          'O servidor retornou uma resposta inválida. '
          'HTTP ${resposta.statusCode}.',
        );
      }

      if (resposta.statusCode != 200 ||
          dados is! Map<String, dynamic> ||
          dados['sucesso'] != true) {
        var mensagem = 'Não foi possível atualizar o produto.';

        if (dados is Map<String, dynamic>) {
          final detalhe = dados['mensagem'] ?? dados['erro'];

          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = detalhe;
          }
        }

        throw Exception('$mensagem (HTTP ${resposta.statusCode})');
      }

      final registro = dados['produto'];

      if (registro is! Map<String, dynamic>) {
        throw const FormatException('O servidor não retornou o produto salvo.');
      }

      final salvo = Produto.fromJson(registro);

      if (salvo.id != id) {
        throw const FormatException(
          'O servidor retornou um produto diferente do solicitado.',
        );
      }

      return salvo;
    } on TimeoutException {
      throw Exception(
        'A confirmação da atualização demorou. '
        'Atualize a lista antes de tentar novamente.',
      );
    } finally {
      client.close();
    }
  }
}

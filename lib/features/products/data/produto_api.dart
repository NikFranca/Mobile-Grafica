import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProdutoApi {
  const ProdutoApi();

  static const String _baseUrl = 'http://localhost:8081';

  Future<List<Produto>> listarProdutos() async {
    final client = http.Client();

    try {
      // Faz a consulta ao servidor.
      final resposta = await client
          .get(
            Uri.parse('$_baseUrl/api/produtos'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 90));

      // HTTP 200 significa que a consulta foi bem-sucedida.
      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro ao buscar produtos: HTTP ${resposta.statusCode}.',
        );
      }

      // Converte o texto recebido em dados do Dart.
      final dados = jsonDecode(resposta.body);

      if (dados is! List) {
        throw const FormatException(
          'A API não retornou uma lista de produtos.',
        );
      }

      // Transforma cada registro em um objeto Produto.
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
}

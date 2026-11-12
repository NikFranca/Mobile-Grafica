import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProdutoApi {
  const ProdutoApi();

  // URL base da API no Render
  static const String _baseUrl = 'https://crud-grafica-mobile-back.onrender.com/produtos';

  Future<List<Produto>> listarProdutos() async {
    final client = http.Client();

    try {
      final url = Uri.parse(_baseUrl);

      final resposta = await client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 90));

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro ao buscar produtos: HTTP ${resposta.statusCode}.',
        );
      }

      final dados = jsonDecode(
        utf8.decode(resposta.bodyBytes),
      );

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
      throw Exception(
        'O servidor demorou para responder. Tente novamente.',
      );
    } finally {
      client.close();
    }
  }

  /// Cadastra um novo produto e retorna uma mensagem de sucesso.
  Future<String> cadastrarProduto(Produto produto) async {
    final client = http.Client();

    try {
      final url = Uri.parse(_baseUrl);

      // Converte o objeto Produto para JSON (certifique-se de que seu modelo tenha o método toJson)
      final bodyData = jsonEncode(produto.toJson());

      final resposta = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: bodyData,
      ).timeout(const Duration(seconds: 90));

      // 200 OK ou 201 Created indicam sucesso na maioria das APIs REST
      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        return 'Produto cadastrado com sucesso!';
      } else {
        // Tenta extrair a mensagem de erro da API se houver
        String mensagemErro = 'Erro ao cadastrar produto: HTTP ${resposta.statusCode}.';
        try {
          final erroJson = jsonDecode(resposta.body);
          if (erroJson is Map && erroJson.containsKey('message')) {
            mensagemErro = 'Erro: ${erroJson['message']}';
          }
        } catch (_) {}
        
        throw Exception(mensagemErro);
      }
    } on TimeoutException {
      throw Exception('O servidor demorou para responder ao cadastrar. Tente novamente.');
    } finally {
      client.close();
    }
  }
}
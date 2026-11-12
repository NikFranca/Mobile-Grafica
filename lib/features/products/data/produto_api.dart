import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud_mobile_grafica/features/products/models/produto.dart';
class ProdutoApi {
  const ProdutoApi();

  Future<List<Produto>> listarProdutos() async {
    final client = http.Client();

    try {
      // Endereço que retorna os produtos.
      final url = Uri.parse(
        'https://crud-grafica-mobile-back.onrender.com/produtos',
      );

      // Faz a consulta ao servidor.
      final resposta = await client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 90));

      // HTTP 200 significa que a consulta foi bem-sucedida.
      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro ao buscar produtos: HTTP ${resposta.statusCode}.',
        );
      }

      // Converte o texto recebido em dados do Dart.
      final dados = jsonDecode(
        utf8.decode(resposta.bodyBytes),
      );

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
      throw Exception(
        'O servidor demorou para responder. Tente novamente.',
      );
    } finally {
      client.close();
    }
  }
}
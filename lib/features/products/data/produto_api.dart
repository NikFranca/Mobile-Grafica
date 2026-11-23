import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:crud_mobile_grafica/features/auth/data/sessao_app.dart';
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

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
    bool requerLogin = false,
  }) async {
    final client = http.Client();

    try {
      final request = http.Request(
        metodo,
        Uri.parse('$_baseUrl$caminho'),
      );

      request.headers['Accept'] = 'application/json';

      if (requerLogin) {
        final token = SessaoApp.token;

        if (token == null || token.isEmpty) {
          throw Exception(
            'Faça login novamente para enviar a imagem.',
          );
        }

        request.headers['Authorization'] = 'Bearer $token';
      }

      if (dados != null) {
        request.headers['Content-Type'] =
            'application/json; charset=utf-8';

        request.body = jsonEncode(dados);
      }

      final resposta = await _receber(client, request)
          .timeout(const Duration(seconds: 90));

      dynamic recebido;

      try {
        recebido = jsonDecode(
          utf8.decode(resposta.bodyBytes),
        );
      } on FormatException {
        throw Exception(
          'Resposta inválida em $caminho. '
          'HTTP ${resposta.statusCode}.',
        );
      }

      final sucessoHttp =
          resposta.statusCode >= 200 && resposta.statusCode < 300;

      final recusado = recebido is Map<String, dynamic> &&
          recebido['sucesso'] == false;

      if (!sucessoHttp || recusado) {
        var mensagem = 'Não foi possível concluir a operação.';

        if (recebido is Map<String, dynamic>) {
          final detalhe = recebido['mensagem'] ??
              recebido['erro'] ??
              recebido['message'] ??
              recebido['error'];

          if (detalhe is String && detalhe.trim().isNotEmpty) {
            mensagem = detalhe;
          }
        }

        throw Exception(
          '$mensagem (HTTP ${resposta.statusCode})',
        );
      }

      return recebido;
    } on TimeoutException {
      throw Exception(
        'O servidor demorou para confirmar a operação. '
        'Confira a lista antes de tentar novamente.',
      );
    } on http.ClientException {
      throw Exception(
        'Não foi possível conectar à API.',
      );
    } finally {
      client.close();
    }
  }

  String _validarId(String? valor) {
    final id = valor?.trim();

    if (id == null || id.isEmpty) {
      throw Exception('O produto não possui um ID válido.');
    }

    return id;
  }

  Future<List<Produto>> listarProdutos() async {
    final dados = await _requisicao(
      'GET',
      '/api/produtos',
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
  }

  Future<String> enviarImagem(Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw Exception('A imagem está vazia.');
    }

    if (bytes.length > limiteImagemBytes) {
      throw Exception('Escolha uma imagem de até 5 MB.');
    }

    final dados = await _requisicao(
      'POST',
      '/api/produtos/imagem',
      requerLogin: true,
      dados: {
        'imagemBase64': base64Encode(bytes),
      },
    );

    if (dados is! Map<String, dynamic> ||
        dados['sucesso'] != true ||
        dados['imagem'] is! String) {
      throw Exception(
        'O servidor não confirmou o envio da imagem.',
      );
    }

    final url = (dados['imagem'] as String).trim();
    final uri = Uri.tryParse(url);

    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw Exception(
        'O servidor retornou uma URL de imagem inválida.',
      );
    }

    return url;
  }

  Future<void> cadastrarProduto({
    required String nome,
    required String descricao,
    required double preco,
    required String categoria,
    required bool ativo,
    String? imagem,
  }) async {
    final dados = await _requisicao(
      'POST',
      '/api/produtos',
      dados: {
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'imagem': imagem,
        'categoria': categoria,
        'ativo': ativo,
      },
    );

    if (dados is! Map<String, dynamic> ||
        dados['sucesso'] != true) {
      throw Exception(
        'A API não confirmou o cadastro do produto.',
      );
    }
  }

  Future<Produto> atualizarProduto(
    Produto produto, {
    String? novaImagemUrl,
  }) async {
    final id = _validarId(produto.id);

    final dados = await _requisicao(
      'PUT',
      '/api/produtos/${Uri.encodeComponent(id)}',
      dados: {
        'nome': produto.nome,
        'descricao': produto.descricao,
        'preco': produto.preco,
        'categoria':
            produto.categoria?.titulo ?? produto.categoriaApi,
        'ativo': produto.ativo,
        if (novaImagemUrl != null) 'imagem': novaImagemUrl,
        if (novaImagemUrl != null) 'imagemUrl': novaImagemUrl,
      },
    );

    if (dados is! Map<String, dynamic> ||
        dados['sucesso'] != true) {
      throw Exception(
        'A API não confirmou a atualização.',
      );
    }

    final registro = dados['produto'];

    if (registro is! Map<String, dynamic>) {
      throw Exception(
        'O servidor não retornou o produto salvo.',
      );
    }

    final salvo = Produto.fromJson(registro);

    if (salvo.id != id) {
      throw Exception(
        'O servidor retornou um produto diferente do solicitado.',
      );
    }

    return salvo;
  }

  Future<void> excluirProduto(String id) async {
    final produtoId = _validarId(id);

    final dados = await _requisicao(
      'DELETE',
      '/api/produtos/${Uri.encodeComponent(produtoId)}',
    );

    if (dados is! Map<String, dynamic> ||
        dados['sucesso'] != true ||
        dados['id'] != produtoId) {
      throw Exception(
        'O servidor não confirmou a exclusão do produto.',
      );
    }
  }
}
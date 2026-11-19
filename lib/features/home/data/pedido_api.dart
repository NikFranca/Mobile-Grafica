import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ResumoPedidos {
  final int pedidos;
  final int pagos;
  final int pendentes;
  final int cancelados;

  const ResumoPedidos({
    required this.pedidos,
    required this.pagos,
    required this.pendentes,
    required this.cancelados,
  });

  factory ResumoPedidos.fromJson(Map<String, dynamic> json) {
    int lerContagem(String chave) {
      final valor = json[chave];

      if (valor is! int || valor < 0) {
        throw FormatException('Contador inválido: $chave.');
      }

      return valor;
    }

    return ResumoPedidos(
      pedidos: lerContagem('pedidos'),
      pagos: lerContagem('pagamentos_confirmados'),
      pendentes: lerContagem('pagamentos_pendentes'),
      cancelados: lerContagem('pagamentos_cancelados'),
    );
  }
}

class PedidoApi {
  const PedidoApi();

  static const String _baseUrl = 'http://localhost:8081';

  Future<ResumoPedidos> buscarResumo() async {
    final client = http.Client();

    try {
      final resposta = await client
          .get(
            Uri.parse('$_baseUrl/api/pedidos/resumo'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 90));

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro ao carregar resumo: HTTP ${resposta.statusCode}.',
        );
      }

      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

      if (dados is! Map<String, dynamic>) {
        throw const FormatException('Resumo inválido recebido da API.');
      }

      return ResumoPedidos.fromJson(dados);
    } on TimeoutException {
      throw Exception('O servidor demorou para responder.');
    } finally {
      client.close();
    }
  }
}

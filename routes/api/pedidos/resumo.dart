import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      headers: {'Allow': 'GET'},
      body: {
        'mensagem': 'Método não permitido.',
      },
    );
  }

  try {
    final supabase = context.read<SupabaseClient>();

    final totais = await Future.wait<int>([
      // Total de pedidos.
      supabase.from('pedido').count(CountOption.exact),

      // Pagamentos confirmados.
      supabase
          .from('pagamento')
          .count(CountOption.exact)
          .eq('status', 'CONFIRMADO'),

      // Pagamentos pendentes.
      supabase
          .from('pagamento')
          .count(CountOption.exact)
          .eq('status', 'PENDENTE'),

      // Pagamentos cancelados.
      supabase
          .from('pagamento')
          .count(CountOption.exact)
          .eq('status', 'CANCELADO'),

      // Pedidos pendentes.
      supabase.from('pedido').count(CountOption.exact).eq('status', 'PENDENTE'),

      // Pedidos cancelados.
      supabase
          .from('pedido')
          .count(CountOption.exact)
          .eq('status', 'CANCELADO'),
    ]);

    return Response.json(
      body: {
        'pedidos': totais[0],
        'pagamentos_confirmados': totais[1],
        'pagamentos_pendentes': totais[2],
        'pagamentos_cancelados': totais[3],
        'pedidos_pendentes': totais[4],
        'pedidos_cancelados': totais[5],
      },
    );
  } catch (erro, stackTrace) {
    stderr.writeln('Erro ao consultar resumo: $erro');
    stderr.writeln(stackTrace);

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'mensagem': 'Não foi possível carregar o resumo.',
      },
    );
  }
}

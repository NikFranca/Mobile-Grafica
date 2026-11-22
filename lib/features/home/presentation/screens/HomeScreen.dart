import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:crud_mobile_grafica/features/home/data/pedido_api.dart';
import 'package:crud_mobile_grafica/features/widgets/app_bottom_bar.dart';
import 'package:fl_chart/fl_chart.dart'; //grafico

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PedidoApi _pedidoApi = const PedidoApi();

  ResumoPedidos? _resumo;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarResumo();
  }

  Future<void> _carregarResumo() async {
    if (_carregando) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final recebido = await _pedidoApi.buscarResumo();

      if (!mounted) return;

      setState(() {
        _resumo = recebido;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;

      debugPrint('Erro ao carregar indicadores: $erro');

      setState(() {
        _carregando = false;
        _erro =
            'Não foi possível carregar os números. '
            'Tente novamente.';
      });
    }
  }

  Widget _buildGraficoResumo(int pagos, int pendentes, int cancelados) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4, // Espaço entre as fatias
          centerSpaceRadius: 50, // Tamanho do buraco no meio (anel)
          sections: [
            PieChartSectionData(
              color: Colors.green, // Pagos
              value: pagos.toDouble(),
              title: '$pagos',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.orange, // Pendentes
              value: pendentes.toDouble(),
              title: '$pendentes',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red, // Cancelados
              value: cancelados.toDouble(),
              title: '$cancelados',
              radius: 40,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget indicador({
    required String titulo,
    required int valor,
    required IconData icone,
    required Color corValor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDF9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icone, size: 24, color: corValor),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$valor',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: corValor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return Center(child: _buildListaProdutosSkeleton());
    }

    if (_erro != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _carregarResumo,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final resumo = _resumo;

    if (resumo == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: indicador(
                  titulo: 'Pedidos',
                  valor: resumo.pedidos,
                  icone: Icons.receipt_long_rounded,
                  corValor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: indicador(
                  titulo: 'Pagos',
                  valor: resumo.pagos,
                  icone: Icons.payments_rounded,
                  corValor: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: indicador(
                  titulo: 'Pendentes',
                  valor: resumo.pendentes,
                  icone: Icons.pending_actions_rounded,
                  corValor: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: indicador(
                  titulo: 'Cancelados',
                  valor: resumo.cancelados,
                  icone: Icons.cancel_outlined,
                  corValor: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Distribuição de Pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _buildGraficoResumo(
            resumo.pagos,
            resumo.pendentes,
            resumo.cancelados,
          ),
        ],
      ),
    );
  }

  Widget _buildListaProdutosSkeleton() {
    return ListView.builder(
      itemCount: 6, // Quantidade de esqueletos simulados na tela
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // Quadrado simulando a imagem do produto
              leading: Container(width: 50, height: 50, color: Colors.white),
              // Linha simulando o nome do produto
              title: Container(height: 16, color: Colors.white),
              // Linha mais curta simulando o preço ou descrição
              subtitle: Container(
                height: 12,
                margin: const EdgeInsets.only(top: 8, right: 100),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081129),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081129),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        leadingWidth: 64,
        leading: Center(
          child: const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar números',
            onPressed: _carregando ? null : _carregarResumo,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(top: false, child: _conteudo()),
      bottomNavigationBar: const AppBottomBar(selectedIndex: 0),
    );
  }
}


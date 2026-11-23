import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:crud_mobile_grafica/features/auth/data/sessao_app.dart';

class BotaoPerfil extends StatelessWidget {
  const BotaoPerfil({super.key});

  void _abrirPerfil(BuildContext context) {
    if (!SessaoApp.possuiUsuario) {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      elevation: 0,
      builder: (context) => const _PainelPerfil(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Meu perfil',
      onPressed: () => _abrirPerfil(context),
      icon: const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE9DDFE),
        child: Icon(
          Icons.person_outline_rounded,
          color: Color(0xFF534078),
        ),
      ),
    );
  }
}

class _PainelPerfil extends StatelessWidget {
  const _PainelPerfil();

  String _formatarCpf(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'\D'), '');

    if (numeros.length != 11) {
      return 'Não informado';
    }

    return '${numeros.substring(0, 3)}.'
        '${numeros.substring(3, 6)}.'
        '${numeros.substring(6, 9)}-'
        '${numeros.substring(9, 11)}';
  }

  Widget _campo({
    required IconData icone,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sair(BuildContext context) {
    SessaoApp.limpar();

    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: alturaMaxima,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF30405F)
                        .withValues(alpha: 0.64),
                    const Color(0xFF0B142A)
                        .withValues(alpha: 0.80),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFC5B8FF)
                                    .withValues(alpha: 0.35),
                                const Color(0xFF9ACBFF)
                                    .withValues(alpha: 0.14),
                              ],
                            ),
                            border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFFE6DFFF),
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Minha conta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Informações do cadastro',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.62),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.white70,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.07),
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _campo(
                      icone: Icons.person_outline_rounded,
                      titulo: 'Nome',
                      valor: SessaoApp.nome.isEmpty
                          ? 'Não informado'
                          : SessaoApp.nome,
                      cor: const Color(0xFFD0C4FF),
                    ),
                    const SizedBox(height: 10),
                    _campo(
                      icone: Icons.badge_outlined,
                      titulo: 'CPF',
                      valor: _formatarCpf(SessaoApp.cpf),
                      cor: const Color(0xFFA8EACB),
                    ),
                    const SizedBox(height: 10),
                    _campo(
                      icone: Icons.mail_outline_rounded,
                      titulo: 'E-mail',
                      valor: SessaoApp.email.isEmpty
                          ? 'Não informado'
                          : SessaoApp.email,
                      cor: const Color(0xFFAFD5FF),
                    ),
                    const SizedBox(height: 22),
                    OutlinedButton.icon(
                      onPressed: () => _sair(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFB8C1),
                        backgroundColor:
                            const Color(0xFFFF6178)
                                .withValues(alpha: 0.10),
                        side: BorderSide(
                          color: const Color(0xFFFF8A9B)
                              .withValues(alpha: 0.30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Sair da conta',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
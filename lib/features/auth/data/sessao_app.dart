class SessaoApp {
  SessaoApp._();

  static String? token;

  static String nome = '';
  static String cpf = '';
  static String email = '';

  static bool get possuiUsuario => email.isNotEmpty;

  static void carregarUsuario(Map<String, dynamic> usuario) {
    nome = usuario['nome']?.toString().trim() ?? '';

    cpf = (usuario['cpf']?.toString() ?? '')
        .replaceAll(RegExp(r'\D'), '');

    email = usuario['email']?.toString().trim() ?? '';
  }

  static void limpar() {
    token = null;
    nome = '';
    cpf = '';
    email = '';
  }
}
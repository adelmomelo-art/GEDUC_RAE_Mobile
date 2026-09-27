class ConviteUsuarioEntrada {
  const ConviteUsuarioEntrada({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cargo,
    required this.setor,
    required this.perfilAcesso,
  });

  final String nome;
  final String email;
  final String telefone;
  final String cargo;
  final String setor;
  final String perfilAcesso;
}

class ConviteUsuarioCsvParser {
  const ConviteUsuarioCsvParser._();

  static const cabecalho = 'nome;email;telefone;cargo;setor;perfilAcesso';
  static const perfisPermitidos = {
    'gestor',
    'gerente',
    'coordenador',
    'agente',
  };

  static List<ConviteUsuarioEntrada> parse(String conteudo) {
    final linhas = conteudo
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((linha) => linha.trim().isNotEmpty)
        .toList(growable: false);
    if (linhas.length < 2) {
      throw const FormatException('Informe o cabeçalho e ao menos um usuário.');
    }

    final separador = linhas.first.contains(';') ? ';' : ',';
    final cabecalhos = _campos(
      linhas.first,
      separador,
    ).map((item) => item.trim().toLowerCase()).toList(growable: false);
    const esperados = [
      'nome',
      'email',
      'telefone',
      'cargo',
      'setor',
      'perfilacesso',
    ];
    if (cabecalhos.length != esperados.length ||
        !_iguais(cabecalhos, esperados)) {
      throw const FormatException('Cabeçalho inválido. Use: $cabecalho');
    }

    final resultado = <ConviteUsuarioEntrada>[];
    final emails = <String>{};
    for (var indice = 1; indice < linhas.length; indice++) {
      final campos = _campos(linhas[indice], separador);
      if (campos.length != esperados.length) {
        throw FormatException('Linha ${indice + 1}: esperado 6 campos.');
      }
      final nome = campos[0].trim();
      final email = campos[1].trim().toLowerCase();
      final perfil = campos[5].trim().toLowerCase();
      if (nome.isEmpty || !_emailValido(email)) {
        throw FormatException('Linha ${indice + 1}: nome ou e-mail inválido.');
      }
      if (!perfisPermitidos.contains(perfil)) {
        throw FormatException('Linha ${indice + 1}: perfil não permitido.');
      }
      if (!emails.add(email)) {
        throw FormatException('Linha ${indice + 1}: e-mail duplicado.');
      }
      resultado.add(
        ConviteUsuarioEntrada(
          nome: nome,
          email: email,
          telefone: campos[2].trim(),
          cargo: campos[3].trim(),
          setor: campos[4].trim(),
          perfilAcesso: perfil,
        ),
      );
    }
    return List.unmodifiable(resultado);
  }

  static List<String> _campos(String linha, String separador) {
    final campos = <String>[];
    final atual = StringBuffer();
    var entreAspas = false;
    for (var i = 0; i < linha.length; i++) {
      final caractere = linha[i];
      if (caractere == '"') {
        if (entreAspas && i + 1 < linha.length && linha[i + 1] == '"') {
          atual.write('"');
          i++;
        } else {
          entreAspas = !entreAspas;
        }
      } else if (caractere == separador && !entreAspas) {
        campos.add(atual.toString());
        atual.clear();
      } else {
        atual.write(caractere);
      }
    }
    if (entreAspas) throw const FormatException('Aspas não fechadas no CSV.');
    campos.add(atual.toString());
    return campos;
  }

  static bool _iguais(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _emailValido(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

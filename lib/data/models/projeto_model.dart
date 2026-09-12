class ProjetoModel {
  const ProjetoModel({
    required this.id,
    required this.nome,
    this.codigo = '',
    this.categoria = '',
    this.descricao = '',
    this.objetivo = '',
    this.publicoAlvo = '',
    this.palavrasChave = const <String>[],
    this.aliases = const <String>[],
    this.regionalIds = const <String>[],
    this.equipeIds = const <String>[],
    this.ordem = 0,
    this.ativo = true,
  });

  final String id;
  final String nome;
  final String codigo;

  /// Classificacao institucional da iniciativa.
  ///
  /// Exemplos:
  /// - Acao Educativa
  /// - Comando Educativo
  /// - Curso
  /// - Palestra
  /// - Roda de Conversa
  /// - Treinamento Institucional
  /// - Workshop
  final String categoria;

  /// Texto institucional objetivo sobre o que e a iniciativa.
  final String descricao;

  /// Finalidade educativa ou institucional da iniciativa.
  final String objetivo;

  /// Publico prioritario ou destinatario da iniciativa.
  final String publicoAlvo;

  /// Termos controlados que apoiam pesquisa, filtros e Faixita.
  final List<String> palavrasChave;

  /// Variacoes de nome reconhecidas para pesquisa e compatibilidade.
  final List<String> aliases;

  /// Regionais onde a iniciativa pode ser aplicada.
  ///
  /// Lista vazia permanece semanticamente neutra nesta etapa. A politica
  /// definitiva de abrangencia territorial sera tratada no contrato 2C/2D.
  final List<String> regionalIds;

  /// Campo legado da ACL estatica.
  ///
  /// Mantido temporariamente para leitura e compatibilidade do schema antigo.
  /// A nova equipe operacional do RAE NAO deve ser inferida deste campo.
  final List<String> equipeIds;

  /// Ordem institucional opcional para exibicao.
  final int ordem;

  final bool ativo;

  /// Validade estrutural preservada para consumidores legados.
  bool get valido => id.trim().isNotEmpty && nome.trim().isNotEmpty;

  /// Contrato mínimo exigido para o novo catálogo institucional.
  bool get validoInstitucional =>
      valido && codigo.trim().isNotEmpty && categoria.trim().isNotEmpty;

  bool get possuiConhecimentoInstitucional =>
      descricao.trim().isNotEmpty ||
      objetivo.trim().isNotEmpty ||
      publicoAlvo.trim().isNotEmpty;

  String get contextoFaixita {
    final partes = <String>[
      if (descricao.trim().isNotEmpty) descricao.trim(),
      if (objetivo.trim().isNotEmpty) 'Objetivo: ${objetivo.trim()}',
      if (publicoAlvo.trim().isNotEmpty) 'Publico-alvo: ${publicoAlvo.trim()}',
    ];

    return partes.join(' ');
  }

  factory ProjetoModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ProjetoModel(
      id: id.trim(),
      nome: map['nome']?.toString().trim() ?? '',
      codigo: map['codigo']?.toString().trim() ?? '',
      categoria: map['categoria']?.toString().trim() ?? '',
      descricao: map['descricao']?.toString().trim() ?? '',
      objetivo: map['objetivo']?.toString().trim() ?? '',
      publicoAlvo: map['publicoAlvo']?.toString().trim() ?? '',
      palavrasChave: _lista(map['palavrasChave']),
      aliases: _lista(map['aliases']),
      regionalIds: _lista(map['regionalIds']),
      equipeIds: _lista(map['equipeIds']),
      ordem: _inteiro(map['ordem']),
      ativo: map['ativo'] != false,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'nome': nome.trim(),
        'codigo': codigo.trim(),
        'categoria': categoria.trim(),
        'descricao': descricao.trim(),
        'objetivo': objetivo.trim(),
        'publicoAlvo': publicoAlvo.trim(),
        'palavrasChave': _normalizarLista(palavrasChave),
        'aliases': _normalizarLista(aliases),
        'regionalIds': _normalizarLista(regionalIds),
        'equipeIds': _normalizarLista(equipeIds),
        'ordem': ordem,
        'ativo': ativo,
      };

  static List<String> _lista(Object? valor) {
    if (valor is! Iterable) {
      return const <String>[];
    }

    return _normalizarLista(
      valor.map(
        (item) => item?.toString() ?? '',
      ),
    );
  }

  static List<String> _normalizarLista(
    Iterable<String> valores,
  ) {
    final resultado = valores
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);

    resultado.sort(
      (a, b) => a.toLowerCase().compareTo(
            b.toLowerCase(),
          ),
    );

    return resultado;
  }

  static int _inteiro(Object? valor) {
    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    return int.tryParse(
          valor?.toString() ?? '',
        ) ??
        0;
  }
}

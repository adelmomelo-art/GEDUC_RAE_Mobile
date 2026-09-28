class TipoAcaoModel {
  final String id;
  final String nomeAcao;
  final String tipoAcao;
  final int publicoEstimadoPadrao;
  final int publicoMinimoPadrao;
  final List<String> materiaisSugeridos;
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const TipoAcaoModel({
    required this.id,
    required this.nomeAcao,
    required this.tipoAcao,
    required this.publicoEstimadoPadrao,
    required this.publicoMinimoPadrao,
    required this.materiaisSugeridos,
    required this.ativo,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory TipoAcaoModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return TipoAcaoModel(
      id: _asString(documentId).isNotEmpty
          ? _asString(documentId)
          : _asString(map['id']),
      nomeAcao: _asString(map['nomeAcao']),
      tipoAcao: _asString(map['tipoAcao']),
      publicoEstimadoPadrao: _asInt(map['publicoEstimadoPadrao']),
      publicoMinimoPadrao: _asInt(map['publicoMinimoPadrao']),
      materiaisSugeridos: _asStringList(map['materiaisSugeridos']),
      ativo: _asBool(map['ativo'], defaultValue: true),
      criadoEm: _asDateTime(map['criadoEm']),
      atualizadoEm: _asDateTime(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap({bool incluirMetadados = true}) {
    return <String, dynamic>{
      'id': id,
      'nomeAcao': nomeAcao,
      'tipoAcao': tipoAcao,
      'publicoEstimadoPadrao': publicoEstimadoPadrao,
      'publicoMinimoPadrao': publicoMinimoPadrao,
      'materiaisSugeridos': List<String>.unmodifiable(materiaisSugeridos),
      'ativo': ativo,
      if (incluirMetadados && criadoEm != null) 'criadoEm': criadoEm,
      if (incluirMetadados && atualizadoEm != null)
        'atualizadoEm': atualizadoEm,
    };
  }

  TipoAcaoModel normalizado() {
    return copyWith(
      id: id.trim(),
      nomeAcao: normalizarEspacos(nomeAcao),
      tipoAcao: normalizarEspacos(tipoAcao),
      publicoEstimadoPadrao: publicoEstimadoPadrao,
      publicoMinimoPadrao: publicoMinimoPadrao,
      materiaisSugeridos: normalizarMateriais(materiaisSugeridos),
    );
  }

  List<String> validar() {
    final valor = normalizado();
    final erros = <String>[];

    if (valor.nomeAcao.isEmpty) {
      erros.add('Informe o nome da ação.');
    }
    if (valor.tipoAcao.isEmpty) {
      erros.add('Informe o tipo da ação.');
    }
    if (valor.publicoEstimadoPadrao < 0) {
      erros.add('O público estimado não pode ser negativo.');
    }
    if (valor.publicoMinimoPadrao < 0) {
      erros.add('O público mínimo não pode ser negativo.');
    }
    if (valor.publicoEstimadoPadrao > 0 &&
        valor.publicoMinimoPadrao > valor.publicoEstimadoPadrao) {
      erros.add('O público mínimo não pode superar o público estimado.');
    }

    return List<String>.unmodifiable(erros);
  }

  String get chaveNormalizada =>
      '${normalizarParaComparacao(nomeAcao)}|'
      '${normalizarParaComparacao(tipoAcao)}';

  TipoAcaoModel copyWith({
    String? id,
    String? nomeAcao,
    String? tipoAcao,
    int? publicoEstimadoPadrao,
    int? publicoMinimoPadrao,
    List<String>? materiaisSugeridos,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    bool limparCriadoEm = false,
    bool limparAtualizadoEm = false,
  }) {
    return TipoAcaoModel(
      id: id ?? this.id,
      nomeAcao: nomeAcao ?? this.nomeAcao,
      tipoAcao: tipoAcao ?? this.tipoAcao,
      publicoEstimadoPadrao:
          publicoEstimadoPadrao ?? this.publicoEstimadoPadrao,
      publicoMinimoPadrao: publicoMinimoPadrao ?? this.publicoMinimoPadrao,
      materiaisSugeridos: List<String>.unmodifiable(
        materiaisSugeridos ?? this.materiaisSugeridos,
      ),
      ativo: ativo ?? this.ativo,
      criadoEm: limparCriadoEm ? null : (criadoEm ?? this.criadoEm),
      atualizadoEm: limparAtualizadoEm
          ? null
          : (atualizadoEm ?? this.atualizadoEm),
    );
  }

  static String normalizarEspacos(String valor) {
    return valor.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizarParaComparacao(String valor) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const semAcento = 'aaaaaeeeeiiiiooooouuuuc';

    var resultado = normalizarEspacos(valor).toLowerCase();
    for (var indice = 0; indice < comAcento.length; indice++) {
      resultado = resultado.replaceAll(comAcento[indice], semAcento[indice]);
    }
    return resultado;
  }

  static List<String> normalizarMateriais(Iterable<String> materiais) {
    final unicos = <String, String>{};

    for (final material in materiais) {
      final valor = normalizarEspacos(material);
      if (valor.isEmpty) {
        continue;
      }
      unicos.putIfAbsent(normalizarParaComparacao(valor), () => valor);
    }

    return List<String>.unmodifiable(unicos.values);
  }

  static String _asString(dynamic valor) => valor?.toString().trim() ?? '';

  static int _asInt(dynamic valor) {
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic valor, {required bool defaultValue}) {
    if (valor is bool) {
      return valor;
    }
    if (valor is String) {
      if (valor.toLowerCase() == 'true') {
        return true;
      }
      if (valor.toLowerCase() == 'false') {
        return false;
      }
    }
    return defaultValue;
  }

  static List<String> _asStringList(dynamic valor) {
    if (valor is! Iterable) {
      return const <String>[];
    }
    return valor.map((item) => item.toString()).toList(growable: false);
  }

  static DateTime? _asDateTime(dynamic valor) {
    if (valor == null) {
      return null;
    }
    if (valor is DateTime) {
      return valor;
    }
    if (valor is String) {
      return DateTime.tryParse(valor);
    }

    try {
      final dynamic convertido = valor.toDate();
      return convertido is DateTime ? convertido : null;
    } catch (_) {
      return null;
    }
  }
}

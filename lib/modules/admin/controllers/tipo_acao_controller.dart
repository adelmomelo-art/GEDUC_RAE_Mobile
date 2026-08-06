import 'package:flutter/foundation.dart';

import '../../../data/models/tipo_acao_model.dart';
import '../../../repositories/tipo_acao_repository.dart';

enum TipoAcaoFiltroStatus { todos, ativos, inativos }

class TipoAcaoController extends ChangeNotifier {
  TipoAcaoController({required this.tipoAcaoRepository});

  final TipoAcaoRepository tipoAcaoRepository;

  final List<TipoAcaoModel> _tipos = <TipoAcaoModel>[];
  bool _carregando = false;
  bool _salvando = false;
  String? _erro;
  String _filtroTexto = '';
  TipoAcaoFiltroStatus _filtroStatus = TipoAcaoFiltroStatus.todos;

  List<TipoAcaoModel> get tipos => List<TipoAcaoModel>.unmodifiable(_tipos);
  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;
  String get filtroTexto => _filtroTexto;
  TipoAcaoFiltroStatus get filtroStatus => _filtroStatus;

  List<TipoAcaoModel> get tiposFiltrados {
    final termo = TipoAcaoModel.normalizarParaComparacao(_filtroTexto);

    return List<TipoAcaoModel>.unmodifiable(
      _tipos.where((tipo) {
        final correspondeStatus = switch (_filtroStatus) {
          TipoAcaoFiltroStatus.todos => true,
          TipoAcaoFiltroStatus.ativos => tipo.ativo,
          TipoAcaoFiltroStatus.inativos => !tipo.ativo,
        };

        if (!correspondeStatus) {
          return false;
        }
        if (termo.isEmpty) {
          return true;
        }

        final conteudo = <String>[
          tipo.nomeAcao,
          tipo.tipoAcao,
          ...tipo.materiaisSugeridos,
        ].map(TipoAcaoModel.normalizarParaComparacao).join(' ');

        return conteudo.contains(termo);
      }),
    );
  }

  int get totalAtivos => _tipos.where((tipo) => tipo.ativo).length;
  int get totalInativos => _tipos.length - totalAtivos;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resultado = await tipoAcaoRepository.listarTiposAcoes();
      _tipos
        ..clear()
        ..addAll(resultado);
    } catch (erro) {
      _erro = _mensagemErro(erro);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Compatibilidade com o nome usado antes da ADM-002A.1.
  Future<void> carregarTipos() => carregar();

  Future<TipoAcaoModel?> criar(TipoAcaoModel tipoAcao) async {
    return _executarSalvamento<TipoAcaoModel>(() async {
      final criado = await tipoAcaoRepository.criarTipoAcao(tipoAcao);
      _tipos.add(criado);
      _ordenar();
      return criado;
    });
  }

  Future<bool> atualizar(TipoAcaoModel tipoAcao) async {
    final resultado = await _executarSalvamento<bool>(() async {
      await tipoAcaoRepository.atualizarTipoAcao(tipoAcao);
      final indice = _tipos.indexWhere((item) => item.id == tipoAcao.id);
      if (indice >= 0) {
        _tipos[indice] = tipoAcao.normalizado();
        _ordenar();
      }
      return true;
    });
    return resultado ?? false;
  }

  Future<bool> alterarStatus(TipoAcaoModel tipoAcao, bool ativo) async {
    final resultado = await _executarSalvamento<bool>(() async {
      await tipoAcaoRepository.alterarStatus(tipoAcao.id, ativo);
      final indice = _tipos.indexWhere((item) => item.id == tipoAcao.id);
      if (indice >= 0) {
        _tipos[indice] = _tipos[indice].copyWith(ativo: ativo);
      }
      return true;
    });
    return resultado ?? false;
  }

  Future<TipoAcaoModel?> buscarDuplicado(
    TipoAcaoModel candidato, {
    String? ignorarId,
  }) {
    return tipoAcaoRepository.buscarDuplicado(candidato, ignorarId: ignorarId);
  }

  void definirFiltroTexto(String valor) {
    if (_filtroTexto == valor) {
      return;
    }
    _filtroTexto = valor;
    notifyListeners();
  }

  void definirFiltroStatus(TipoAcaoFiltroStatus valor) {
    if (_filtroStatus == valor) {
      return;
    }
    _filtroStatus = valor;
    notifyListeners();
  }

  void limparErro() {
    if (_erro == null) {
      return;
    }
    _erro = null;
    notifyListeners();
  }

  Future<T?> _executarSalvamento<T>(Future<T> Function() operacao) async {
    if (_salvando) {
      return null;
    }

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      return await operacao();
    } catch (erro) {
      _erro = _mensagemErro(erro);
      return null;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  void _ordenar() {
    _tipos.sort(
      (a, b) => a.nomeAcao.toLowerCase().compareTo(b.nomeAcao.toLowerCase()),
    );
  }

  String _mensagemErro(Object erro) {
    if (erro is TipoAcaoValidationException ||
        erro is TipoAcaoDuplicadoException) {
      return erro.toString();
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}

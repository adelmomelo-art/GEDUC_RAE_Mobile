import 'package:flutter/material.dart';

import '../../../core/services/localizacao/gps_service.dart';
import '../../../core/services/localizacao/localizacao_result.dart';
import '../../../core/services/localizacao/location_exception.dart';
import '../../../core/services/localizacao/regional_service.dart';
import '../../../core/services/localizacao/reverse_geocoding_service.dart';
import '../../../data/models/acao_model.dart';
import '../../acoes/controllers/acao_controller.dart';

/// Controller responsável por coordenar todo o fluxo operacional
/// de localização da ação.
class LocalizacaoController extends ChangeNotifier {
  LocalizacaoController({
    GpsService? gpsService,
    ReverseGeocodingService? reverseGeocodingService,
    RegionalService? regionalService,
  })  : _gpsService = gpsService ?? const GpsService(),
        _reverseGeocodingService =
            reverseGeocodingService ?? const ReverseGeocodingService(),
        _regionalService = regionalService ?? RegionalService();

  final GpsService _gpsService;
  final ReverseGeocodingService _reverseGeocodingService;
  final RegionalService _regionalService;

  final TextEditingController nomeLocalController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController regionalController = TextEditingController();
  final TextEditingController pontoReferenciaController =
      TextEditingController();
  final TextEditingController pesquisaEnderecoController =
      TextEditingController();

  bool? _estaNoLocal;
  bool _dadosIniciaisCarregados = false;
  bool _processando = false;
  bool _capturandoGps = false;
  bool _consultandoEndereco = false;
  bool _consultandoRegional = false;

  double _latitude = 0;
  double _longitude = 0;
  double? _precisaoGps;
  DateTime? _dataHoraCaptura;

  OrigemLocalizacao? _origemLocalizacao;
  bool _localizacaoEditadaManualmente = false;
  bool _regionalEditadaManualmente = false;

  int _identificadorConsultaRegional = 0;

  bool? get estaNoLocal => _estaNoLocal;
  bool get dadosIniciaisCarregados => _dadosIniciaisCarregados;
  bool get processando => _processando;
  bool get capturandoGps => _capturandoGps;
  bool get consultandoEndereco => _consultandoEndereco;
  bool get consultandoRegional => _consultandoRegional;

  double get latitude => _latitude;
  double get longitude => _longitude;
  double? get precisaoGps => _precisaoGps;
  DateTime? get dataHoraCaptura => _dataHoraCaptura;

  OrigemLocalizacao? get origemLocalizacao => _origemLocalizacao;

  bool get localizacaoEditadaManualmente {
    return _localizacaoEditadaManualmente;
  }

  bool get regionalEditadaManualmente => _regionalEditadaManualmente;

  bool get possuiLocalizacao {
    return _coordenadasValidas(
      latitude: _latitude,
      longitude: _longitude,
    );
  }

  bool get possuiEndereco {
    return enderecoController.text.trim().isNotEmpty;
  }

  bool get possuiBairro {
    return bairroController.text.trim().isNotEmpty;
  }

  bool get possuiRegional {
    return regionalController.text.trim().isNotEmpty;
  }

  bool get possuiPontoReferencia {
    return pontoReferenciaController.text.trim().isNotEmpty;
  }

  bool get localizacaoBaseConfirmada {
    return possuiLocalizacao &&
        possuiEndereco &&
        possuiBairro &&
        possuiRegional;
  }

  bool get ocupado {
    return _processando ||
        _capturandoGps ||
        _consultandoEndereco ||
        _consultandoRegional;
  }

  String get mensagemFaxita {
    if (_capturandoGps) {
      return 'Estou buscando o melhor sinal disponível. '
          'Aguarde alguns segundos.';
    }

    if (_consultandoEndereco) {
      return 'Localização encontrada. Estou identificando o endereço.';
    }

    if (_consultandoRegional) {
      return 'Estou identificando automaticamente a Regional.';
    }

    if (validarParaAvancar() == null) {
      return 'Os dados da localização estão completos e prontos para '
          'confirmação.';
    }

    if (_estaNoLocal == true && possuiLocalizacao) {
      return 'Localização capturada. Confira os dados e complete o ponto '
          'de referência antes de avançar.';
    }

    if (_estaNoLocal == true) {
      return 'Use o botão de localização para capturar as coordenadas '
          'da ação.';
    }

    if (_estaNoLocal == false && possuiLocalizacao) {
      return 'Confira no mapa se a localização informada está correta e '
          'complete os dados do local.';
    }

    if (_estaNoLocal == false) {
      return 'Informe o endereço onde a ação aconteceu e confira a '
          'posição no mapa.';
    }

    return 'Você está no local onde a ação está acontecendo?';
  }

  /// Carrega apenas uma vez os dados previamente registrados na ação.
  void carregarDadosIniciais(AcaoModel? acao) {
    if (_dadosIniciaisCarregados) {
      return;
    }

    if (acao != null) {
      nomeLocalController.text = acao.nomeLocal;
      enderecoController.text = acao.endereco;
      bairroController.text = acao.bairro;
      regionalController.text = acao.regional;
      _regionalEditadaManualmente = false;

      pontoReferenciaController.text = acao.pontoReferencia.isNotEmpty
          ? acao.pontoReferencia
          : acao.equipamentoReferencia;

      _latitude = acao.latitude;
      _longitude = acao.longitude;
      _precisaoGps = acao.precisaoGps;
      _dataHoraCaptura = acao.dataHoraCaptura;
      _origemLocalizacao = acao.origemLocalizacao;
      _localizacaoEditadaManualmente = acao.localizacaoEditadaManualmente;

      _estaNoLocal = switch (acao.origemLocalizacao) {
        OrigemLocalizacao.gps => true,
        OrigemLocalizacao.enderecoInformado || OrigemLocalizacao.mapa => false,
        null => null,
      };
    }

    _dadosIniciaisCarregados = true;
    notifyListeners();
  }

  void selecionarModo(bool estaNoLocal) {
    if (ocupado) {
      return;
    }

    _estaNoLocal = estaNoLocal;
    notifyListeners();
  }

  void notificarEdicaoDeDados() {
    notifyListeners();
  }

  void registrarEdicaoManualDaRegional(String valor) {
    _regionalEditadaManualmente = valor.trim().isNotEmpty;

    // Invalida eventual consulta automática ainda em andamento.
    _identificadorConsultaRegional++;

    notifyListeners();
  }

  Future<LocalizacaoResult> capturarLocalizacaoGps() async {
    if (_capturandoGps) {
      throw LocationException.localizacaoIndisponivel();
    }

    _capturandoGps = true;
    notifyListeners();

    try {
      final resultado = await _gpsService.capturarLocalizacaoAtual(
        timeout: const Duration(seconds: 30),
      );

      _latitude = resultado.latitude;
      _longitude = resultado.longitude;
      _precisaoGps = resultado.precisao;
      _dataHoraCaptura = resultado.dataHoraCaptura;
      _estaNoLocal = true;
      _origemLocalizacao = OrigemLocalizacao.gps;
      _localizacaoEditadaManualmente = false;

      notifyListeners();

      await preencherEnderecoPelasCoordenadas(
        latitude: resultado.latitude,
        longitude: resultado.longitude,
      );

      return resultado;
    } finally {
      _capturandoGps = false;
      notifyListeners();
    }
  }

  Future<EnderecoGeocodificado?> preencherEnderecoPelasCoordenadas({
    required double latitude,
    required double longitude,
  }) async {
    if (_consultandoEndereco) {
      return null;
    }

    _consultandoEndereco = true;
    notifyListeners();

    try {
      final endereco = await _reverseGeocodingService.buscarEndereco(
        latitude: latitude,
        longitude: longitude,
      );

      if (endereco.logradouro.isNotEmpty) {
        enderecoController.text = _montarEnderecoPrincipal(endereco);
      }

      if (endereco.bairro.isNotEmpty) {
        bairroController.text = endereco.bairro;
      }

      if (bairroController.text.trim().isNotEmpty) {
        await buscarRegionalPorBairro(
          bairroController.text,
          limparQuandoNaoEncontrada: true,
        );
      }

      notifyListeners();
      return endereco;
    } on LocationException {
      return null;
    } finally {
      _consultandoEndereco = false;
      notifyListeners();
    }
  }

  Future<RegionalResult> buscarRegionalPorBairro(
    String bairro, {
    bool limparQuandoNaoEncontrada = true,
  }) async {
    final bairroInformado = bairro.trim();
    final identificadorConsulta = ++_identificadorConsultaRegional;

    _regionalEditadaManualmente = false;

    if (bairroInformado.isEmpty) {
      regionalController.clear();
      notifyListeners();

      return RegionalResult.naoEncontrada(
        bairroConsultado: bairroInformado,
      );
    }

    _consultandoRegional = true;
    notifyListeners();

    try {
      final resultado = await _regionalService.buscarPorBairro(
        bairroInformado,
      );

      if (identificadorConsulta != _identificadorConsultaRegional) {
        return resultado;
      }

      if (resultado.encontrada && resultado.nome.trim().isNotEmpty) {
        regionalController.text = resultado.nome.trim();
        _regionalEditadaManualmente = false;
      } else if (limparQuandoNaoEncontrada &&
          !_regionalEditadaManualmente) {
        regionalController.clear();
      }

      notifyListeners();
      return resultado;
    } finally {
      if (identificadorConsulta == _identificadorConsultaRegional) {
        _consultandoRegional = false;
        notifyListeners();
      }
    }
  }

  Future<void> atualizarPorSelecaoManual({
    required double latitude,
    required double longitude,
  }) async {
    if (!_coordenadasValidas(
      latitude: latitude,
      longitude: longitude,
    )) {
      throw LocationException.localizacaoIndisponivel();
    }

    _latitude = latitude;
    _longitude = longitude;
    _precisaoGps = null;
    _dataHoraCaptura = DateTime.now();
    _estaNoLocal = false;
    _origemLocalizacao = OrigemLocalizacao.mapa;
    _localizacaoEditadaManualmente = true;

    notifyListeners();

    await preencherEnderecoPelasCoordenadas(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void sincronizarComAcao(
    AcaoController acaoController, {
    required bool localizacaoValidada,
  }) {
    acaoController.preencherLocalizacao(
      endereco: enderecoController.text.trim(),
      bairro: bairroController.text.trim(),
      regional: regionalController.text.trim(),
      equipamentoReferencia: pontoReferenciaController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      nomeLocal: nomeLocalController.text.trim(),
      pontoReferencia: pontoReferenciaController.text.trim(),
      origemLocalizacao: _origemLocalizacao ??
          (_estaNoLocal == true
              ? OrigemLocalizacao.gps
              : OrigemLocalizacao.enderecoInformado),
      precisaoGps: _precisaoGps,
      dataHoraCaptura: _dataHoraCaptura,
      localizacaoValidada: localizacaoValidada,
      localizacaoEditadaManualmente: _localizacaoEditadaManualmente,
    );
  }

  String? validarParaAvancar() {
    if (_estaNoLocal == null) {
      return 'Informe se você está no local da ação.';
    }

    if (!possuiEndereco) {
      return 'Informe o endereço da ação.';
    }

    if (!possuiBairro) {
      return 'Informe o bairro da ação.';
    }

    if (!possuiRegional) {
      return 'Informe a Regional. Caso ela não seja identificada '
          'automaticamente, preencha o campo manualmente.';
    }

    if (!possuiPontoReferencia) {
      return 'Informe o ponto de referência.';
    }

    if (!possuiLocalizacao) {
      return _estaNoLocal == true
          ? 'Capture a localização pelo GPS antes de avançar.'
          : 'Pesquise ou selecione a localização no mapa antes de avançar.';
    }

    return null;
  }

  void iniciarProcessamento() {
    if (_processando) {
      return;
    }

    _processando = true;
    notifyListeners();
  }

  void finalizarProcessamento() {
    if (!_processando) {
      return;
    }

    _processando = false;
    notifyListeners();
  }

  Future<void> abrirConfiguracoesDeLocalizacao() {
    return _gpsService.abrirConfiguracoesDeLocalizacao();
  }

  Future<void> abrirConfiguracoesDoAplicativo() {
    return _gpsService.abrirConfiguracoesDoAplicativo();
  }

  String _montarEnderecoPrincipal(
    EnderecoGeocodificado endereco,
  ) {
    final logradouro = endereco.logradouro.trim();
    final numero = endereco.numero.trim();

    if (logradouro.isEmpty) {
      return '';
    }

    if (numero.isEmpty || logradouro.contains(numero)) {
      return logradouro;
    }

    return '$logradouro, $numero';
  }

  bool _coordenadasValidas({
    required double latitude,
    required double longitude,
  }) {
    final latitudeValida = latitude >= -90 && latitude <= 90;
    final longitudeValida = longitude >= -180 && longitude <= 180;

    return latitudeValida &&
        longitudeValida &&
        !(latitude == 0 && longitude == 0);
  }

  @override
  void dispose() {
    nomeLocalController.dispose();
    enderecoController.dispose();
    bairroController.dispose();
    regionalController.dispose();
    pontoReferenciaController.dispose();
    pesquisaEnderecoController.dispose();

    super.dispose();
  }
}

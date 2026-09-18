import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';

class EscalaConfiguracaoDados {
  const EscalaConfiguracaoDados({
    required this.configuracao,
    required this.membrosEquipe,
    required this.perfisOperacionais,
  });

  final EscalaConfiguracaoModel? configuracao;
  final List<MembroEquipeModel> membrosEquipe;
  final List<EscalaPerfilOperacionalModel> perfisOperacionais;
}

abstract class EscalaConfiguracaoRepository {
  Future<EscalaConfiguracaoDados> carregarConfiguracaoOperacional();

  Future<void> salvarConfiguracaoEscala(EscalaConfiguracaoModel configuracao);

  Future<void> salvarPerfilOperacional(EscalaPerfilOperacionalModel perfil);
}

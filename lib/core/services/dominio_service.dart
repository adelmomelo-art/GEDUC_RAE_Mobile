import '../../data/models/dominio_model.dart';
import '../constants/dominio_tipos.dart';

class DominioService {
  List<DominioModel> carregarDominiosIniciais() {
    return const [
      // ============================
      // FORMAÇÃO
      // ============================

      DominioModel(
        id: 'formacao_palestra',
        tipo: DominioTipos.formacao,
        nome: 'Palestra',
        ordem: 1,
      ),

      DominioModel(
        id: 'formacao_oficina',
        tipo: DominioTipos.formacao,
        nome: 'Oficina',
        ordem: 2,
      ),

      DominioModel(
        id: 'formacao_curso',
        tipo: DominioTipos.formacao,
        nome: 'Curso',
        ordem: 3,
      ),

      // ============================
      // PÚBLICO
      // ============================

      DominioModel(
        id: 'publico_criancas',
        tipo: DominioTipos.publico,
        nome: 'Crianças',
        ordem: 1,
      ),

      DominioModel(
        id: 'publico_adolescentes',
        tipo: DominioTipos.publico,
        nome: 'Adolescentes',
        ordem: 2,
      ),

      DominioModel(
        id: 'publico_adultos',
        tipo: DominioTipos.publico,
        nome: 'Adultos',
        ordem: 3,
      ),

      DominioModel(
        id: 'publico_idosos',
        tipo: DominioTipos.publico,
        nome: 'Idosos',
        ordem: 4,
      ),

      // ============================
      // TIPO DE PARTICIPAÇÃO
      // ============================

      DominioModel(
        id: 'participacao_presencial',
        tipo: DominioTipos.tipoParticipacao,
        nome: 'Presencial',
        ordem: 1,
      ),

      DominioModel(
        id: 'participacao_abordagem',
        tipo: DominioTipos.tipoParticipacao,
        nome: 'Abordagem educativa',
        ordem: 2,
      ),

      DominioModel(
        id: 'participacao_evento',
        tipo: DominioTipos.tipoParticipacao,
        nome: 'Evento',
        ordem: 3,
      ),

      // ============================
      // FOCO TEMÁTICO
      // ============================

      DominioModel(
        id: 'tema_velocidade',
        tipo: DominioTipos.focoTematico,
        nome: 'Velocidade',
        ordem: 1,
      ),

      DominioModel(
        id: 'tema_alcool_direcao',
        tipo: DominioTipos.focoTematico,
        nome: 'Álcool e direção',
        ordem: 2,
      ),

      DominioModel(
        id: 'tema_capacete',
        tipo: DominioTipos.focoTematico,
        nome: 'Uso do capacete',
        ordem: 3,
      ),

      DominioModel(
        id: 'tema_cinto',
        tipo: DominioTipos.focoTematico,
        nome: 'Uso do cinto de segurança',
        ordem: 4,
      ),

      DominioModel(
        id: 'tema_celular',
        tipo: DominioTipos.focoTematico,
        nome: 'Uso do celular ao volante',
        ordem: 5,
      ),

      // ============================
      // PERFIL DO USUÁRIO
      // ============================

      DominioModel(
        id: 'perfil_pedestre',
        tipo: DominioTipos.perfilUsuario,
        nome: 'Pedestre',
        ordem: 1,
      ),

      DominioModel(
        id: 'perfil_ciclista',
        tipo: DominioTipos.perfilUsuario,
        nome: 'Ciclista',
        ordem: 2,
      ),

      DominioModel(
        id: 'perfil_motociclista',
        tipo: DominioTipos.perfilUsuario,
        nome: 'Motociclista',
        ordem: 3,
      ),

      DominioModel(
        id: 'perfil_condutor',
        tipo: DominioTipos.perfilUsuario,
        nome: 'Condutor',
        ordem: 4,
      ),

      DominioModel(
        id: 'perfil_passageiro',
        tipo: DominioTipos.perfilUsuario,
        nome: 'Passageiro',
        ordem: 5,
      ),

      // ============================
      // SEXO PREDOMINANTE
      // ============================

      DominioModel(
        id: 'sexo_feminino',
        tipo: DominioTipos.sexoPredominante,
        nome: 'Feminino',
        ordem: 1,
      ),

      DominioModel(
        id: 'sexo_masculino',
        tipo: DominioTipos.sexoPredominante,
        nome: 'Masculino',
        ordem: 2,
      ),

      DominioModel(
        id: 'sexo_misto',
        tipo: DominioTipos.sexoPredominante,
        nome: 'Misto',
        ordem: 3,
      ),

      // ============================
      // AVALIAÇÃO DA AÇÃO
      // ============================

      DominioModel(
        id: 'avaliacao_otima',
        tipo: DominioTipos.avaliacaoAcao,
        nome: 'Ótima',
        ordem: 1,
      ),

      DominioModel(
        id: 'avaliacao_boa',
        tipo: DominioTipos.avaliacaoAcao,
        nome: 'Boa',
        ordem: 2,
      ),

      DominioModel(
        id: 'avaliacao_regular',
        tipo: DominioTipos.avaliacaoAcao,
        nome: 'Regular',
        ordem: 3,
      ),

      DominioModel(
        id: 'avaliacao_ruim',
        tipo: DominioTipos.avaliacaoAcao,
        nome: 'Ruim',
        ordem: 4,
      ),

      // ============================
      // MATERIAL UTILIZADO
      // ============================

      DominioModel(
        id: 'material_folder',
        tipo: DominioTipos.materialUtilizado,
        nome: 'Folder',
        ordem: 1,
      ),

      DominioModel(
        id: 'material_cartilha',
        tipo: DominioTipos.materialUtilizado,
        nome: 'Cartilha',
        ordem: 2,
      ),

      DominioModel(
        id: 'material_faixa',
        tipo: DominioTipos.materialUtilizado,
        nome: 'Faixa educativa',
        ordem: 3,
      ),

      DominioModel(
        id: 'material_ludico',
        tipo: DominioTipos.materialUtilizado,
        nome: 'Material lúdico',
        ordem: 4,
      ),

      // ============================
      // FATORES DE RISCO
      // ============================

      DominioModel(
        id: 'risco_velocidade',
        tipo: DominioTipos.fatorRisco,
        nome: 'Excesso de velocidade',
        ordem: 1,
      ),

      DominioModel(
        id: 'risco_celular',
        tipo: DominioTipos.fatorRisco,
        nome: 'Uso do celular',
        ordem: 2,
      ),

      DominioModel(
        id: 'risco_capacete',
        tipo: DominioTipos.fatorRisco,
        nome: 'Não utilização do capacete',
        ordem: 3,
      ),

      DominioModel(
        id: 'risco_cinto',
        tipo: DominioTipos.fatorRisco,
        nome: 'Não utilização do cinto',
        ordem: 4,
      ),

      DominioModel(
        id: 'risco_alcool',
        tipo: DominioTipos.fatorRisco,
        nome: 'Álcool e direção',
        ordem: 5,
      ),

      // ============================
      // MUDANÇA DE COMPORTAMENTO
      // ============================

      DominioModel(
        id: 'mudanca_sim',
        tipo: DominioTipos.mudancaComportamento,
        nome: 'Sim',
        ordem: 1,
      ),

      DominioModel(
        id: 'mudanca_parcial',
        tipo: DominioTipos.mudancaComportamento,
        nome: 'Parcialmente',
        ordem: 2,
      ),

      DominioModel(
        id: 'mudanca_nao',
        tipo: DominioTipos.mudancaComportamento,
        nome: 'Não observada',
        ordem: 3,
      ),
    ];
  }
}
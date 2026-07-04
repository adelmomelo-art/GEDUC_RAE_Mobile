import '../../data/models/dominio_model.dart';

class DominioService {
  List<DominioModel> carregarDominiosIniciais() {
    return const [
      // Formação
      DominioModel(
        id: 'formacao_palestra',
        tipo: 'formacao',
        nome: 'Palestra',
        ordem: 1,
      ),
      DominioModel(
        id: 'formacao_oficina',
        tipo: 'formacao',
        nome: 'Oficina',
        ordem: 2,
      ),
      DominioModel(
        id: 'formacao_curso',
        tipo: 'formacao',
        nome: 'Curso',
        ordem: 3,
      ),

      // Público
      DominioModel(
        id: 'publico_criancas',
        tipo: 'publico',
        nome: 'Crianças',
        ordem: 1,
      ),
      DominioModel(
        id: 'publico_adolescentes',
        tipo: 'publico',
        nome: 'Adolescentes',
        ordem: 2,
      ),
      DominioModel(
        id: 'publico_adultos',
        tipo: 'publico',
        nome: 'Adultos',
        ordem: 3,
      ),
      DominioModel(
        id: 'publico_idosos',
        tipo: 'publico',
        nome: 'Idosos',
        ordem: 4,
      ),

      // Tipo de participação
      DominioModel(
        id: 'participacao_presencial',
        tipo: 'tipo_participacao',
        nome: 'Presencial',
        ordem: 1,
      ),
      DominioModel(
        id: 'participacao_abordagem',
        tipo: 'tipo_participacao',
        nome: 'Abordagem educativa',
        ordem: 2,
      ),
      DominioModel(
        id: 'participacao_evento',
        tipo: 'tipo_participacao',
        nome: 'Evento',
        ordem: 3,
      ),

      // Foco temático
      DominioModel(
        id: 'tema_velocidade',
        tipo: 'foco_tematico',
        nome: 'Velocidade',
        ordem: 1,
      ),
      DominioModel(
        id: 'tema_alcool_direcao',
        tipo: 'foco_tematico',
        nome: 'Álcool e direção',
        ordem: 2,
      ),
      DominioModel(
        id: 'tema_capacete',
        tipo: 'foco_tematico',
        nome: 'Uso do capacete',
        ordem: 3,
      ),
      DominioModel(
        id: 'tema_cinto',
        tipo: 'foco_tematico',
        nome: 'Uso do cinto de segurança',
        ordem: 4,
      ),
      DominioModel(
        id: 'tema_celular',
        tipo: 'foco_tematico',
        nome: 'Uso do celular ao volante',
        ordem: 5,
      ),

      // Perfil do usuário
      DominioModel(
        id: 'perfil_pedestre',
        tipo: 'perfil_usuario',
        nome: 'Pedestre',
        ordem: 1,
      ),
      DominioModel(
        id: 'perfil_ciclista',
        tipo: 'perfil_usuario',
        nome: 'Ciclista',
        ordem: 2,
      ),
      DominioModel(
        id: 'perfil_motociclista',
        tipo: 'perfil_usuario',
        nome: 'Motociclista',
        ordem: 3,
      ),
      DominioModel(
        id: 'perfil_condutor',
        tipo: 'perfil_usuario',
        nome: 'Condutor',
        ordem: 4,
      ),
      DominioModel(
        id: 'perfil_passageiro',
        tipo: 'perfil_usuario',
        nome: 'Passageiro',
        ordem: 5,
      ),

      // Sexo predominante
      DominioModel(
        id: 'sexo_feminino',
        tipo: 'sexo_predominante',
        nome: 'Feminino',
        ordem: 1,
      ),
      DominioModel(
        id: 'sexo_masculino',
        tipo: 'sexo_predominante',
        nome: 'Masculino',
        ordem: 2,
      ),
      DominioModel(
        id: 'sexo_misto',
        tipo: 'sexo_predominante',
        nome: 'Misto',
        ordem: 3,
      ),

      // Avaliação da ação
      DominioModel(
        id: 'avaliacao_otima',
        tipo: 'avaliacao_acao',
        nome: 'Ótima',
        ordem: 1,
      ),
      DominioModel(
        id: 'avaliacao_boa',
        tipo: 'avaliacao_acao',
        nome: 'Boa',
        ordem: 2,
      ),
      DominioModel(
        id: 'avaliacao_regular',
        tipo: 'avaliacao_acao',
        nome: 'Regular',
        ordem: 3,
      ),
      DominioModel(
        id: 'avaliacao_ruim',
        tipo: 'avaliacao_acao',
        nome: 'Ruim',
        ordem: 4,
      ),

      // Material utilizado
      DominioModel(
        id: 'material_folder',
        tipo: 'material_utilizado',
        nome: 'Folder',
        ordem: 1,
      ),
      DominioModel(
        id: 'material_cartilha',
        tipo: 'material_utilizado',
        nome: 'Cartilha',
        ordem: 2,
      ),
      DominioModel(
        id: 'material_faixa',
        tipo: 'material_utilizado',
        nome: 'Faixa educativa',
        ordem: 3,
      ),
      DominioModel(
        id: 'material_brinquedo',
        tipo: 'material_utilizado',
        nome: 'Material lúdico',
        ordem: 4,
      ),

      // Fator de risco
      DominioModel(
        id: 'risco_excesso_velocidade',
        tipo: 'fator_risco',
        nome: 'Excesso de velocidade',
        ordem: 1,
      ),
      DominioModel(
        id: 'risco_celular',
        tipo: 'fator_risco',
        nome: 'Uso de celular',
        ordem: 2,
      ),
      DominioModel(
        id: 'risco_capacete',
        tipo: 'fator_risco',
        nome: 'Não uso do capacete',
        ordem: 3,
      ),
      DominioModel(
        id: 'risco_cinto',
        tipo: 'fator_risco',
        nome: 'Não uso do cinto',
        ordem: 4,
      ),
      DominioModel(
        id: 'risco_alcool',
        tipo: 'fator_risco',
        nome: 'Álcool e direção',
        ordem: 5,
      ),

      // Mudança de comportamento
      DominioModel(
        id: 'mudanca_sim',
        tipo: 'mudanca_comportamento',
        nome: 'Sim',
        ordem: 1,
      ),
      DominioModel(
        id: 'mudanca_parcial',
        tipo: 'mudanca_comportamento',
        nome: 'Parcialmente',
        ordem: 2,
      ),
      DominioModel(
        id: 'mudanca_nao',
        tipo: 'mudanca_comportamento',
        nome: 'Não observada',
        ordem: 3,
      ),
    ];
  }
}
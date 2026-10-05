import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/agenda/models/agenda_compromisso.dart';
import 'package:geduc_rae_mobile/modules/agenda/services/agenda_service.dart';
import 'package:geduc_rae_mobile/modules/agenda/security/agenda_access_policy.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  test('remarcação e revisão geram snapshots distintos sem perder idempotência',
      () {
    final primeira = AgendaService.novaAtividadeId('acao', '2026-10-05');
    final remarcada = AgendaService.novaAtividadeId('acao', '2026-10-06');
    final revisao = AgendaService.novaAtividadeId('acao', '2026-10-05-v3');
    expect({primeira, remarcada, revisao}, hasLength(3));
    expect(primeira, isNot('agenda-acao'));
    expect(remarcada, AgendaService.novaAtividadeId('acao', '2026-10-06'));
    expect(
        remarcada, isNot(AgendaService.novaAtividadeId('outra', '2026-10-06')));
  });
  final data = DateTime(2026, 10, 5);
  AgendaCompromisso compromisso() => AgendaCompromisso(
      id: 'acao',
      data: data,
      titulo: 'AMC nas Escolas',
      turno: 'manha',
      contatoNome: 'Contato restrito',
      contatoTelefone: 'telefone-restrito',
      observacoesInternas: 'informacao-restrita',
      materiais: 'materiais-restritos',
      orientacaoEquipe: 'Levar material educativo');

  test('permite planejar sem horário e sem público estimado fictício', () {
    final item = compromisso();
    expect(AgendaService.validar(item), isEmpty);
    expect(item.quantidadePublico, isNull);
    expect(item.horarioACombinar, isTrue);
    expect(AgendaService.validar(item, paraEscala: true), isNotEmpty);
  });
  test('horário parcial e quantidades negativas são inválidos', () {
    expect(
        AgendaService.validar(compromisso().alterar({'horaInicio': '08:00'})),
        isNotEmpty);
    expect(
        AgendaService.validar(compromisso().alterar({'quantidadePublico': -1})),
        isNotEmpty);
  });
  test('planejamento precisa estar pronto e ter catálogo, local e horário', () {
    final item = compromisso().alterar({
      'situacao': 'pronta',
      'projetoId': 'projeto-oficial',
      'local': 'Escola',
      'endereco': 'Rua da Escola, 10',
      'horaInicio': '08:00',
      'horaFim': '10:00'
    });
    expect(AgendaService.validar(item, paraEscala: true), isEmpty);
    expect(
        AgendaService.validar(item.alterar({'situacao': 'cancelada'}),
            paraEscala: true),
        isNotEmpty);
  });
  test(
      'snapshot público não contém contatos, materiais nem observações internas',
      () {
    final snapshot = AgendaService.camposPublicos(compromisso());
    expect(snapshot.values, isNot(contains('Contato restrito')));
    expect(snapshot.values, isNot(contains('telefone-restrito')));
    expect(snapshot.values, isNot(contains('informacao-restrita')));
    expect(snapshot.values, isNot(contains('materiais-restritos')));
    expect(snapshot['orientacaoOperacional'], 'Levar material educativo');
  });
  test('modelo preserva vínculo, nulos e revisão no round trip', () {
    final item = compromisso().alterar({
      'revisao': 3,
      'escalaId': 'escala',
      'atividadeId': 'atividade',
      'dataVinculada': data
    });
    final copia = AgendaCompromisso.fromMap(item.id, item.toMap());
    expect(copia.toMap(), item.toMap());
    expect(copia.vinculada, isTrue);
  });
  test('acesso exige agente designado e configuração ativa', () {
    final config = EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'responsavel',
        responsavelEscalaMembroEquipeId: 'membro',
        ativo: true,
        designadoPor: 'admin',
        designadoEm: data);
    for (final perfil in [
      'administrador',
      'gestor',
      'gerente',
      'coordenador',
      'agente'
    ]) {
      expect(
          AgendaAccessPolicy.autoriza(
              usuarioId: 'outro', perfilAcesso: perfil, configuracao: config),
          isFalse);
    }
    expect(
        AgendaAccessPolicy.autoriza(
            usuarioId: 'responsavel',
            perfilAcesso: 'agente',
            configuracao: config),
        isTrue);
    expect(
        AgendaAccessPolicy.autoriza(
            usuarioId: 'responsavel',
            perfilAcesso: 'agente',
            configuracao: null),
        isFalse);
    expect(
        AgendaAccessPolicy.autoriza(
            usuarioId: 'responsavel',
            perfilAcesso: 'administrador',
            configuracao: config),
        isFalse);
  });
}

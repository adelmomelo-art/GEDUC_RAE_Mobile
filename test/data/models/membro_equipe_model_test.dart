import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/equipe_operacional_service.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';

void main() {
  test('usuário legado assume vínculo de agente', () {
    final membro = MembroEquipeModel.fromMap(
      {
        'nome': 'Maria da Silva',
        'ativo': true,
        'createdAt': '2026-08-10T10:00:00.000',
        'updatedAt': '2026-08-10T10:00:00.000',
      },
      documentId: 'maria',
    );

    expect(membro.vinculo, VinculoOperacional.agente);
    expect(membro.podeCoordenar, isFalse);
    expect(membro.ativo, isTrue);
  });

  test('preserva terceirizado habilitado para coordenar', () {
    final membro = MembroEquipeModel.fromMap(
      {
        'usuarioId': 'carlos',
        'nome': 'Carlos Lima',
        'vinculo': 'terceirizado',
        'podeCoordenar': true,
        'ativo': true,
        'origem': 'usuario',
        'createdAt': '2026-08-10T10:00:00.000',
        'updatedAt': '2026-08-10T10:00:00.000',
      },
      documentId: 'carlos',
    );

    expect(membro.vinculo, VinculoOperacional.terceirizado);
    expect(membro.podeCoordenar, isTrue);
    expect(membro.usuarioId, 'carlos');
  });

  test('preserva agente inativo e sem permissão para coordenar', () {
    final membro = MembroEquipeModel.fromMap(
      {
        'nome': 'Agente Inativo',
        'vinculo': 'agente',
        'podeCoordenar': false,
        'ativo': false,
      },
      documentId: 'agente-inativo',
    );

    expect(membro.vinculo, VinculoOperacional.agente);
    expect(membro.ativo, isFalse);
    expect(membro.podeCoordenar, isFalse);
  });

  test('preserva terceirizado ativo sem permissão para coordenar', () {
    final membro = MembroEquipeModel.fromMap(
      {
        'nome': 'Terceirizado Ativo',
        'vinculo': 'terceirizado',
        'podeCoordenar': false,
        'ativo': true,
      },
      documentId: 'terceirizado-ativo',
    );

    expect(membro.vinculo, VinculoOperacional.terceirizado);
    expect(membro.ativo, isTrue);
    expect(membro.podeCoordenar, isFalse);
  });

  test('sincronização preserva situação operacional configurada', () {
    final atual = <String, dynamic>{
      'ativo': true,
      'podeCoordenar': false,
    };

    expect(
      EquipeOperacionalMergePolicy.preservarBooleano(
        atual: atual,
        campo: 'ativo',
        padrao: false,
      ),
      isTrue,
    );
    expect(
      EquipeOperacionalMergePolicy.preservarBooleano(
        atual: atual,
        campo: 'podeCoordenar',
        padrao: true,
      ),
      isFalse,
    );
  });

  test('sincronização usa padrão somente para membro novo', () {
    expect(
      EquipeOperacionalMergePolicy.preservarBooleano(
        atual: null,
        campo: 'ativo',
        padrao: false,
      ),
      isFalse,
    );
  });

  test('MergePolicy preserva falso configurado para ativo', () {
    expect(
      EquipeOperacionalMergePolicy.preservarBooleano(
        atual: const {'ativo': false},
        campo: 'ativo',
        padrao: true,
      ),
      isFalse,
    );
  });
}

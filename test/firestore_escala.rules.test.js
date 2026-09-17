const { before, beforeEach, after, test } = require('node:test');
const fs = require('node:fs');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

const projectId = 'geduc-rae-escala-rules-test';
let ambiente;

function banco(uid) {
  return uid
    ? ambiente.authenticatedContext(uid).firestore()
    : ambiente.unauthenticatedContext().firestore();
}

function agora() {
  return new Date('2026-09-17T12:00:00.000Z');
}

function escala(overrides = {}) {
  return {
    data: new Date('2026-09-17T00:00:00.000Z'),
    status: 'rascunho',
    versao: 1,
    observacaoGeral: '',
    motivoRevisao: '',
    criadoPor: 'responsavel',
    criadoEm: agora(),
    atualizadoPor: 'responsavel',
    atualizadoEm: agora(),
    publicadoPor: '',
    publicadoEm: null,
    ...overrides,
  };
}

function atividadeAdministrativa(overrides = {}) {
  return {
    escalaId: 'escala-1',
    data: new Date('2026-09-17T00:00:00.000Z'),
    secaoId: 'apoio_geduc',
    tipoAtividadeId: 'inteligencia_dados',
    naturezaAtividade: 'administrativa',
    titulo: 'Inteligência e Tratamento de Dados',
    descricao: '',
    turnoId: 'tarde',
    qtrHorario: '',
    horaInicio: '',
    horaFim: '',
    qthLocal: 'Base GEDUC',
    qthEndereco: '',
    qthRegionalId: '',
    qthPontoReferencia: '',
    orientacaoOperacional: '',
    coordenadorMembroEquipeId: 'membro-coordenador',
    coordenadorUsuarioId: 'coordenador',
    coordenadorNomeSnapshot: 'Coordenador Teste',
    participanteUsuarioIds: ['agente'],
    geraRae: false,
    contabilizaProdutividade: true,
    raeId: '',
    execucaoMissaoId: '',
    status: 'planejada',
    criadoPor: 'responsavel',
    criadoEm: agora(),
    atualizadoPor: 'responsavel',
    atualizadoEm: agora(),
    ...overrides,
  };
}

function atividadeEducativa(overrides = {}) {
  return atividadeAdministrativa({
    tipoAtividadeId: 'comando_educativo',
    naturezaAtividade: 'educativa',
    titulo: 'Motociclista Seguro',
    qtrHorario: '06:00',
    horaInicio: '07:00',
    horaFim: '11:00',
    qthLocal: 'Av. Tenente Benévolo x Rua Gonçalves Ledo',
    qthRegionalId: 'regional-12',
    geraRae: true,
    ...overrides,
  });
}

function alocacao(overrides = {}) {
  return {
    escalaId: 'escala-1',
    atividadeId: 'atividade-admin',
    data: new Date('2026-09-17T00:00:00.000Z'),
    membroEquipeId: 'membro-agente',
    usuarioId: 'agente',
    nomeSnapshot: 'Agente',
    vinculoSnapshot: 'agente',
    setorSnapshot: 'GEDUC',
    cargaHorariaSnapshot: '180H',
    funcaoNaAtividade: 'execucao',
    turnoId: 'tarde',
    horaInicio: '12:00',
    horaFim: '16:00',
    tipoJornada: 'normal',
    horaInicioReal: '',
    horaFimReal: '',
    minutosPrevistos: 240,
    minutosRealizados: null,
    motivoJornadaComplementar: '',
    classificadoPor: '',
    classificadoEm: null,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: agora(),
    atualizadoPor: 'responsavel',
    atualizadoEm: agora(),
    ...overrides,
  };
}
function execucao(executor, overrides = {}) {
  return {
    escalaAtividadeId: 'atividade-admin',
    escalaId: 'escala-1',
    data: new Date('2026-09-17T00:00:00.000Z'),
    status: 'concluida',
    resultadoResumo: 'Missão concluída',
    observacao: '',
    evidencias: [],
    executadoPorUsuarioId: executor,
    executadoPorMembroEquipeId: `membro-${executor}`,
    executadoPorNomeSnapshot: executor,
    concluidoEm: agora(),
    criadoEm: agora(),
    atualizadoEm: agora(),
    ...overrides,
  };
}

async function semear() {
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    const db = contexto.firestore();

    const usuarios = {
      admin: { perfilAcesso: 'administrador', ativo: true },
      gestor: { perfilAcesso: 'gestor', ativo: true },
      gerente: { perfilAcesso: 'gerente', ativo: true },
      coordenador: { perfilAcesso: 'coordenador', ativo: true },
      agente: { perfilAcesso: 'agente', ativo: true },
      responsavel: { perfilAcesso: 'agente', ativo: true },
      inativo: { perfilAcesso: 'agente', ativo: false },
      desconhecido: { perfilAcesso: 'superusuario', ativo: true },
    };

    for (const [uid, identidade] of Object.entries(usuarios)) {
      await db.collection('usuarios').doc(uid).set({
        nome: uid,
        perfilAcesso: identidade.perfilAcesso,
        ativo: identidade.ativo,
      });
    }

    const membros = [
      ['membro-responsavel', 'responsavel', false],
      ['membro-agente', 'agente', false],
      ['membro-coordenador', 'coordenador', true],
    ];

    for (const [id, usuarioId, podeCoordenar] of membros) {
      await db.collection('equipe_operacional').doc(id).set({
        usuarioId,
        nome: usuarioId,
        vinculo: 'agente',
        podeCoordenar,
        ativo: true,
        origem: 'usuario',
        createdAt: agora(),
        updatedAt: agora(),
      });
    }

    await db.collection('escala_configuracoes').doc('principal').set({
      responsavelEscalaUsuarioId: 'responsavel',
      responsavelEscalaMembroEquipeId: 'membro-responsavel',
      ativo: true,
      designadoPor: 'gerente',
      designadoEm: agora(),
    });

    await db.collection('escala_perfis_operacionais').doc('membro-responsavel').set({
      membroEquipeId: 'membro-responsavel',
      usuarioId: 'responsavel',
      setorCodigo: 'GEDUC',
      cargaHorariaCodigo: '180H',
      ativo: true,
      criadoPor: 'gerente',
      criadoEm: agora(),
      atualizadoPor: 'gerente',
      atualizadoEm: agora(),
    });

    await db.collection('escalas').doc('escala-1').set(escala());
    await db.collection('escalas').doc('escala-publicada').set(escala({
      status: 'publicada',
      versao: 1,
      criadoPor: 'responsavel',
      atualizadoPor: 'responsavel',
      publicadoPor: 'responsavel',
      publicadoEm: agora(),
    }));

    await db.collection('escala_atividades').doc('atividade-admin').set(
      atividadeAdministrativa(),
    );
    await db.collection('escala_atividades').doc('atividade-educativa').set(
      atividadeEducativa(),
    );

    await db.collection('escala_alocacoes').doc('alocacao-agente').set({
      escalaId: 'escala-1',
      atividadeId: 'atividade-admin',
      data: new Date('2026-09-17T00:00:00.000Z'),
      membroEquipeId: 'membro-agente',
      usuarioId: 'agente',
      nomeSnapshot: 'Agente',
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'execucao',
      turnoId: 'tarde',
      horaInicio: '',
      horaFim: '',
      tipoJornada: 'normal',
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 0,
      minutosRealizados: null,
      motivoJornadaComplementar: '',
      classificadoPor: '',
      classificadoEm: null,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora(),
      atualizadoPor: 'responsavel',
      atualizadoEm: agora(),
    });

    await db.collection('escala_indisponibilidades').doc('ferias-agente').set({
      dataInicio: new Date('2026-09-17T00:00:00.000Z'),
      dataFim: new Date('2026-09-18T00:00:00.000Z'),
      membroEquipeId: 'membro-agente',
      usuarioId: 'agente',
      nomeSnapshot: 'Agente',
      tipoId: 'ferias',
      turnoId: '',
      horaInicio: '',
      horaFim: '',
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora(),
      atualizadoPor: 'responsavel',
      atualizadoEm: agora(),
    });
  });
}

before(async () => {
  ambiente = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await ambiente.clearFirestore();
  await semear();
});

after(async () => {
  await ambiente.cleanup();
});

test('escala nega usuário anônimo, inativo e perfil desconhecido', async () => {
  for (const uid of [null, 'inativo', 'desconhecido']) {
    await assertFails(banco(uid).collection('escalas').get());
  }
});

test('todos os perfis ativos, inclusive gerente, consultam escala completa', async () => {
  for (const uid of ['admin', 'gestor', 'gerente', 'coordenador', 'agente', 'responsavel']) {
    await assertSucceeds(banco(uid).collection('escalas').get());
    await assertSucceeds(banco(uid).collection('escala_atividades').get());
    await assertSucceeds(banco(uid).collection('escala_alocacoes').get());
  }
});

test('agente responsável cria e publica escala', async () => {
  const ref = banco('responsavel').collection('escalas').doc('nova');
  await assertSucceeds(ref.set(escala()));
  await assertSucceeds(ref.update({
    status: 'publicada',
    publicadoPor: 'responsavel',
    publicadoEm: agora(),
    atualizadoPor: 'responsavel',
    atualizadoEm: agora(),
  }));
});

test('agente comum, coordenador e gestor não gerenciam escala', async () => {
  for (const uid of ['agente', 'coordenador', 'gestor']) {
    await assertFails(
      banco(uid).collection('escalas').doc(`negada-${uid}`).set(
        escala({ criadoPor: uid, atualizadoPor: uid }),
      ),
    );
  }
});

test('gerente nao cria, mas altera revisa e publica escala existente', async () => {
  const nova = banco('gerente').collection('escalas').doc('gerente-nova');
  await assertFails(nova.set(escala({
    criadoPor: 'gerente',
    atualizadoPor: 'gerente',
  })));

  const ref = banco('gerente').collection('escalas').doc('escala-1');
  await assertSucceeds(ref.update({
    observacaoGeral: 'Revisada pelo gerente',
    atualizadoPor: 'gerente',
    atualizadoEm: agora(),
  }));
  await assertSucceeds(ref.update({
    status: 'publicada',
    publicadoPor: 'gerente',
    publicadoEm: agora(),
    atualizadoPor: 'gerente',
    atualizadoEm: agora(),
  }));
});

test('administrador configura, mas nao opera escala', async () => {
  await assertFails(
    banco('admin').collection('escalas').doc('admin-nova').set(
      escala({ criadoPor: 'admin', atualizadoPor: 'admin' }),
    ),
  );
  await assertFails(
    banco('admin').collection('escalas').doc('escala-1').update({
      observacaoGeral: 'Tentativa operacional',
      atualizadoPor: 'admin',
      atualizadoEm: agora(),
    }),
  );
});

test('revisão de escala publicada exige nova versão e motivo', async () => {
  const ref = banco('gerente').collection('escalas').doc('escala-publicada');

  await assertFails(ref.update({
    observacaoGeral: 'Sem versionar',
    atualizadoPor: 'gerente',
    atualizadoEm: agora(),
  }));

  await assertSucceeds(ref.update({
    observacaoGeral: 'Versão revisada',
    versao: 2,
    motivoRevisao: 'Substituição operacional',
    publicadoPor: 'gerente',
    publicadoEm: agora(),
    atualizadoPor: 'gerente',
    atualizadoEm: agora(),
  }));
});

test('somente gerente ou administrador designa responsável fixo', async () => {
  const refGerente = banco('gerente').collection('escala_configuracoes').doc('principal');
  await assertSucceeds(refGerente.update({
    responsavelEscalaUsuarioId: 'agente',
    responsavelEscalaMembroEquipeId: 'membro-agente',
    designadoPor: 'gerente',
    designadoEm: agora(),
  }));

  await assertFails(
    banco('responsavel').collection('escala_configuracoes').doc('principal').update({
      responsavelEscalaUsuarioId: 'agente',
      responsavelEscalaMembroEquipeId: 'membro-agente',
      designadoPor: 'responsavel',
      designadoEm: agora(),
    }),
  );
});

test('responsável da escala precisa ser agente ativo e membro ativo', async () => {
  await assertFails(
    banco('gerente').collection('escala_configuracoes').doc('principal').update({
      responsavelEscalaUsuarioId: 'coordenador',
      responsavelEscalaMembroEquipeId: 'membro-coordenador',
      designadoPor: 'gerente',
      designadoEm: agora(),
    }),
  );
});

test('gerente mantém perfis operacionais e agente apenas consulta', async () => {
  const dados = {
    membroEquipeId: 'membro-agente',
    usuarioId: 'agente',
    setorCodigo: 'GEDUC',
    cargaHorariaCodigo: '240H',
    ativo: true,
    criadoPor: 'gerente',
    criadoEm: agora(),
    atualizadoPor: 'gerente',
    atualizadoEm: agora(),
  };

  await assertSucceeds(
    banco('gerente').collection('escala_perfis_operacionais').doc('membro-agente').set(dados),
  );
  await assertSucceeds(
    banco('agente').collection('escala_perfis_operacionais').get(),
  );
  await assertFails(
    banco('agente').collection('escala_perfis_operacionais').doc('membro-agente').set({
      ...dados,
      criadoPor: 'agente',
      atualizadoPor: 'agente',
    }),
  );
});

test('alocacao aceita normal, hora extra e banco de horas', async () => {
  await assertSucceeds(
    banco('responsavel').collection('escala_alocacoes').doc('j-normal').set(
      alocacao(),
    ),
  );
  await assertSucceeds(
    banco('responsavel').collection('escala_alocacoes').doc('j-extra').set(
      alocacao({
        tipoJornada: 'hora_extra',
        motivoJornadaComplementar: 'Reforco operacional',
        classificadoPor: 'responsavel',
        classificadoEm: agora(),
      }),
    ),
  );
  await assertSucceeds(
    banco('responsavel').collection('escala_alocacoes').doc('j-banco').set(
      alocacao({
        tipoJornada: 'banco_horas',
        motivoJornadaComplementar: 'Credito para compensacao futura',
        classificadoPor: 'responsavel',
        classificadoEm: agora(),
      }),
    ),
  );
});

test('alocacao rejeita jornada desconhecida e minutos invalidos', async () => {
  await assertFails(
    banco('responsavel').collection('escala_alocacoes').doc('j-invalida').set(
      alocacao({ tipoJornada: 'dobra' }),
    ),
  );
  await assertFails(
    banco('responsavel').collection('escala_alocacoes').doc('min-invalido').set(
      alocacao({ minutosPrevistos: 1441 }),
    ),
  );
});

test('jornada complementar exige motivo, autoria e timestamp', async () => {
  await assertFails(
    banco('responsavel').collection('escala_alocacoes').doc('extra-sem-motivo').set(
      alocacao({
        tipoJornada: 'hora_extra',
        classificadoPor: 'responsavel',
        classificadoEm: agora(),
      }),
    ),
  );
  await assertFails(
    banco('responsavel').collection('escala_alocacoes').doc('banco-forjado').set(
      alocacao({
        tipoJornada: 'banco_horas',
        motivoJornadaComplementar: 'Teste',
        classificadoPor: 'gerente',
        classificadoEm: agora(),
      }),
    ),
  );
});
test('ação educativa exige geraRae=true e administrativa exige false', async () => {
  await assertFails(
    banco('responsavel').collection('escala_atividades').doc('educativa-invalida').set(
      atividadeEducativa({ geraRae: false }),
    ),
  );
  await assertFails(
    banco('responsavel').collection('escala_atividades').doc('admin-invalida').set(
      atividadeAdministrativa({ geraRae: true }),
    ),
  );
  await assertSucceeds(
    banco('responsavel').collection('escala_atividades').doc('educativa-valida').set(
      atividadeEducativa(),
    ),
  );
});

test('coordenador atua na execução, não altera estrutura da escala', async () => {
  await assertFails(
    banco('coordenador').collection('escala_atividades').doc('atividade-admin').update({
      qtrHorario: '10:00',
      atualizadoPor: 'coordenador',
      atualizadoEm: agora(),
    }),
  );

  await assertSucceeds(
    banco('coordenador').collection('escala_execucoes_missao').doc('exec-coord').set(
      execucao('coordenador'),
    ),
  );
});

test('agente participante registra própria missão administrativa', async () => {
  await assertSucceeds(
    banco('agente').collection('escala_execucoes_missao').doc('exec-agente').set(
      execucao('agente'),
    ),
  );
});

test('agente não participante não registra missão administrativa', async () => {
  await assertFails(
    banco('responsavel').collection('escala_execucoes_missao').doc('exec-fora').set(
      execucao('responsavel'),
    ),
  );
});

test('execução administrativa aceita evidência sem horas reais', async () => {
  const dados = execucao('agente', {
    evidencias: [{
      id: 'ev-1',
      tipo: 'documento',
      descricao: 'Relatório consolidado',
      referencia: 'ref-futura',
      criadoPor: 'agente',
      criadoEm: agora(),
    }],
  });

  await assertSucceeds(
    banco('agente').collection('escala_execucoes_missao').doc('exec-evidencia').set(dados),
  );
});

test('execução administrativa não aceita forjar outro executor', async () => {
  await assertFails(
    banco('agente').collection('escala_execucoes_missao').doc('exec-falso').set(
      execucao('coordenador'),
    ),
  );
});

test('ação educativa não usa registro de missão administrativa', async () => {
  await assertFails(
    banco('agente').collection('escala_execucoes_missao').doc('exec-educativa').set(
      execucao('agente', { escalaAtividadeId: 'atividade-educativa' }),
    ),
  );
});

test('férias e sobreposição não são bloqueios server-side da publicação', async () => {
  await assertSucceeds(
    banco('responsavel').collection('escala_atividades').doc('atividade-sobreposta').set(
      atividadeAdministrativa({
        titulo: 'Segunda atividade simultânea',
        participanteUsuarioIds: ['agente'],
      }),
    ),
  );
});

test('coleções de escala não permitem exclusão pelo cliente', async () => {
  const casos = [
    ['escalas', 'escala-1'],
    ['escala_atividades', 'atividade-admin'],
    ['escala_alocacoes', 'alocacao-agente'],
    ['escala_indisponibilidades', 'ferias-agente'],
    ['escala_configuracoes', 'principal'],
    ['escala_perfis_operacionais', 'membro-responsavel'],
  ];

  for (const [colecao, id] of casos) {
    await assertFails(banco('admin').collection(colecao).doc(id).delete());
  }
});

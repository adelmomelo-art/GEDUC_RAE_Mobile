# ESC-001C — BLUEPRINT
## Modelo de Dados + Firestore Rules + Segurança

**Baseline:** `7578c5eafd53985c036d35eb5476bcb3a0009177`
**Branch:** `feature/esc-001c-modelo-dados-rules`

## Objetivo

Transformar a matriz funcional homologada da ESC-001B em contratos de dados e segurança testáveis, sem implementar ainda as telas de gestão da escala.

## Princípios

1. `equipe_operacional` continua sendo a identidade operacional canônica.
2. `usuarios` continua sendo identidade/autenticação/autorização.
3. A configuração específica de escala guarda setor e carga horária sem criar cadastro paralelo de pessoa.
4. Todos os perfis ativos da escala podem ler a escala completa.
5. Escrita estrutural da escala fica restrita ao Gerente, Administrador e agente fixo responsável.
6. O Coordenador atua na execução, não na gestão.
7. O agente participante pode registrar sua própria execução administrativa.
8. Ações educativas exigem `geraRae=true`.
9. Missões administrativas exigem `geraRae=false` e podem ter evidências.
10. Férias/folga/compensação e sobreposição são alertas de aplicação, não bloqueios server-side.

## Coleções

- `escala_configuracoes` — documento `principal` com o agente fixo responsável.
- `escala_perfis_operacionais` — vínculo do membro operacional com setor/carga horária/elegibilidade.
- `escalas` — cabeçalho diário/versionamento/publicação.
- `escala_atividades` — ações educativas e missões administrativas.
- `escala_alocacoes` — pessoas alocadas por atividade.
- `escala_indisponibilidades` — férias/folga/compensação informativas.
- `escala_execucoes_missao` — execução leve das missões administrativas.

## Isolamento do Gerente

As regras existentes excluem `gerente` de `perfilReconhecido()`. Alterar isso globalmente faria `usuarioAtivo()` liberar coleções legadas de forma ampla.

ESC-001C NÃO altera essa função. Em vez disso cria:

- `usuarioEscalaAtivo()`;
- `perfilEscalaAtual()`;
- `podeGerenciarEscala()`;
- `podeRegistrarExecucaoMissao()`.

Assim, o Gerente passa a operar a escala sem receber, por consequência, novos poderes sobre RAEs, domínios ou outros módulos.

## Evidências administrativas

O modelo aceita metadados de evidência, mas ESC-001C não habilita Storage/R2 e não muda `remoteStorageEnabled=false`. O transporte/armazenamento físico continuará condicionado às frentes de evidência já existentes.

## Fora do escopo

- telas;
- rotas;
- importador do PDF;
- geração do PDF da escala;
- vínculo automático Escala → RAE;
- indicadores;
- Faixita;
- notificações;
- Storage remoto;
- Cloudflare R2.

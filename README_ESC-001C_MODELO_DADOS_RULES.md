# ESC-001C — Modelo de Dados e Firestore Rules

## Resultado esperado

Esta etapa estabelece a fundação técnica da Escala GEDUC sem criar interface.

### Segurança

- todos os perfis ativos da Escala leem a escala completa;
- agente responsável fixo gerencia a escala;
- Gerente gerencia a escala e designa o responsável;
- Administrador mantém governança técnica;
- Gestor permanece somente leitura até decisão futura;
- Coordenador atua na execução e não altera estrutura da escala;
- participante pode registrar própria execução administrativa;
- exclusão de documentos de escala pelo cliente permanece bloqueada.

### Regra crítica de compatibilidade

O perfil `gerente` NÃO é adicionado à função global `perfilReconhecido()` de `firestore.rules`. A autorização do Gerente é isolada às coleções de escala, evitando ampliar o ACL legado de RAE por efeito colateral.

### Dados

As coleções novas são:

- `escala_configuracoes`;
- `escala_perfis_operacionais`;
- `escalas`;
- `escala_atividades`;
- `escala_alocacoes`;
- `escala_indisponibilidades`;
- `escala_execucoes_missao`.

### RAE

Toda atividade com `naturezaAtividade=educativa` deve ter `geraRae=true`.

Missões administrativas devem ter `geraRae=false` e poderão registrar execução/evidência para produtividade.

### Alertas não bloqueantes

Conflitos de horário, férias, folga e compensação não são bloqueados por Firestore Rules. A camada de aplicação futura apresentará alertas e permitirá que a autoridade operacional decida.

### Evidências

ESC-001C modela metadados de evidência administrativa. Não habilita Firebase Storage, Cloudflare R2 nem outro armazenamento remoto.

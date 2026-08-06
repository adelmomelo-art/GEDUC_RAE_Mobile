# ADM-002A — Diagnóstico arquitetural

## Síntese

O módulo não está começando do zero. Há rota, permissão, provider, controller, repository, service, modelo e regras Firestore. O problema central é que esses componentes não formam hoje um fluxo único.

## Achados

| Prioridade | Achado | Consequência |
|---|---|---|
| Alta | `TiposAcoesPage` acessa Firestore diretamente | arquitetura existente é ignorada e testes ficam difíceis |
| Alta | `NovaAcaoPage` também lê a coleção diretamente | regra de negócio fica duplicada |
| Alta | tipos inativos não são filtrados na Nova Ação | item administrativamente inativo pode continuar sendo selecionado |
| Alta | formulário não possui validação | documentos vazios ou incoerentes podem ser gravados |
| Alta | regras Firestore não validam schema | perfil é protegido, mas conteúdo inválido é aceito |
| Média | controller só carrega lista | não controla criar, editar, status, erro ou saving |
| Média | service não é injetável | testes unitários exigem Firebase real ou adaptações |
| Média | parsing usa apenas `doc.data()` | o identificador depende do campo interno `id` |
| Média | metadata é inconsistente | tela direta escreve `criadoEm`; service atual não escreve |
| Média | não há edição | correção de cadastro exige intervenção externa |
| Média | interface é um diálogo simples | baixa ergonomia em celular e tablet |
| Média | não há confirmação de inativação | alteração acidental de disponibilidade |
| Média | ausência de tratamento de erro na página | falhas podem ser silenciosas |
| Baixa | rota não está sob `/admin` | inconsistência de nomenclatura, sem risco funcional imediato |
| Baixa | `nova_acao_page1.dart` duplica fluxo | dívida técnica e risco de manutenção |

## Pontos já corretos

- branch e baseline limpas;
- rota protegida;
- administrador e gestor autorizados;
- coordenador e agente sem permissão administrativa;
- leitura permitida a usuário ativo;
- delete bloqueado;
- módulo separado da Central de Domínios;
- provider já registrado;
- repository e service já criados;
- catálogo administrativo já identifica o módulo como em evolução.

## Parecer

A evolução deve ser uma **consolidação arquitetural**, não uma terceira implementação paralela. O código direto da página deve ser substituído, não mantido ao lado do controller.

## Risco principal

O maior risco de negócio é a combinação entre:

1. inativação administrativa;
2. leitura sem filtro na Nova Ação;
3. ausência de validação de documentos.

Isso permite que o catálogo deixe de refletir efetivamente o que está disponível para operação.

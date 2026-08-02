# ADM-001C — Identidade e Segurança

## Resultado consolidado

A ADM-001C estabelece identidade operacional validada, política única de
autorização no cliente e baseline versionada/testável das regras do Firestore.

## Pacotes

| Pacote | Commit | Resultado | Validação |
|---|---|---|---|
| ADM-001C.1 | `072c5a5` | Identidade Confiável | tablet aprovado; analyze 0 |
| ADM-001C.2 | `fc575a0` | Política Única de Autorização | tablet 10/10; analyze 0 |
| ADM-001C.3 | `42e3560` | Firestore Security Baseline | emulador 14/14; analyze 0 |
| ADM-001C.4 | pendente | Homologação e encerramento | tablet 10/10; documentação atualizada |

## Arquitetura resultante

- Firebase Auth estabelece a sessão autenticada.
- `usuarios/{uid}` estabelece identidade, situação ativa e perfil.
- `AuthorizationService` mantém a identidade corrente.
- `AuthorizationPolicy` é a matriz única de permissões no cliente.
- `RouteGuard` protege rotas administrativas.
- Firestore Rules é a autoridade final sobre os dados.
- Interfaces não autorizam por comparação textual de perfil.
- Coleções não inventariadas são negadas por padrão.

## Evidências acumuladas

- correção do `Stack Overflow` no ciclo de identidade/roteamento;
- login, retomada, Home, Administração, voltar, logout e novo login aprovados;
- painel administrativo com seis módulos aprovado;
- listagem e atualização de usuários aprovadas;
- 14 testes positivos e negativos das regras aprovados;
- zero vulnerabilidades npm altas ou críticas na cadeia de teste;
- `flutter analyze` com zero issues em todos os pacotes;
- commits e pushes incrementais concluídos.
- homologação integrada final no tablet: 10/10 itens aprovados.

## Estado das regras remotas

As novas regras estão versionadas e aprovadas no emulador, mas **não estão
publicadas no Firebase remoto**. Este encerramento não equivale a autorização
de `firebase deploy`.

## Débitos controlados

- `acoes` ainda não possui autoria imutável por UID;
- matriz de permissões ainda é estática;
- publicação remota e teste de fumaça dependem de procedimento separado;
- a sprint somente alcança status final após PR, Code Review, merge e validação
  pós-merge.

## Próximos passos

1. gerar CPB final;
2. registrar o commit documental;
3. fazer push da branch;
4. abrir Pull Request para `main`;
5. realizar Code Review Arquitetural;
6. fazer merge e validação pós-merge;
7. deliberar separadamente sobre publicação das regras.

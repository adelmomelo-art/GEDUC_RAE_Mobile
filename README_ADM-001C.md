# ADM-001C — Identidade e Segurança

## Resultado consolidado

A ADM-001C estabelece identidade operacional validada, política única de
autorização no cliente e baseline versionada/testável das regras do Firestore.

## Pacotes

| Pacote | Commit | Resultado | Validação |
|---|---|---|---|
| ADM-001C.1 | `072c5a5` | Identidade Confiável | tablet aprovado; analyze 0 |
| ADM-001C.2 | `fc575a0` | Política Única de Autorização | tablet 10/10; analyze 0 |
| ADM-001C.3 + R1 | `42e3560`, `2129355` | Firestore Security Baseline | emulador 15/15; analyze 0 |
| ADM-001C.4 | `0d3d831` | Homologação e encerramento | tablet 10/10; CPB final 7/7 |

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
- 15 testes positivos e negativos das regras aprovados após Code Review;
- validação estrutural e imutabilidade de `createdAt` restauradas em `domains`;
- zero vulnerabilidades npm altas ou críticas na cadeia de teste;
- `flutter analyze` com zero issues em todos os pacotes;
- CPB corretivo da Code Review com 11/11 arquivos;
- commits e pushes incrementais concluídos;
- Pull Request nº 3 aberto, atualizado e automaticamente mesclável;
- Code Review Arquitetural aprovada após a correção R1;
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

1. concluído — gerar CPB final;
2. concluído — registrar o commit documental e o corretivo R1;
3. concluído — fazer push da branch;
4. concluído — abrir Pull Request para `main`;
5. concluído — realizar Code Review Arquitetural;
6. pendente — atualizar a descrição do PR, fazer merge e validação pós-merge;
7. pendente — deliberar separadamente sobre publicação das regras.

# ADM-001C — Identidade e Segurança

## Resultado consolidado

A ADM-001C estabelece identidade operacional validada, política única de
autorização no cliente e baseline versionada/testável das regras do Firestore.

**Status final:** concluída e integrada à `main` pelo merge commit `21f8ea2`,
com validação pós-merge aprovada.

## Pacotes

| Pacote | Commit | Resultado | Validação |
|---|---|---|---|
| ADM-001C.1 | `072c5a5` | Identidade Confiável | tablet aprovado; analyze 0 |
| ADM-001C.2 | `fc575a0` | Política Única de Autorização | tablet 10/10; analyze 0 |
| ADM-001C.3 + R1 | `42e3560`, `2129355` | Firestore Security Baseline | emulador 15/15; analyze 0 |
| ADM-001C.4 | `0d3d831`, merge `21f8ea2` | Homologação e encerramento | tablet 10/10; pós-merge aprovado |

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
- Pull Request nº 3 integrado à `main` no merge commit `21f8ea2`;
- validação pós-merge: analyze 0, Firestore 15/15 e working tree limpa;
- homologação integrada final no tablet: 10/10 itens aprovados.

## Estado das regras remotas

As novas regras estão versionadas e aprovadas no emulador, mas **não estão
publicadas no Firebase remoto**. Este encerramento não equivale a autorização
de `firebase deploy`.

## Débitos controlados

- `acoes` ainda não possui autoria imutável por UID;
- matriz de permissões ainda é estática;
- publicação remota e teste de fumaça dependem de procedimento separado;
- o repositório ainda não possui status checks ou workflows automatizados.

## Próximos passos

1. concluído — CPBs, commits e pushes incrementais;
2. concluído — Pull Request e Code Review Arquitetural;
3. concluído — merge e validação pós-merge;
4. pendente e separado da ADM-001C — deliberar sobre publicação das regras;
5. débito futuro — instituir status checks e workflows automatizados.

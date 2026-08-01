# PF-ENG 003/2026 — POLÍTICA OFICIAL DE ENGENHARIA

> Plataforma Fênix — Sistema de Conhecimento da Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

| Item | Valor |
|---|---|
| Código | PF-ENG 003/2026 |
| Título | Política Oficial de Engenharia |
| Versão | 1.0 |
| Status | Oficial |
| Data de adoção | 31/07/2026 |
| Baseline inicial | `08f969d` |

------------------------------------------------------------------------

# 1. Objetivo

Instituir o processo obrigatório para alterações estruturais, funcionais
de alto impacto e de segurança na Plataforma Fênix.

A política busca garantir:

- rastreabilidade;
- qualidade;
- previsibilidade;
- revisão técnica;
- redução de regressões;
- alinhamento entre código, arquitetura e documentação.

------------------------------------------------------------------------

# 2. Abrangência

A política é obrigatória para alterações envolvendo:

- arquitetura;
- autenticação e autorização;
- roteamento;
- providers globais;
- serviços e repositórios compartilhados;
- modelos de dados;
- regras do Firestore;
- módulos administrativos;
- sincronização e armazenamento;
- Analytics Engine;
- Faixita;
- integrações externas;
- mudanças metodológicas.

Correções triviais podem utilizar fluxo simplificado somente quando não
alterarem contratos, arquitetura ou segurança.

------------------------------------------------------------------------

# 3. Fluxo obrigatório

``` text
1. Inspeção arquitetural
2. Blueprint
3. Plano de implementação
4. Criação de feature branch
5. Implementação incremental
6. dart format controlado
7. flutter analyze com 0 issues
8. Homologação funcional
9. Testes complementares
10. Validação Git
11. CPB homologado
12. Commit
13. Push
14. Pull Request
15. Code Review Arquitetural
16. Merge na main
17. Validação pós-merge
18. Atualização documental
19. Encerramento da sprint
```

------------------------------------------------------------------------

# 4. Branches

## 4.1 Branch principal

`main` representa a versão integrada, homologada e documentada.

Nenhuma alteração estrutural deve ser implementada diretamente na
`main`.

## 4.2 Branches de trabalho

Padrões:

``` text
feature/<identificador>
hotfix/<identificador>
release/<identificador>
docs/<identificador>
```

Exemplos:

``` text
feature/adm-001b2-autorizacao-administrativa
docs/enc-adm-001b2-governanca
```

------------------------------------------------------------------------

# 5. Qualidade obrigatória

Antes do commit:

``` text
flutter analyze
No issues found!
```

Também devem ser executados:

``` text
git status
git diff --stat
git diff --check
```

Arquivos acidentais, artefatos gerados, credenciais e documentos fora do
escopo devem ser removidos antes do staging.

------------------------------------------------------------------------

# 6. CPB

O ChatGPT Package Builder é o mecanismo oficial de troca auditável de
arquivos.

Cada pacote deve possuir:

- manifesto versionado;
- estrutura de diretórios preservada;
- relatório de geração;
- evidência Git;
- resultado do `flutter analyze`, quando aplicável;
- zero arquivos ausentes.

Saídas ZIP permanecem fora do Git.

------------------------------------------------------------------------

# 7. Pull Request

Pull Request é obrigatório para mudanças estruturais.

O PR deve registrar:

- objetivo;
- entregas;
- arquivos relevantes;
- homologações;
- resultado do `flutter analyze`;
- riscos conhecidos;
- documentação relacionada.

O merge somente pode ocorrer após Code Review Arquitetural aprovada.

------------------------------------------------------------------------

# 8. Code Review Arquitetural

A revisão deve avaliar, quando aplicável:

- aderência ao Blueprint;
- separação de responsabilidades;
- direção das dependências;
- escopo dos providers;
- segurança;
- autorização;
- navegação;
- tratamento de erros;
- impacto em dados;
- regressões;
- testabilidade;
- documentação;
- rastreabilidade.

Parecer padrão:

``` text
Arquitetura:
Segurança:
Navegação:
Qualidade:
Homologação:
Riscos:
Resultado:
```

------------------------------------------------------------------------

# 9. Merge e pós-merge

Após o merge:

``` text
git switch main
git pull --ff-only origin main
flutter analyze
git status
```

Critérios:

- `main` sincronizada;
- `flutter analyze` com 0 issues;
- `working tree clean`;
- documentação atualizada;
- baseline registrada.

------------------------------------------------------------------------

# 10. Documentação obrigatória

Alterações estruturais devem atualizar:

- `docs/01_PLATFORM_ARCHITECTURE.md`;
- `docs/06_ENGINEERING_LOG.md`;
- Blueprint correspondente;
- política ou guia afetado;
- ADR, quando necessário.

Código e documentação devem representar a mesma arquitetura.

------------------------------------------------------------------------

# 11. Exceções

Exceções a esta política exigem:

- justificativa registrada;
- avaliação de risco;
- autorização da Diretoria de Engenharia;
- plano de regularização documental e técnica.

------------------------------------------------------------------------

# 12. Marco inaugural

A política foi aplicada formalmente pela primeira vez na integração:

``` text
ADM-001B.1 — Fundação Administrativa
ADM-001B.2 — Camada de Autorização Administrativa
Pull Request nº 1
Merge: 08f969d
```

------------------------------------------------------------------------

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**
**Documento Oficial — PF-ENG 003/2026**

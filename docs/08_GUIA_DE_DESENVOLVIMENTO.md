# GUIA DE DESENVOLVIMENTO DA PLATAFORMA FÊNIX

> Manual Oficial do Desenvolvedor\
> Sistema de Conhecimento da Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- -------------------------------
  Documento   08_GUIA_DE_DESENVOLVIMENTO.md
  Versão      2.0
  Status      Oficial
  Sprint      Arquitetural 1.0

------------------------------------------------------------------------

# 1. Objetivo

Este guia estabelece o padrão oficial para desenvolvimento da Plataforma
Fênix.

Todo colaborador deverá seguir este documento antes de implementar novas
funcionalidades, corrigir defeitos ou propor alterações arquiteturais.

------------------------------------------------------------------------

# 2. Estrutura do Projeto

``` text
lib/
 ├── core/
 ├── modules/
 ├── models/
 ├── services/
 ├── repositories/
 ├── controllers/
 ├── widgets/
 └── routes/

assets/
DOCS/
ARCHITECTURE/
```

Cada componente deve possuir responsabilidade única e organização
consistente.

------------------------------------------------------------------------

# 3. Fluxo Oficial de Desenvolvimento

``` text
Blueprint
      ↓
Planejamento
      ↓
Implementação
      ↓
flutter analyze
      ↓
Homologação
      ↓
Atualização do SKPF
      ↓
Git Commit
```

Nenhuma etapa deve ser ignorada.

------------------------------------------------------------------------

# 4. Padrões de Código

-   Arquivos completos nas entregas.
-   Classes com responsabilidade única.
-   Reutilização antes de duplicação.
-   Serviços desacoplados.
-   Comentários apenas quando agregarem contexto.
-   Nomes claros e consistentes.

------------------------------------------------------------------------

# 5. Organização dos Módulos

Cada módulo deverá conter, quando aplicável:

-   pages
-   controllers
-   services
-   models
-   widgets

Evite dependências circulares entre módulos.

------------------------------------------------------------------------

# 6. Checklist antes do flutter analyze

-   Compilação local.
-   Imports organizados.
-   Código não utilizado removido.
-   Avisos analisados.
-   Documentação atualizada quando necessário.

------------------------------------------------------------------------

# 7. Checklist de Homologação

Antes da aprovação:

-   funcionalidades testadas;
-   navegação validada;
-   persistência verificada;
-   integração confirmada;
-   flutter analyze sem erros críticos;
-   aprovação do responsável pelo produto.

------------------------------------------------------------------------

# 8. Padrão de Commits

Utilize mensagens objetivas e rastreáveis.

Exemplos:

``` text
feat(localizacao): adiciona seleção pelo mapa

fix(sync): corrige sincronização offline

docs(SKPF): atualiza arquitetura
```

------------------------------------------------------------------------

# 9. Atualização do SKPF

Alterações estruturais exigem atualização dos documentos
correspondentes:

-   Arquitetura
-   Engineering Log
-   Blueprint
-   ADR (quando aplicável)

------------------------------------------------------------------------

# 10. Filosofia da Plataforma

A Plataforma Fênix evolui de forma incremental.

Qualidade, rastreabilidade e documentação possuem a mesma importância
que o código.

Toda implementação deve contribuir para uma arquitetura sustentável e de
longo prazo.

------------------------------------------------------------------------

──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Guia de Desenvolvimento

Versão 2.0

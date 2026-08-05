# BLUEPRINT — PV-007B-R3
## Alinhamento cromático da Home Operacional

**Projeto:** Plataforma Fênix — GEDUC/RAE Mobile
**Data:** 05/08/2026
**Branch de aplicação:** `feature/pv-007b-home-operacional-compacta`

## 1. Objetivo

Alinhar a Home Operacional ao layout visual aprovado, corrigindo a divergência cromática observada após a homologação responsiva da R2, sem alterar regras de negócio, rotas, permissões ou comportamento dos componentes.

## 2. Diretrizes preservadas

- Responsividade multidispositivo da R2 mantida.
- Breakpoints, espaçamentos, alturas mínimas e alvos de toque mantidos.
- Fonte atual mantida; a adoção da Aribau Grotesk permanece pausada.
- Nenhuma alteração em Providers, rotas, serviços, modelos ou dependências.
- Paleta restrita ao módulo Home por meio de `HomeVisualTokens`.

## 3. Paleta R3

| Papel visual | Cor | Hexadecimal |
|---|---:|---:|
| Cabeçalho — início | Laranja institucional vivo | `#F24A0D` |
| Cabeçalho — fim | Laranja institucional profundo | `#E33F0D` |
| Ação Nova Ação | Laranja escuro | `#C83A0F` |
| Ação Consultar RAE | Verde-petróleo | `#007C72` |
| Verde-petróleo escuro | Apoio e textos | `#005E57` |
| Azul | BI e Pessoas | `#0B88C9` |
| Azul-marinho | Administração e controles | `#153E5A` |
| Grafite | Saída | `#333333` |
| Creme Faixita | Fundo do card | `#FFEEDC` |
| Sucesso | Verde operacional | `#1E8A32` |
| Canvas | Off-white | `#FAFAF8` |

## 4. Aplicação por componente

### Cabeçalho
- Gradiente laranja institucional.
- Ícone institucional laranja em fundo branco.
- Identificação `Plataforma Fênix • GEDUC` em selo branco com texto azul-marinho.
- Atualizar em azul-marinho e sair em grafite.

### Atalhos
- Nova Ação em laranja.
- Consultar RAE em verde-petróleo.
- Dashboard em verde-petróleo.
- BI GEDUC e Offline em azul.
- Administração em azul-marinho.
- Atalhos secundários com fundo branco e borda neutra.

### Faixita
- Card em creme suave.
- Título em azul-marinho.
- Destaques em laranja.
- Ação de orientação em verde-petróleo.

### Indicadores
- Ações em verde-petróleo.
- Pessoas em azul.
- Veículos em laranja.
- Credenciais em azul-marinho.
- Cards brancos com ícones em círculos cromáticos suaves.

### RAEs e sistema
- RAEs preservam verde-petróleo e estados operacionais.
- Sistema saudável preserva verde de sucesso.
- Alertas mantêm cores semânticas próprias.

## 5. Critérios de aceite

1. O cabeçalho deve aparecer em laranja em celular e tablet.
2. Nova Ação e Consultar RAE devem manter distinção laranja/verde-petróleo.
3. Não deve existir roxo nos atalhos da Home.
4. O card da Faixita deve usar fundo creme.
5. Pessoas deve usar azul e Credenciais azul-marinho.
6. Os testes responsivos anteriores devem continuar aprovados.
7. `flutter analyze` deve terminar com `No issues found!`.

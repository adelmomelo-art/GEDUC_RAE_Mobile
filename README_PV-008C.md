# PV-008C — Jornada RAE: etapas iniciais

## Baseline

- `main`: `431864e9009a91f3aea10c7a8c73e9fd342181fc`;
- branch: `feature/pv-008c-jornada-rae-inicio`;
- fundação: PV-008B homologada e integrada.

## Escopo

- Nova Ação;
- Localização;
- Caracterização;
- Recursos Operacionais;
- Integração e Observações.

As cinco telas passam a compartilhar `FenixAppBar` e
`FenixJourneyHeader`, com identidade institucional, indicação de etapa e
progresso responsivo. Regras, dados, validações e rotas permanecem inalterados.

## Homologação prevista

- Galaxy A05 e Samsung Tab S6 em retrato;
- larguras automatizadas de 320, 360, 412 e 800 px;
- escala de texto 1,3;
- fluxo de ida e volta entre as cinco etapas;
- preservação do rascunho e dos dados já preenchidos.

## Validação técnica

- 518 testes automatizados aprovados;
- `flutter analyze`: `No issues found!`;
- APK debug gerado com 190,94 MB;
- SHA-256: `DA3F536A6BAEE619570E25A900955531B20B80ED7EE41D7B5032636DF47C043D`.

## Homologação física

Concluída em 08/08/2026:

- Samsung Galaxy A05: etapas 1 a 5, ida, volta, rascunho e escala ampliada aprovados;
- Samsung Tab S6: etapas 1 a 5, ida, volta, rascunho e escala ampliada aprovados;
- avanço da etapa 5 para Resultados preservado nos dois dispositivos.

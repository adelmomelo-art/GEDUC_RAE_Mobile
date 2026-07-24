# CE-030A — Etapa 2: Evolução do AcaoModel

## Arquivo para substituição

Substitua o arquivo atual `acao_model.dart` pelo arquivo incluído neste pacote.

## Novos recursos

- enum `OrigemLocalizacao`;
- `nomeLocal`;
- `pontoReferencia`;
- `precisaoGps`;
- `dataHoraCaptura`;
- `localizacaoValidada`;
- `localizacaoEditadaManualmente`;
- serialização compatível com registros antigos;
- leitura de `DateTime`, texto ISO, milissegundos e objetos com `toDate()`;
- preservação de `equipamentoReferencia` como campo legado.

## Validação

Execute na raiz do projeto:

```bash
flutter analyze
```

O resultado esperado é:

```text
No issues found!
```

Não altere ainda o `AcaoController`. Ele será atualizado na Etapa 3 após a homologação deste modelo.

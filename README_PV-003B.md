# PV-003B — Dados institucionais da Caracterização

## Arquivo substituído

`lib/modules/acoes/caracterizacao_acao_page.dart`

## Implementações

- cabeçalho institucional;
- orientação contextual da Faxita;
- formação, tipo de participação e instituição parceira;
- campos obrigatórios identificados visualmente;
- checkboxes responsivos;
- persistência automática do rascunho;
- persistência ao voltar;
- restauração dos dados;
- navegação protegida;
- fluxo para `/recursos-operacionais` preservado.

## Validação

```bash
flutter analyze
```

## Teste operacional

1. Acesse Caracterização.
2. Preencha Formação, Tipo de participação e Instituição parceira.
3. Volte para Localização e retorne.
4. Confirme a restauração.
5. Complete os demais campos.
6. Avance para Recursos Operacionais.
7. Teste em janela estreita e larga.

## Critério de homologação

- zero erros no `flutter analyze`;
- nenhuma perda de dados;
- sem overflow;
- avanço e retorno funcionando.

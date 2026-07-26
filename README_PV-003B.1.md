# PV-003B.1 — Refinamento operacional da Caracterização

## Arquivo substituído

```text
lib/modules/acoes/caracterizacao_acao_page.dart
```

## Ajustes executados

- removido o bloco superior redundante de identificação da etapa;
- orientação da etapa concentrada na Faxita;
- retirado o texto isolado sobre campos obrigatórios;
- Faxita em amarelo enquanto houver pendências obrigatórias;
- Faxita em verde quando todos os campos obrigatórios estiverem completos;
- campo de instituição parceira com cabeçalho em negrito;
- campo identificado como opcional;
- exemplo interno: `Ex.: PM, GMF, DETRAN, Honda`;
- ícone de parceria preservado;
- botões transferidos para barra inferior fixa;
- rótulos padronizados para `Voltar` e `Confirmar e avançar`;
- persistência automática e restauração do rascunho preservadas.

## Aplicação

Copie a pasta `lib` sobre a pasta `lib` do projeto e substitua o arquivo atual.

Execute:

```bash
flutter analyze
```

## Teste operacional

1. Abrir a tela com os campos vazios e confirmar a Faxita amarela.
2. Verificar se não existe mais o bloco superior redundante.
3. Confirmar que a Faxita informa sobre os campos com `*`.
4. Verificar o campo opcional de instituição parceira e seu exemplo.
5. Preencher parcialmente e confirmar que a Faxita permanece amarela.
6. Preencher todos os campos obrigatórios e confirmar que a Faxita fica verde.
7. Voltar à Localização e retornar à Caracterização.
8. Confirmar a preservação integral dos dados.
9. Verificar a barra inferior fixa e os botões.
10. Avançar para Recursos Operacionais.
11. Executar `flutter analyze`.

## Critério de homologação

- zero issues no `flutter analyze`;
- padrão semafórico funcionando;
- persistência aprovada;
- navegação coerente com as telas anteriores;
- ausência de overflow em tela estreita.

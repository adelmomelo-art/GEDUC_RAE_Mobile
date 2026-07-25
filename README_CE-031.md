# CE-031 — Refinamento Operacional da Localização

## Arquivos alterados

1. `lib/modules/localizacao/controllers/localizacao_controller.dart`
2. `lib/modules/localizacao/localizacao_page.dart`
3. `lib/modules/localizacao/widgets/localizacao_form_card.dart`
4. `lib/modules/localizacao/widgets/faxita_location_card.dart`
5. `lib/modules/localizacao/widgets/gps_status_card.dart`

## Correções e melhorias

- Conversão do horário de captura para o fuso local apenas na exibição.
- Validação individual de endereço, bairro, Regional, ponto de referência e coordenadas.
- Regional liberada para preenchimento manual quando a identificação automática falhar.
- Proteção contra respostas antigas de consultas assíncronas de Regional.
- Limpeza de Regional antiga quando o novo bairro não tiver correspondência.
- Pergunta sobre presença no local exibida apenas pela Faxita.
- Estados visuais da Faxita:
  - amarelo: aguardando ou processando;
  - verde: dados completos;
  - vermelho: erro ou impedimento;
  - informativo: orientação normal.
- Mensagem operacional para divergência entre o bairro do geocodificador e a base territorial.

## Procedimento

1. Faça uma cópia de segurança dos cinco arquivos atuais.
2. Substitua pelos arquivos deste pacote.
3. Execute:

```powershell
flutter analyze
```

4. Não faça commit antes da homologação funcional.

## Roteiro de teste

### Cenário A — GPS com bairro cadastrado
- Marcar “Sim, estou no local”.
- Capturar localização.
- Confirmar endereço, bairro e Regional.
- Confirmar horário local correto.
- Informar ponto de referência.
- Confirmar Faxita verde.
- Avançar.

### Cenário B — Bairro sem correspondência
- Usar um bairro que não esteja na lista territorial.
- Confirmar mensagem vermelha da Faxita.
- Preencher Regional manualmente.
- Informar os demais campos.
- Avançar.

### Cenário C — Validação individual
- Apagar somente o endereço e tentar avançar.
- Repetir para bairro, Regional e ponto de referência.
- Confirmar que cada mensagem identifica apenas o campo ausente.

### Cenário D — Pergunta única
- Abrir a tela.
- Confirmar que a pergunta sobre estar no local aparece somente na mensagem da Faxita.

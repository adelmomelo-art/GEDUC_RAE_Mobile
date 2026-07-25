# PV-002B — Pesquisa de endereço e localização remota

## Objetivo

Permitir que o usuário registre a localização da ação mesmo quando não estiver
fisicamente no local.

## Arquivos entregues

- `lib/core/services/localizacao/endereco_geocoding_service.dart`
- `lib/modules/localizacao/controllers/localizacao_controller.dart`
- `lib/modules/localizacao/localizacao_page.dart`
- `lib/modules/localizacao/widgets/endereco_manual_card.dart`

## Implementações

- geocodificação direta de endereço para latitude e longitude;
- reposicionamento automático do mapa após a pesquisa;
- geocodificação reversa para preencher endereço e bairro;
- tentativa automática de identificação da Regional;
- registro da origem como `enderecoInformado`;
- persistência imediata no `AcaoController`;
- indicador visual durante a pesquisa;
- mensagens operacionais da Faxita;
- tratamento de endereço vazio, não encontrado e falha do serviço.

## Procedimento

Copie a pasta `lib` do pacote sobre a pasta `lib` do projeto, preservando a
estrutura dos diretórios.

Depois execute:

```bash
flutter analyze
```

## Teste operacional

1. Abra uma Nova Ação e avance para Localização.
2. Escolha `Não estou no local`.
3. Pesquise um endereço completo de Fortaleza.
4. Confirme que o mapa foi reposicionado.
5. Confira endereço, bairro e Regional.
6. Informe o ponto de referência.
7. Volte para Nova Ação e entre novamente em Localização.
8. Confirme que os dados pesquisados foram preservados.
9. Confirme e avance para Caracterização.

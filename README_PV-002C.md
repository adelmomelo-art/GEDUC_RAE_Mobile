# PV-002C — Seleção direta da localização pelo mapa

## Objetivo

Permitir que o usuário registre a localização da ação tocando diretamente no mapa quando selecionar **Não estou no local**.

## Arquivos para substituição

- `lib/modules/localizacao/localizacao_page.dart`
- `lib/modules/localizacao/widgets/mapa_localizacao_widget.dart`

## Implementações

- seleção de coordenadas por toque no mapa;
- reposicionamento automático do marcador;
- geocodificação reversa do ponto selecionado;
- preenchimento automático do endereço e bairro;
- identificação automática da Regional;
- origem persistida como `OrigemLocalizacao.mapa`;
- persistência imediata no `AcaoController` como localização ainda não validada;
- orientação contextual da Faxita;
- bloqueio da seleção enquanto o módulo estiver processando;
- manutenção do fluxo de GPS para o modo **Estou no local**.

## Aplicação

Copie a pasta `lib` sobre a pasta `lib` do projeto, mantendo a estrutura.

Depois execute:

```bash
flutter analyze
```

## Teste operacional

1. Abra **Nova Ação** e avance para **Localização**.
2. Selecione **Não estou no local**.
3. Toque em um ponto do mapa.
4. Confirme o deslocamento do marcador.
5. Verifique o preenchimento de endereço, bairro e Regional.
6. Informe o ponto de referência.
7. Toque em outro ponto e confirme a atualização dos dados.
8. Volte para **Nova Ação** e entre novamente em **Localização**.
9. Confirme a preservação do ponto selecionado.
10. Confirme e avance para **Caracterização**.

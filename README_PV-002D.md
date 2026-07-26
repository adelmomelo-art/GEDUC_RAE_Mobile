# PV-002D — Padronização visual da Localização

## Objetivo

Alinhar a tela **Localização da Ação** ao padrão visual homologado no PV-001, mantendo integralmente os fluxos funcionais aprovados nos pacotes PV-002A, PV-002B e PV-002C.

## Arquivo para substituição

- `lib/modules/localizacao/localizacao_page.dart`

## Implementações

- cabeçalho institucional com identidade visual alinhada à tela Nova Ação;
- melhoria da hierarquia visual da etapa de localização;
- refinamento do card de escolha entre GPS e localização remota;
- manutenção do card contextual da Faxita;
- resumo consolidado da localização antes da confirmação;
- exibição responsiva em uma ou duas colunas;
- indicação visual quando os dados já são suficientes para avançar;
- preservação integral da captura por GPS, pesquisa por endereço, seleção pelo mapa e persistência do rascunho.

## Aplicação

Copie a pasta `lib` sobre a pasta `lib` do projeto, mantendo a estrutura.

Depois execute:

```bash
flutter analyze
```

## Teste operacional

1. Abra **Nova Ação** e avance para **Localização**.
2. Confirme a exibição do novo cabeçalho institucional.
3. Teste o modo **Sim, estou no local** e capture o GPS.
4. Confirme a atualização do mapa, status, formulário e resumo.
5. Retorne e teste o modo **Não estou no local**.
6. Pesquise um endereço e confirme a atualização do resumo.
7. Selecione outro ponto diretamente no mapa.
8. Edite bairro, Regional e ponto de referência.
9. Confirme que o resumo acompanha as alterações.
10. Verifique o layout em janela estreita e larga.
11. Volte para Nova Ação e retorne para confirmar a persistência.
12. Confirme e avance para **Caracterização**.

## Critério de homologação

- `flutter analyze` sem erros;
- fluxos PV-002A, PV-002B e PV-002C preservados;
- cabeçalho, cards e resumo exibidos corretamente;
- nenhuma perda de dados durante a navegação.

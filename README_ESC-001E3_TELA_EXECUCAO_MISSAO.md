# ESC-001E.3 — Execução da Missão

Esta entrega integra a Escala publicada à execução administrativa individual da E.2. Abre a tela pelo cartão da missão, carrega o executor canônico, permite iniciar, salvar resultado/observação, concluir e cancelar com confirmação e consulta o registro encerrado.

O botão só aparece a participante ou coordenador autorizado. A rota e o controller voltam a validar o acesso. A política e as Rules negam execução pelo perfil administrador, mesmo se escalado como participante.

## Homologação funcional

1. Publicar uma escala com missão administrativa sem RAE. Entrar como agente participante: abrir missão e iniciar; recarregar e confirmar que continua a mesma execução.
2. Salvar resultado e observação; sair e voltar: os dois valores devem permanecer.
3. Tentar concluir com resultado vazio: operação impedida. Concluir com resultado: confirmar, conferir status e campos somente leitura; tentar retornar à tela não reabre.
4. Em outra missão, cancelar: recusar a confirmação mantém a missão em andamento; confirmar encerra e bloqueia edição.
5. Coordenador da atividade consegue registrar somente a própria execução. Agente externo e administrador não recebem a ação nem escrevem a execução.
6. Escala rascunho, ação educativa e missão marcada para RAE não expõem a ação de execução; erro de rede permite nova tentativa sem duplicar registro.
7. Verificar que QTR, QTH, equipe e horas planejadas permanecem intactos. Evidências são apenas exibidas nesta etapa.

## Validações exigidas

```powershell
flutter test
flutter analyze
npm ci
npm run test:rules
git diff --check
```

O fechamento depende de `flutter analyze` com zero issues, todos os testes passando e os gates do PR aprovados. Ver [blueprint](docs/ESC-001E3_BLUEPRINT_TELA_EXECUCAO_MISSAO.md).

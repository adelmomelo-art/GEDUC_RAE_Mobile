# PV-003C — Público-alvo

## Arquivo substituído

```text
lib/modules/acoes/caracterizacao_acao_page.dart
```

## Escopo implementado

- correção semântica do campo `Público` para:
  - Público interno;
  - Público externo;
  - Público interno e externo;
- ampliação dos perfis de usuários;
- inclusão de públicos etários e operacionais;
- refinamento das opções de sexo predominante;
- orientação objetiva sobre público interno e externo;
- resumo dinâmico do público selecionado;
- compatibilidade com rascunhos antigos;
- migração automática dos antigos valores:
  - Crianças;
  - Adolescentes;
  - Adultos;
  - Idosos;
- preservação do contrato existente com `AcaoController`;
- manutenção integral do RF-021;
- Faxita e padrão semafórico preservados;
- nenhuma alteração em `AcaoModel` ou `AcaoController`.

## Aplicação

Copie a pasta `lib` sobre a pasta `lib` do projeto e substitua o arquivo atual.

Execute:

```powershell
flutter analyze
```

Com o aplicativo já aberto no dispositivo, pressione:

```text
R
```

Use Hot Restart nesta etapa porque os mapas de opções e a restauração inicial foram alterados.

## Teste operacional

1. Confirmar as opções:
   - Público interno;
   - Público externo;
   - Público interno e externo.
2. Verificar a orientação abaixo do campo.
3. Selecionar diferentes perfis de usuários.
4. Confirmar a atualização do resumo dinâmico.
5. Verificar as quatro opções de sexo predominante.
6. Voltar para Localização e retornar.
7. Confirmar preservação integral dos dados.
8. Fechar e reabrir o aplicativo com rascunho existente.
9. Confirmar que não há erro em rascunhos antigos.
10. Confirmar mudança da Faxita para verde quando todos os campos obrigatórios estiverem completos.

## Critério de homologação

- `flutter analyze` com zero issues;
- ausência de overflow;
- persistência aprovada;
- resumo dinâmico correto;
- público interno/externo operacionalmente compreensível;
- compatibilidade com rascunhos anteriores.

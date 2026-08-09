# Revisão — catálogos da Caracterização

## Problemas tratados

- opção `Misto` cadastrada em `sexo_predominante` não aparecia imediatamente;
- campo de sexo predominante não possuía a pergunta destacada solicitada;
- alterações e desativações feitas na Central de Domínios podiam permanecer
  ocultas pelo cache persistente da Caracterização.

## Correção

- recarregar os grupos da Caracterização ao entrar na tela, preservando o
  cache somente como contingência offline;
- invalidar o cache global depois de editar, ativar ou desativar um domínio;
- exibir em negrito `Qual o sexo predominante *` antes do seletor;
- manter o seletor com o texto neutro `Selecione uma opção`.

## Integração com domínios legados

A desativação de itens antigos de Formação utiliza a regularização de
`createdAt` já integrada à `main` e publicada nas regras do Firestore. A parte
cliente está incluída no APK conjunto desta revisão.

## Validação

- teste de atualização do catálogo de duas para três opções aprovado;
- 523 testes Flutter aprovados;
- `flutter analyze --no-pub`: sem apontamentos.
- APK debug gerado com 190,94 MB;
- SHA-256: `35FE8E63D7F315F2C3F438E2E72BC99BEEFEF706FDDC3B25A6C7A12CEE5C36C5`.

## Homologação virtual

Concluída e aprovada em 08/08/2026:

- Masculino, Feminino e Misto disponíveis;
- cabeçalho `Qual o sexo predominante` aprovado;
- desativação de item legado de Formação aprovada;
- item desativado removido das opções ativas da Caracterização;
- valor antigo preservado em rascunhos;
- escala ampliada e retorno da tela aprovados.

A homologação física permanece separada e pendente.

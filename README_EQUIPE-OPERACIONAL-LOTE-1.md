# Equipe Operacional - Lote 1

## Objetivo

Criar uma fundacao segura para classificar todos os participantes do sistema como agentes ou terceirizados e indicar quem pode coordenar acoes.

## Estrutura

A colecao `usuarios` permanece protegida e responsavel por identidade, contato e permissao. A nova colecao `equipe_operacional` disponibiliza apenas os dados necessarios aos formularios operacionais:

- identificador do usuario;
- nome;
- vinculo `agente` ou `terceirizado`;
- habilitacao para coordenar;
- situacao ativa;
- origem e datas de auditoria.

## Compatibilidade

O comando administrativo de sincronizacao:

1. registra usuarios atuais como agentes por padrao;
2. preserva classificacoes ja realizadas;
3. habilita os coordenadores existentes;
4. consolida usuario e coordenador pelo e-mail quando possivel;
5. preserva coordenadores legados ainda nao vinculados a um usuario.

## Seguranca

- usuarios ativos podem ler o catalogo operacional;
- somente administradores podem criar ou alterar classificacoes;
- exclusao permanece bloqueada;
- vinculos diferentes de agente ou terceirizado sao rejeitados.

## Limite do lote

Este lote nao altera ainda o preenchimento do RAE. As caixas de selecao da tela Recursos Operacionais pertencem ao Lote 2.

## Metodologia temporaria de cadastro

Durante a fase de testes, novas identidades continuam sendo criadas no Firebase Authentication e vinculadas manualmente a um documento de mesmo UID na colecao `usuarios`. A tela Usuarios permanece somente para consulta.

Depois do cadastro da identidade, o administrador utiliza a sincronizacao da Equipe Operacional e classifica o membro como Agente ou Terceirizado, podendo tambem habilita-lo para coordenar acoes.

Um formulario administrativo para criacao segura de contas fica registrado como evolucao futura e nao integra este lote.

## Correcao R1

A sincronizacao foi ajustada para preservar as decisoes administrativas ja registradas em `equipe_operacional`:

- situacao ativa ou inativa;
- vinculo Agente ou Terceirizado;
- habilitacao para coordenar.

Somente membros novos recebem valores padrao. A regressao foi coberta por testes automatizados.

## Estado ao encerrar

- regras da colecao `equipe_operacional` publicadas no projeto Firebase `geduc-rae-mobile`;
- APK de homologacao R1 gerado e assinado;
- analise Flutter sem problemas;
- 531 testes Flutter aprovados;
- 19 testes das regras do Firestore aprovados;
- implementacao ainda sem commit, push ou PR.

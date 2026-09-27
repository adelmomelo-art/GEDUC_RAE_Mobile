# CAD-USU-001 — Cadastro controlado de usuários

O pacote substitui o cadastro manual simultâneo no Firebase Authentication e
no Firestore por um fluxo de convite controlado pelo administrador.

## Fluxo operacional

1. O administrador abre **Administração > Usuários** e cria um convite ou cola
   uma lista CSV com até 400 pessoas.
2. O sistema gera um código individual, válido por 30 dias. Não existe senha
   provisória compartilhada.
3. A pessoa usa **Recebi um convite / ativar conta**, cria a própria senha e
   confirma o e-mail.
4. Após entrar, informa o código. A identidade `/usuarios/{uid}` nasce inativa.
   Agentes e coordenadores também recebem um vínculo operacional inativo com o
   mesmo UID.
5. O administrador revisa o vínculo operacional (ou o escopo do gerente) e só
   então ativa a conta na tela de usuários.

## CSV

Cabeçalho obrigatório:

```text
nome;email;telefone;cargo;setor;perfilAcesso
```

Perfis aceitos: `gestor`, `gerente`, `coordenador` e `agente`. A criação de
novos administradores continua fora desse fluxo por ser uma operação de alto
privilégio.

## Garantias

- o convite só pode ser usado pelo e-mail confirmado correspondente;
- perfil e dados cadastrais são copiados do convite, não escolhidos pelo usuário;
- o UID do Authentication é a chave canônica em `usuarios` e
  `equipe_operacional`;
- agentes/coordenadores não podem ser ativados sem vínculo operacional ativo;
- gerente não pode ser ativado sem Regional, Equipe e Projeto;
- nenhuma exclusão é liberada ao cliente;
- o pacote não implementa cálculo financeiro nem usa Cloud Functions.

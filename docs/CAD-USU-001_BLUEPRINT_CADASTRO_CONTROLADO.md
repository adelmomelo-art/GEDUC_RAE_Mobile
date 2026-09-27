# Blueprint — CAD-USU-001

**Baseline:** `05d28261697375a5f880c582d0e1347764f2974c`

## Objetivo

Permitir carga inicial e manutenção controlada de identidades sem conceder ao
aplicativo administrativo a senha dos usuários e sem depender de edição manual
do Firestore.

## Estados

| Estado | Authentication | Firestore `usuarios` | Acesso |
|---|---|---|---|
| Convite pendente | ausente | ausente | nenhum |
| E-mail a confirmar | presente/não confirmado | ausente | nenhum |
| Aguardando revisão | presente/confirmado | presente/inativo | bloqueado |
| Ativo | presente/confirmado | presente/ativo | conforme perfil |

## Coleção `convites_usuarios`

O ID é um UUID opaco. O documento registra identidade pretendida, perfil,
autor, validade, estado e UID consumidor. O consumo ocorre em transação junto
à criação de `usuarios/{uid}` e, quando operacional, de
`equipe_operacional/{uid}`.

## Decisões de segurança

- convite exige token autenticado com `email_verified == true`;
- o e-mail do token deve ser idêntico ao e-mail normalizado do convite;
- administrador não pode ser criado por convite;
- identidade nasce sempre com `ativo: false`;
- ativação e desativação possuem autor e timestamp do servidor;
- as regras validam prontidão operacional na ativação;
- a importação CSV é colada na interface para evitar permissões de arquivo e
  plugins nativos adicionais.

## Fora do escopo

Envio automático de e-mail, exclusão física, redefinição administrativa de
senha, criação de administrador, cálculo financeiro e processamento por Cloud
Functions.

# ESC-001D.6 — BLUEPRINT TÉCNICO
## Configuração da Escala e integração Home

**Baseline:** `42a2fbef36bb27a8859e3c6b4d54b9ed528efb9c`
**Dependências:** ESC-001D.1 a ESC-001D.5 fechadas
**Plano de origem:** ESC-001D_PLANO_IMPLEMENTACAO_v0.1 — seção 82

## 1. Resultado

A D.6 fecha a configuração operacional do módulo e a entrada pela Home:

```text
Equipe Operacional
      ↓
Perfil da Escala GEDUC
      ↓
Responsável fixo
      ↓
Rotas/guards
      ↓
Home
```

## 2. Responsável fixo

Elegibilidade na UI/controller:

```text
membro operacional ativo
+ perfil da Escala ativo
+ setor GEDUC
+ vínculo operacional Agente
+ usuarioId canônico não vazio
```

A Rules já preserva a validação de identidade crítica:

```text
usuário ativo
perfil de acesso = agente
membro ativo
membro.usuarioId = usuário selecionado
```

O perfil operacional ativo é critério de seleção do fluxo D.6. Como a
coleção histórica `escala_perfis_operacionais` não possui chave documental
canônica obrigatória por `membroEquipeId`, não foi introduzida uma migração
silenciosa de IDs nesta etapa.

## 3. Equipe GEDUC

A tela não duplica cadastro de pessoa.

Origem:

```text
equipe_operacional
```

Configuração específica:

```text
escala_perfis_operacionais
```

Campos alteráveis nesta tela:

```text
ativo na Escala GEDUC
carga horária = 180H | 240H
```

Campos apenas exibidos:

```text
nome
vínculo
pode coordenar
UID canônico
```

O responsável atual não pode ser desativado antes da designação de outro.

## 4. Permissões

```text
Consulta Escala
= todos os perfis reconhecidos ativos

Gestão
= Gerente
  ou agente responsável

Configuração
= Gerente
  ou Administrador

Administrador opera escala
= NÃO
```

## 5. Rotas

```text
/escala
/escala/gestao
/escala/configuracao
```

A decisão é centralizada em `EscalaNavigationPolicy`, reutilizada por routes
e Home.

## 6. Home

Atalhos do módulo:

```text
Escala GEDUC
Minha Escala
Gestão da Escala
Configuração da Escala
```

Regras:

```text
Escala GEDUC / Minha Escala
= todos os perfis ativos reconhecidos

Gestão
= Gerente ou responsável

Configuração
= Gerente ou Administrador
```

“Minha Escala” continua sendo apenas:

```text
/escala?minha=1
```

Nenhuma segunda página é criada.

## 7. Firestore Rules

A D.6 reforça atualização de `escala_perfis_operacionais` para impedir troca
de identidade do perfil em um update:

```text
membroEquipeId preservado
usuarioId preservado
```

Create continua validando compatibilidade com a Equipe Operacional.

## 8. Fora do escopo

- execução das missões (ESC-001E);
- Escala → RAE (ESC-001F);
- PDF oficial (ESC-001G);
- indicadores/Faixita (ESC-001H);
- financeiro.

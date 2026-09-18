# ESC-001D.7 — FECHAMENTO INTEGRAL
## Módulo Escala GEDUC

**Baseline de entrada:** `032654cac21deb6f3ddf436bc5145ddc21a683a7`
**Fase:** ESC-001D.7
**Natureza:** fechamento técnico, regressão e evidência
**Regra desta etapa:** nenhuma funcionalidade nova

## 1. Cadeia de fechamento

A ESC-001D foi concluída incrementalmente:

```text
ESC-001D.1  Segurança e contratos
ESC-001D.2  Equipe, conferência, horas e conflitos
ESC-001D.3  Consulta da Escala GEDUC
ESC-001D.4  Gestão, rascunho, atividades e alocações
ESC-001D.5  Publicação, revisão e versionamento
ESC-001D.6  Configuração e integração Home
ESC-001D.7  Fechamento integral
```

Baselines de merge consolidadas:

```text
D.1 = c4af0b1dbb366b2352d6ac60b4bf20193ad9eda9
D.2 = 4b1902fa80708ac330b11d94c85aa3f37e4112a3
D.3 = 97f7f331c82a845fbabac375610a5d0ecf110d57
D.4 = cf0df4c0aa510e470db209e28cc762700190a878
D.5 = 42a2fbef36bb27a8859e3c6b4d54b9ed528efb9c
D.6 = 032654cac21deb6f3ddf436bc5145ddc21a683a7
```

## 2. Contratos funcionais congelados

### Consulta

```text
/escala
```

Todos os perfis reconhecidos ativos podem consultar a escala publicada.

“Minha Escala” continua sendo filtro da mesma tela:

```text
/escala?minha=1
```

### Gestão

```text
/escala/gestao
```

Autorizados:

```text
Gerente
ou agente responsável fixo
```

Administrador técnico não opera a escala.

### Configuração

```text
/escala/configuracao
```

Autorizados:

```text
Gerente
Administrador
```

A configuração mantém:

```text
responsável fixo
participação na Escala GEDUC
carga 180H/240H
```

A identidade da pessoa continua em `equipe_operacional`.

## 3. Jornada

Códigos oficiais:

```text
normal
hora_extra
banco_horas
```

A segunda/posterior alocação não é automaticamente Hora Extra.

A classificação complementar é decisão explícita do responsável.

O Gerente pode transportar classificação já publicada em uma revisão apenas
com proveniência verificável; não pode inventar/reclassificar Hora Extra ou
Banco de Horas.

Não existe financeiro na ESC-001D.

## 4. Conferência do efetivo

A conferência usa pessoa única e identidade canônica prioritária.

```text
efetivo ativo GEDUC
versus
agentes alocados/indisponíveis
```

Sobreposição, férias, folga, compensação e ausência de situação são alertas
operacionais, não bloqueios automáticos de publicação.

## 5. Publicação e revisão

Fluxo consolidado:

```text
RASCUNHO
→ revisão da publicação
→ blockers estruturais
→ alertas operacionais
→ publicação
→ PUBLICADA v1
→ motivo obrigatório
→ RASCUNHO v2
→ republicação
→ PUBLICADA v2 + v1 ARQUIVADA
```

A versão publicada não é editada in-place.

Durante revisão, a Consulta continua priorizando a versão publicada e a
Gestão prioriza o rascunho em preparação.

## 6. Home

Atalhos consolidados conforme autorização:

```text
Escala GEDUC
Minha Escala
Gestão da Escala
Configuração da Escala
```

A mesma política de navegação é reutilizada por Home e rotas.

## 7. Segurança

A ESC-001D mantém:

```text
Gerente fora do ACL legado global
write mínimo por responsabilidade
delete negado nas coleções críticas
identidade operacional preservada
membroEquipeId/usuarioId preservados em update de perfil operacional
```

## 8. Normalização do formatador

No fechamento com Dart 3.12.2 e resolução de pacotes ativa, o formatador
oficial identificou doze arquivos que precisavam ser normalizados para o
formato corrente.

A D.7 admite esse delta exclusivamente como formatação:

```text
12 arquivos Dart
+ 3 artefatos de fechamento
= 15 arquivos versionados
```

Antes de staging, a D.7 cria uma worktree temporária destacada exatamente na
baseline, executa `flutter pub get` e o mesmo `dart format` sobre os mesmos
doze arquivos e compara o SHA-256 de cada resultado canônico com a worktree
D.7.

```text
baseline
→ flutter pub get
→ dart format
→ SHA-256 canônico
```

Os 12/12 hashes devem ser idênticos. Qualquer divergência interrompe o
fechamento. Assim, mudanças como vírgulas de formatação não geram falso
positivo e qualquer diferença além da saída oficial do formatador continua
fail-closed.

Nenhuma funcionalidade nova é introduzida.

## 9. Quality gates do fechamento

A D.7 deve provar novamente:

```text
dart format --output=none --set-exit-if-changed
flutter pub get
flutter test focado no módulo Escala
flutter test completo
flutter analyze
npm ci
npm run test:rules
git diff --check
escopo exato
CPB
commit
PR
6 Quality Gates
merge
sync main
cleanup
```

## 10. Fronteira para as próximas fases

A ESC-001D termina aqui.

Ficam fora dela:

```text
ESC-001E  Execução operacional
ESC-001F  Integração Escala → RAE
ESC-001G  PDF oficial
ESC-001H  Indicadores/Faixita
```

Storage/R2 e App Check não são alterados pela D.7.

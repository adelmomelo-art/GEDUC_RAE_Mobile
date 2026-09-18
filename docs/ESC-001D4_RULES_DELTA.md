# ESC-001D.4 — DELTA DE FIRESTORE RULES

Baseline: `97f7f331c82a845fbabac375610a5d0ecf110d57`

Alterações estritamente limitadas à Gestão da Escala:

1. `escala_alocacoes` pode ser excluída por responsável/Gerente somente quando
   a escala pai está em `rascunho`.
2. criação de `hora_extra` ou `banco_horas` exige agente responsável fixo.
3. alteração da classificação da jornada exige agente responsável fixo.
4. demais deletes permanecem negados.
5. nenhuma regra de Storage/R2/App Check é modificada.

A regra não consegue inferir "segunda alocação NORMAL" sem campo ordinal. Esse
caso é bloqueado pelo Controller D.4 quando o operador não é o agente
responsável.

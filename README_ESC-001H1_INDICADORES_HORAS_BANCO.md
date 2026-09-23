# ESC-001H.1 — Indicadores históricos e banco de horas

Esta etapa cria o núcleo determinístico que consolida horas operacionais de
escalas publicadas. Ela não cria tela, consulta ao Firestore nem cálculo
financeiro.

## Entregas

- consolidação por período inclusivo;
- separação entre jornada normal, hora extra e banco de horas;
- crédito de banco somente a partir de horas reais coerentes em alocação
  `banco_horas`;
- débito de banco somente a partir de indisponibilidade `compensacao` com
  intervalo válido;
- saldo total e saldo individual por pessoa;
- reconciliação de identidade por `usuarioId` e `membroEquipeId`;
- registros incompletos tratados como pendência, sem inferência de minutos;
- exclusão de rascunhos e dias fora do período.

## Invariantes

1. Somente escalas publicadas entram no histórico.
2. Horas planejadas e realizadas permanecem grandezas distintas.
3. Crédito e compensação não são convertidos em dinheiro.
4. Ausência de horário não equivale a zero hora realizada.
5. Dados inválidos não alteram o saldo e permanecem visíveis como pendência.
6. Pessoas com o mesmo nome não são agrupadas sem identidade compatível.

## Fora do escopo

- interface de indicadores;
- consultas históricas no repositório;
- produtividade e Faixita;
- upload de evidências;
- folha, remuneração, adicional ou qualquer outro cálculo financeiro;
- deploy, migração ou alteração de regras do Firebase.

Esses itens seguem para as próximas subetapas da ESC-001H, sempre preservando
o caráter exclusivamente operacional do controle de horas.

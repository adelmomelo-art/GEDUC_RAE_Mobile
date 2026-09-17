# ESC-001B — MATRIZ FUNCIONAL HOMOLOGADA

## Status

**HOMOLOGADA.**

Baseline de referência: `7578c5eafd53985c036d35eb5476bcb3a0009177`.

## Decisões finais

- `180H` / `240H` representam a carga horária do agente.
- Os horários associados a 180H/240H no documento são apenas informativos de cabeçalho e não criam bloqueios automáticos.
- `QTR` = horário.
- `QTH` = local.
- Existe um agente fixo responsável pela escala.
- O Gerente designa esse responsável.
- O agente responsável cria, edita, revisa e publica a escala.
- O Gerente revisa, altera e publica a escala e pode substituir o responsável.
- O agente comum visualiza a escala completa.
- “Minha Escala” continua útil como filtro pessoal, não como limitação de acesso.
- Férias, folga e compensação geram alerta informativo e não bloqueio.
- Sobreposição do mesmo agente em atividades simultâneas gera alerta e não bloqueio.
- Toda ação educativa gera RAE.
- Missões administrativas não geram RAE por padrão, mas contabilizam produtividade.
- O próprio agente participante pode registrar a conclusão de missão administrativa.
- Produtividade administrativa não mede horas reais no MVP.
- Missão administrativa pode possuir evidências.
- O Coordenador atua na execução da missão, não na gestão da escala.
- O Coordenador pode registrar execução, observações e evidências da atividade que coordena, mas não altera a estrutura planejada nem publica a escala.
- O termo `PD` não integra o modelo; foi removido por falta de definição funcional confirmada.

## Segurança

O perfil `gerente` permanece fora da função global `usuarioAtivo()` das regras legadas para não ampliar, por efeito colateral, acesso a RAEs e catálogos. ESC-001C cria uma identidade de escala específica que reconhece o Gerente apenas nas coleções do módulo Escala.

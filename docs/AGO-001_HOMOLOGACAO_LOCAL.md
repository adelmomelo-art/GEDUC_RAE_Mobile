# AGO-001 — homologação funcional web local (R7)

Projeto exclusivo: `demo-geduc-ago001-hml`. Auth 9099, Firestore 8080,
hub 4400, app `http://127.0.0.1:7351`. Java 21 e Node 24, Flutter/Chrome.
A entrada `lib/main_ago001_hml.dart` usa opções Firebase fictícias e conecta
os dois emuladores antes de construir o app. Bloqueia release, plataforma
nativa e outras origens. Não ativa App Check no emulador. Configuração
Firebase de produção e regras permanecem como na R4. A R6 inicializa
os símbolos de data antes de abrir a interface nas duas entradas; não
altera o locale padrão. O launcher resolve seu caminho após o bloco param,
compatível com a inicialização do PowerShell 5.1.

A porta/origem 7351 separa SharedPreferences da versão publicada. Auth e
Firestore não persistem sessão/cache nessa entrada. Não utilizar o comando
normal `flutter run` nesta rodada. Este pacote homologa o fluxo da agenda e
escala; uploads R2, evidências, envio de RAE e APK A05 não fazem parte dela.

## 1. Aplicar R7 e validar

Aplicar o pacote integral com `Aplicar-AGO001.ps1`, sobre a R6 não commitada.
O instalador aceita também uma base limpa no commit do manifesto.
Não reaplicar pacotes anteriores sobre arquivos já alterados manualmente.

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile_AGO001_WT
npm ci --strict-allow-scripts
npm run audit:security
flutter analyze
flutter test --no-pub
```

Usar um comando por vez e parar em caso de falha. O instalador confere
45 arquivos. Flutter pode alterar registrants; restaurar somente os sete
arquivos gerados listados no README, sem restaurar o trabalho da agenda.

## 2. Terminal A — manter aberto

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile_AGO001_WT
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ago001\Homologar-AGO001.ps1 -Etapa Emuladores
```

Aguardar Auth e Firestore iniciados. Não rodar outros testes de emulador
junto desta sessão. O launcher verifica as portas antes de iniciar.
Não exige `firebase login` nem credenciais de produção.

## 3. Terminal B — preparar, conferir e abrir

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile_AGO001_WT
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ago001\Homologar-AGO001.ps1 -Etapa Preparar
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ago001\Homologar-AGO001.ps1 -Etapa Testar
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\ago001\Homologar-AGO001.ps1 -Etapa App
```

Executar um comando por vez. O seed cria seis contas, três membros GEDUC,
perfis 180H, responsável designado, projeto e regional fictícios. Pode ser
repetido sem apagar ou sobrescrever documentos existentes. UID obtido do
Auth emulado; o script confere que o token pertence ao projeto demo correto.
O teste escreve um compromisso descartável com histórico e verifica os
bloqueios usando tokens de login reais. Limpa somente seu documento temporário.
A etapa App repete esse teste antes de abrir o Chrome.

## Contas locais

Senha para todas: **`Ago001-Hml-2026!`**. Não é uma senha de produção.

| E-mail | Papel nesta rodada |
| --- | --- |
| responsavel@ago001.example.test | Agente designado, pode acessar agenda e gerir escala |
| participante@ago001.example.test | Agente a alocar na escala, consulta informação operacional |
| externo@ago001.example.test | Agente sem alocação, não acessa agenda |
| gerente@ago001.example.test | Gerente com escopo, não acessa agenda privada |
| admin@ago001.example.test | Administrador, não acessa agenda privada |
| inativo@ago001.example.test | Identidade inativa, aplicativo bloqueado |

Use somente essas contas. O Chrome deve abrir em `http://127.0.0.1:7351`,
com a faixa **AGO-001 HML LOCAL** e indicação de homologação no login.
Se não houver faixa/origem correta, fechar essa janela e preservar o log.
Sair pelo menu do app antes de trocar de perfil; recarregar também descarta
a autenticação nesta entrada. Digitar os e-mails e senha nos campos do login.

## Roteiro funcional e evidências

Os testes automatizados são pré-requisito; os itens abaixo exigem conferência
manual. Registrar PASS/FAIL, mensagem exibida e captura quando necessário.

| Caso | Procedimento | Resultado esperado |
| --- | --- | --- |
| H01 | Responsável faz login e abre Agenda Operacional | Calendário mensal e botão Agendar ação |
| H02 | Criar hoje título HML Escola, turno manhã, demais campos a combinar | Salva planejamento; não cria escala automaticamente |
| H03 | Sair/entrar e consultar mês/dia/turno/pesquisa | Compromisso preservado, filtros coerentes |
| H04 | Abrir Editar; escolher Projeto Educativo HML, horários 08:00–10:00, local Escola HML e endereço Rua Fictícia, 100; contato, materiais e nota privada fictícios; orientação pública separada | Salva dados progressivos; Pronta para escala fica possível |
| H05 | Pronta para escala; gerar vínculo usando o botão de montagem exibido; repetir tentativa | Escala em rascunho criada com uma atividade; sem duplicação |
| H06 | Abrir escala; editar atividade, escolher responsável como coordenador e participante como integrante; salvar e conferir/publicar | Horários, coordenador, alocação e publicação consistentes |
| H07 | Participante entra; abre escala da mesma data | Recebe informações operacionais publicadas; contato, materiais e observações internas da agenda não aparecem |
| H08 | Participante, externo, gerente e admin tentam Agenda pelo atalho/rota `/agenda-operacional` | Acesso negado, mesmo ao tentar URL diretamente |
| H09 | Inativo tenta login | Página de acesso à conta bloqueia o uso operacional |
| H10 | Responsável tenta editar planejamento já vinculado a escala publicada | Versão publicada preservada; preparar revisão, aplicar planejamento atualizado e republicar conforme mensagens do app |
| H11 | Em outro compromisso ainda sem publicação, mudar data com motivo e consultar histórico | Remarcação preservada; dia antigo/novo corretos e histórico crescente |
| H12 | Cancelar outro compromisso com motivo; tentar escalar novamente | Cancelamento registrado, sem reabertura/escala; histórico preservado |
| H13 | Gerar PDF da escala publicada e comparar com a consulta | Mesma data/versão, horários e equipe; nenhum dado privado da agenda |
| H14 | Na escala publicada, iniciar revisão para cancelar/remarcar ação, registrar motivo, aplicar e publicar retirada antes de nova data | Versão anterior preservada; nova publicação retira a ação; vínculo não duplica |

Na conferência da escala, verificar também que o agente externo não foi
alocado involuntariamente e que QTR/QTH e horas planejadas correspondem
à atividade. Se houver bloqueio de publicação, registrar a mensagem e
corrigir o dado que o app solicitar; não afrouxar regras para homologar.

## Encerramento

Fechar app/Flutter com `q` no Terminal B e emuladores com Ctrl+C no A.
Sem exportação, os dados locais desta rodada não são preservados após o
encerramento dos emuladores. Registrar o resultado manual antes de encerrar.
Reiniciar exige novamente Preparar. Commit/push após homologação funcional;
merge, publicação das regras e build/instalação A05 são etapas posteriores.

Referências técnicas: https://firebase.google.com/docs/emulator-suite/connect_auth
https://firebase.google.com/docs/emulator-suite/connect_firestore

## R7 — correção da revisão com coordenador

A homologação encontrou PERMISSION_DENIED ao copiar a atividade da v1
para v2. A reprodução com coordenador e responsável designado mostrou
esgotamento do limite de 1.000 expressões. A R7 mantém a política de
autorização, avalia a identidade uma vez em podeAtualizarEscala e valida
o vínculo da cópia pela atividade de origem antes da alternativa privada.

Regressão inclui clone com coordenador/participante e agenda editada,
aplicação atômica na cópia, preservação da publicação anterior e bloqueios
de revisão/origem forjadas e agente sem designação. Dependências e Dart
não mudam da R6. Regras automatizadas: 83 testes.

### Retomar a tentativa local sem apagar os dados

Manter os emuladores abertos e encerrar somente Flutter com q. Aplicar
pacote R7 sobre R6; aguardar Change detected/Rules updated no Terminal A.
Se não houver confirmação de recarga, não repetir a publicação nem
encerrar os emuladores: preservar logs e investigar. Reabrir a etapa App
com RepoPath explícito. A nova versão em rascunho pode ter sido criada
antes da falha da cópia. Reabrir Gestão da Escala na mesma data; se houver
Retomar revisão, usar esse botão para completar a preparação. Não criar
outro motivo nem apagar v2. Se ainda aparecer Revisar escala, reutilizar
o motivo da tentativa original. Depois aplicar planejamento na agenda,
conferir e publicar. Fluxo confirmado PASS pelo usuário em 05/10/2026.

### Resultados manuais informados até 05/10/2026

PASS: login/calendário, cadastro e persistência, edição e prontidão,
vínculo e ausência de duplicação, publicação, informação ao participante,
privacidade na consulta, acesso restrito, remarcação, histórico, cancelamento,
bloqueio de montagem e PDF consistente/privado.
PASS adicional: preparação e aplicação da revisão, v2 sem duplicação,
republicação, orientação atualizada ao participante e PDF v2 consistente/privado;
preparação v3, remarcação/histórico, bloqueio antes da retirada e retirada
publicada (v3, zero agentes na captura).
Falha de montagem na nova data corrigida pela R8 e repetida pelo usuário:
PASS em 06/10/2026, rascunho v1, atividade única, horário/local preservados.
Aceite final do usuário em 05/10/2026 às 14:44 (America/Sao_Paulo):
"Reaplicação sem duplicação — PASS" e "Planejamento preservado — PASS".
H14 (remarcação com retirada publicada e montagem na nova data): PASS.
Homologação funcional web local H01–H14 concluída. Este aceite não constitui
validação Android/A05 nem publicação das regras em produção.

### AGO-001 R8 — montagem depois de remarcar

Novas atividades recebem ID por escala e compromisso. Atividades já vinculadas
mantêm seus IDs, incluindo os anteriores à R8; aplicação continua usando a
atividade existente. A remarcação não reutiliza nem sobrescreve o snapshot
antigo. Nenhuma alteração em regras, roles ou dependências.

Recuperação com os dados desta homologação:
1. Manter Terminal A (emuladores) aberto. Parar apenas Flutter no Terminal B com q.
2. Aplicar o pacote R8 integral sobre R7, em pasta de extração nova.
3. Reiniciar somente Etapa App. Entrar como responsável e abrir a ação de 06/10.
4. Montar escala. Conferir uma atividade, planejamento preservado e aplicar
   novamente para verificar ausência de duplicação. As versões antigas permanecem.
5. Se falhar, enviar o código exibido e o trecho AGO-001 do Console/Terminal B.
   O modo debug registra tipo/código e stack, sem mensagem da exceção ou dados privados.

### Sugestão de evolução do calendário — recebida em 05/10/2026

Pedido do usuário: mostrar o nome da ação no calendário e cores de semáforo:
verde agendada, vermelho cancelada, amarelo próxima de acontecer.
Proposta a detalhar após fechar AGO-001: manter o número do dia, título e
situação por ação (várias situações podem coexistir no mesmo dia), além da
cor. Limiar de proximidade ainda não definido pelo usuário; sugestão inicial
de três dias, pendente de decisão. Não implementada neste pacote de correção.

### AGO-001 R9 — consolidação do aceite

Atualização documental; Dart, regras e dependências idênticos à R8.
Evidências técnicas R8 preservadas: Analyze zero issues, Flutter 1.156 PASS,
regras 84 PASS e build web HML PASS. Sem repetir suites para esta alteração
documental. Próximas etapas: commit/push, CI remoto e revisão da entrega;
publicação das regras e atualização A05 continuam pendentes. O semáforo
no calendário permanece proposta para a próxima evolução, após esta entrega.

## Fechamento posterior — web de produção e A05

As pendências descritas acima pertencem às revisões históricas. Em 06/10/2026,
merge, CI remoto, publicação das regras, atualização web/A05 e homologação
funcional em ambos foram concluídos PASS. Registro consolidado em
[AGO-001](AGO-001_AGENDA_OPERACIONAL.md#fechamento-em-produção--06102026).

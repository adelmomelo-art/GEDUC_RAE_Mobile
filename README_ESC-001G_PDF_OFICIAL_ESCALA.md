# ESC-001G — PDF oficial da Escala GEDUC

O ESC-001G gera o documento oficial da programação a partir da versão
publicada da escala.

## Entrega

- botão `PDF oficial` na consulta da Escala GEDUC;
- documento A4 em orientação paisagem;
- identificação da data, versão e instante da publicação;
- atividades organizadas por seção;
- QTR, QTH, coordenação e orientação operacional;
- equipe completa com função, horário, jornada e horas planejadas;
- resumo de horas programadas por jornada;
- indisponibilidades do dia;
- fontes Unicode e identificação institucional;
- bloqueio para escala ausente ou ainda não publicada.

## Limite do documento

O PDF é um retrato da programação oficial publicada. Ele não inclui horas
realizadas, observações de execução, evidências, resultados de missão ou dados
do RAE. Esses registros são posteriores à publicação e permanecem nos fluxos
ESC-001E e ESC-001F.

Não existe cálculo monetário. Hora extra e banco de horas são classificações
operacionais de tempo.

## Validação

```powershell
flutter test test/modules/escala/services/escala_pdf_service_test.dart
flutter test test/modules/escala/pages/escala_page_test.dart
flutter test
flutter analyze
```

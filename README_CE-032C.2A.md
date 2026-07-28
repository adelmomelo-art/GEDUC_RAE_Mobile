# CE-032C.2A — Cache Persistente do Dashboard

## Objetivo

Persistir localmente os indicadores e os três últimos RAEs apresentados no Centro de Operação.

## Arquivos

- `lib/modules/home/models/home_cache_data.dart` — novo
- `lib/modules/home/services/home_persistent_cache.dart` — novo
- `lib/modules/home/services/home_loader_service.dart` — substituição completa
- `lib/modules/home/models/home_state.dart` — substituição completa
- `README_CE-032C.2A.md` — novo

## Comportamento

### Online

1. Consulta o Firebase.
2. Ordena os RAEs pela data da ação.
3. Mantém os três registros mais recentes.
4. Salva indicadores, RAEs e horário da atualização no SharedPreferences.
5. Entrega os dados online ao Centro de Operação.

### Offline ou timeout

1. Tenta recuperar o cache local.
2. Quando existe cache, entrega os dados anteriores e marca `dadosEmCache`.
3. Quando não existe cache, informa que ainda não há dados anteriores no dispositivo.

## Escopo

A CE-032C.2A cria a persistência e disponibiliza os metadados no estado. A exibição visual da origem e do horário será implementada na CE-032C.2C.

## Instalação

Copie os arquivos para os caminhos indicados, preservando a estrutura de pastas.

## Validação

```powershell
dart format lib/modules/home
flutter analyze
```

## Teste funcional

1. Abrir o Centro de Operação com internet.
2. Confirmar indicadores e últimos RAEs.
3. Fechar o aplicativo.
4. Desativar a internet.
5. Abrir novamente.
6. Confirmar a recuperação dos mesmos indicadores e RAEs.
7. Reconectar e atualizar.
8. Confirmar que o cache recebe os dados mais recentes.

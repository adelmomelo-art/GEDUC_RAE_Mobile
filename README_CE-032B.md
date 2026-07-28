# CE-032B — Persistência Offline dos Domínios

## Objetivo

Adicionar persistência local à Central de Domínios da Plataforma Fênix, mantendo o Firestore como fonte oficial e o cache em memória da CE-032A-1.

## Arquitetura em camadas

1. **Cache em memória — 10 minutos**
   - resposta imediata durante a sessão;
   - implementado pela CE-032A-1.

2. **Cache persistente — 24 horas**
   - armazenado com `SharedPreferences`;
   - permanece disponível após fechar e reabrir o aplicativo;
   - evita consulta remota quando ainda válido.

3. **Contingência — retenção máxima de 30 dias**
   - quando o cache persistente passou de 24 horas, o sistema tenta atualizar pelo Firestore;
   - se o Firestore falhar, os dados locais ainda podem ser utilizados;
   - o grupo é marcado como desatualizado e o erro permanece disponível no Provider.

4. **Firestore**
   - continua sendo a fonte oficial;
   - toda leitura remota bem-sucedida atualiza os dois caches.

## Arquivos

Novo:

- `lib/core/domains/domain_persistent_cache.dart`

Substituir:

- `lib/core/domains/domain_provider.dart`

## Dependência

A implementação utiliza `shared_preferences`, já empregado pela Plataforma Fênix no serviço offline. Não deve ser adicionada uma segunda biblioteca de persistência nesta fase.

## Comportamentos preservados

- API anterior do `DomainProvider`;
- cache inteligente da CE-032A-1;
- Futures compartilhadas;
- proteção contra respostas assíncronas antigas;
- valores legados;
- fallback de cache expirado;
- widgets homologados pela CE-032A-2.

## Novas APIs

```dart
Future<Duration?> idadeDoCachePersistente(String grupo)
```

```dart
void invalidarGrupo(
  String grupo, {
  bool notificar = true,
  bool invalidarPersistencia = true,
})
```

```dart
Future<void> limpar({
  bool limparCacheDoServico = false,
  bool limparCachePersistente = true,
})
```

## Instalação

Extraia o ZIP na raiz:

```text
C:\Projetos\GEDUC_RAE_Mobile
```

## Validação técnica

```powershell
dart format lib/core/domains/domain_persistent_cache.dart lib/core/domains/domain_provider.dart

flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Homologação funcional

### Preparação online

1. Execute o aplicativo com internet.
2. Acesse `Nova Ação → Caracterização da Ação`.
3. Abra:
   - Formação;
   - Público;
   - Sexo predominante;
   - Mudança de comportamento.
4. Confirme que as opções aparecem.
5. Feche completamente o aplicativo.

### Teste offline após reinício

1. Desative a internet do computador.
2. Inicie novamente:
   ```powershell
   flutter run -d chrome
   ```
3. Acesse novamente `Caracterização da Ação`.
4. Abra os quatro campos.

Resultado esperado:

- listas disponíveis;
- seleções funcionando;
- nenhum loading infinito;
- nenhum erro impeditivo;
- dados recuperados do cache persistente.

### Retorno online

1. Reative a internet.
2. Reinicie o aplicativo.
3. Abra os campos novamente.

Resultado esperado:

- funcionamento normal;
- nenhuma duplicação;
- nenhuma perda das opções ou seleções.

## Observação para Flutter Web

O `SharedPreferences` utiliza o armazenamento local do navegador. O teste deve ser feito no mesmo navegador e no mesmo perfil. Limpar os dados do site também remove o cache persistente.

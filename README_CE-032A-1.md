# Plataforma Fênix — CE-032A-1

## Inteligência de Cache do Motor de Domínios

### Arquivos para substituir

1. `lib/core/domains/domain_cache.dart`
2. `lib/core/domains/domain_provider.dart`

### Correções estruturais

- TTL passa a ser efetivamente respeitado pelo `DomainProvider`.
- Requisições simultâneas para o mesmo grupo compartilham a mesma `Future`.
- Valores legados deixam de impedir o carregamento remoto.
- Cache expirado pode ser usado como fallback quando o Firestore falhar.
- Invalidação durante uma consulta impede que uma resposta antiga repovoe o estado.
- API pública anterior foi preservada.
- Foram adicionados:
  - `possuiDadosDesatualizados(grupo)`
  - `idadeDoCache(grupo)`
  - `DomainCacheEntry`
  - `obterMesmoExpirado(grupo)`
  - `limparExpirados()`

## Instalação

Copie a pasta `lib` deste pacote para a raiz do projeto e confirme a substituição dos dois arquivos.

## Validação técnica

Execute, na raiz do projeto:

```powershell
dart format lib/core/domains/domain_cache.dart lib/core/domains/domain_provider.dart
flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Homologação funcional prevista

1. Abrir uma tela com `DomainDropdown`.
2. Confirmar o carregamento normal das opções.
3. Abrir outra tela que use o mesmo grupo e confirmar ausência de novo loading perceptível.
4. Testar um registro com valor legado.
5. Confirmar que o valor legado aparece sem impedir as opções atuais.
6. Usar atualizar/recarregar e confirmar nova leitura.
7. Fechar e reabrir a tela dentro de 10 minutos e confirmar uso do cache.

# ISSUE-002A.2 — Integração do DomainService

## Conteúdo do pacote

### Arquivo para substituição

- `lib/core/services/domain_service.dart`

### Documento arquitetural

- `docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md`

## Resultado

O `DomainService` deixa de armazenar os domínios em uma lista em memória
e passa a delegar todas as operações ao `DomainDataSource`.

A implementação padrão é o `FirestoreDomainDataSource`, criado na
ISSUE-002A.1.

## Instalação

Extraia o pacote na raiz do projeto, preservando a estrutura de pastas e
substituindo o arquivo existente quando solicitado.

## Validação técnica

Execute:

```powershell
flutter analyze
git status
```

Resultado esperado do analisador:

```text
No issues found!
```

## Homologação funcional

Abra a Central de Domínios Administráveis e verifique:

1. a tela carrega sem erro;
2. os domínios aparecem normalmente;
3. a coleção `domains` é criada/preenchida no Firestore;
4. alterar o status de um domínio atualiza a interface;
5. recarregar a tela preserva o novo status.

## Commit após homologação

```powershell
git add lib/core/services/domain_service.dart `
        docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md `
        README_ISSUE-002A.2.md

git commit -m "feat(domain): integra DomainService ao Firestore (ISSUE-002A.2)"

git push

git status
```

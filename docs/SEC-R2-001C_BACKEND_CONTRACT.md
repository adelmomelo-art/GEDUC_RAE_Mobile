# SEC-R2-001C - Contrato Cliente / Backend de Evidencias

## Estado

Esta etapa fecha o contrato entre o aplicativo Flutter e o futuro backend autorizador de evidencias.

Cloudflare R2 continua nao habilitado.

remoteStorageEnabled permanece false.

Nenhuma credencial de R2 pode existir no APK.

## Endpoint de upload

POST /v1/evidencias/upload-grant

## Autenticacao

O backend devera autenticar o usuario chamador por token Firebase Auth.

App Check devera ser validado quando o enforcement produtivo for autorizado.

O backend nunca deve confiar em perfil, escopo ou ACL enviados pelo cliente.

## Request logico

- acaoId
- evidenciaId
- autorUserId
- contentType
- tamanhoBytes
- sha256

O cliente NAO envia objectKey.

## Validacoes obrigatorias server-side

O backend devera:

1. validar autenticacao;
2. validar usuario ativo;
3. carregar o RAE pelo acaoId;
4. validar ACL do usuario sobre o RAE;
5. validar aclClassificacaoCompleta;
6. validar responsavel, coordenador, regional, equipe e projeto;
7. validar escopo do Gerente quando aplicavel;
8. validar autorUserId;
9. validar contentType;
10. validar tamanhoBytes;
11. validar SHA-256;
12. aplicar limites operacionais de upload;
13. calcular objectKey autoritativa;
14. emitir URL temporaria;
15. nunca retornar credenciais permanentes.

## Identidade idempotente

Identidade logica:

acaoId + evidenciaId + sha256

Chave logica:

evidence-upload-v1:{acaoId}:{evidenciaId}:{sha256}

Para a mesma identidade o backend devera retornar sempre a mesma objectKey.

## Object key

Formato recomendado:

evidencias/v1/{acaoId}/{evidenciaId}/{sha256}.{ext}

A extensao devera ser derivada pelo backend a partir do MIME permitido.

A objectKey nunca e autoridade do cliente.

## Response logica

O backend devera retornar:

- uri HTTPS temporaria;
- operation = upload;
- expiresAt;
- objectKey autoritativa;
- requiredHeaders, incluindo Content-Type;
- uploadIdentity com acaoId, evidenciaId e sha256.

## Autor da evidencia

autorUserId identifica o usuario que originou ou capturou a evidencia.

Ele nao substitui a identidade autenticada do usuario que solicita o grant.

O backend devera registrar ambos quando forem diferentes.

## Invariantes

- armazenamento local continua obrigatorio;
- original local permanece preservado;
- URL assinada fica somente em memoria;
- nenhum segredo de provedor no cliente;
- nenhum objectKey arbitrario vindo do cliente;
- retry nao pode criar nova identidade remota;
- mudanca de SHA representa novo snapshot;
- remoteStorageEnabled=true permanece proibido nesta etapa.

## Proxima etapa

SEC-R2-002A - backend autorizador real e bucket Cloudflare R2 privado.

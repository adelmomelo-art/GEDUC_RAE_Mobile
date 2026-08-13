# Escopo de publicação — saneamento territorial pós-CIO Lote 4

## Objetivo

Definir o conjunto revisado de arquivos aptos a compor o commit documental do
ciclo territorial, sem incluir dados operacionais, backups, coordenadas
individuais, artefatos de homologação ou ferramentas de escrita em produção.

## Arquivos publicáveis

### Governança e rastreabilidade

- `AUDITORIA_RECONSTRUCAO-CATALOGO-TERRITORIAL_LC307.md`;
- `BLUEPRINT_RECONSTRUCAO-CATALOGO-TERRITORIAL_LC307.md`;
- `PLANO_SANEAMENTO-TERRITORIAL-POS-LOTE-4.md`;
- `TERMO_ENCERRAMENTO-SANEAMENTO-TERRITORIAL-POS-LOTE-4.md`;
- `README_CIO-LOTE-4-HOMOLOGADO.md`;
- `tools/manifestos/CIO-LOTE-4-HOMOLOGADO.txt`.

### Matrizes, diagnóstico e simulação

- `DIAGNOSTICO_SANEAMENTO-TERRITORIAL_ETAPA-1.md`;
- `MAPEAMENTO_IDS-REGIONAIS_CATALOGO-LC307.md`;
- `MATRIZ_CATALOGO-TERRITORIAL_FORTALEZA_LC307.md`;
- `MATRIZ_HOMOLOGACAO-DIVERGENCIAS-GEOMETRICAS.md`;
- `MATRIZ_INSTITUCIONAL_SANEAMENTO-TERRITORIAL_LOTE-B.md`;
- `MATRIZ_REINICIO-SANEAMENTO-RAES_LC307.md`;
- `MATRIZ_RESTRITA_SANEAMENTO-TERRITORIAL_LOTE-A.md`;
- `SIMULACAO_RECONSTRUCAO-CATALOGO-TERRITORIAL_LC307.md`.

### Resultados e evidências públicas

- `RESULTADO_RECONSTRUCAO-CATALOGO-TERRITORIAL_LC307.md`;
- `RESULTADO_SANEAMENTO-RAES_LC307.md`;
- `RESULTADO_SANEAMENTO-TERRITORIAL_LOTE-A.md`;
- `VALIDACAO_GEOMETRICA-RAES_IPLANFOR.md`;
- `docs/catalogo_territorial_fortaleza_lc307.csv`;
- `tools/gerar_matriz_catalogo_territorial.ps1`;
- `tools/gerar_relatorio_catalogo_territorial.js`.

### Proteção do repositório

- `.gitignore`, com exclusão explícita de `/work/`.

## Arquivos obrigatoriamente locais

Todo o conteúdo de `work/` fica fora do Git, incluindo:

- backups brutos do Firestore;
- planos de escrita e arquivos com versões dos documentos;
- scripts que autenticam e escrevem diretamente em produção;
- arquivos com coordenadas e geometrias de trabalho;
- APK de homologação;
- rascunhos de PR e relatórios temporários.

Esses arquivos não devem ser adicionados com opção de inclusão forçada.

## Verificações realizadas

- nenhum padrão de credencial ou chave privada encontrado nos candidatos;
- catálogo CSV com 121 linhas, 121 bairros únicos e 12 Regionais;
- sintaxe do gerador JavaScript aprovada;
- integridade textual aprovada por `git diff --check`;
- `work/` confirmado como ignorado pelo Git;
- nenhum arquivo de aplicação, regra do Firestore ou dependência foi alterado.

## Estado

Escopo apto para revisão e commit documental. Commit, push e pull request
dependem de autorização específica.

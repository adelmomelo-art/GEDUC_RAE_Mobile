# BUG-ADMIN-ESCOPO-R1 - Salvar Escopo

Correcao isolada para permission-denied ao salvar o escopo de outro usuario.

## Causa

O administrador podia listar usuarios, mas a transacao executava um get no
usuario alvo. As Rules permitiam esse get apenas ao proprio usuario, bloqueando
a transacao antes do update.

## Correcao

O administrador passa a poder executar get individual em usuarios. Gestor e
demais perfis continuam impedidos. O update permanece limitado aos campos de
escopo e exige scopeUpdatedBy igual ao UID autenticado.

Este pacote nao publica Rules. Producao exige homologacao, fechamento Git e
autorizacao explicita posterior.
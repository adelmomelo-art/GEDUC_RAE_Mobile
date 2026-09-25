# UX-ESCALA-R1 - Refinamentos pos-homologacao

Pacote visual fechado apos homologacao produtiva da Escala GEDUC.

## Alteracoes

- remove o quadro geral "Jornadas de referencia" das visoes Escala completa e Minha Escala;
- preserva o carimbo `PUBLICADA - vN` e todos os dados operacionais;
- remove da Home o atalho redundante "Minha Escala";
- mantem "Minha Escala" como filtro dentro da tela Escala GEDUC;
- preserva a rota `/escala?minha=1` para compatibilidade.

## Invariantes

Nao altera modelos, calculos, QTR, QTH, horas, banco, PDF, Firestore, Rules,
permissoes, documentos publicados ou financeiro.

O defeito de atualizacao do escopo de usuario e tratado separadamente.
# CPB — ChatGPT Package Builder

Versão 1.0.0

O CPB gera pacotes ZIP de arquivos do projeto a partir de manifestos versionados. Preserva a estrutura de diretórios, valida os arquivos e pode incluir informações do Git e o resultado do `flutter analyze`.

## Uso

Na raiz do projeto:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 HOTFIX-001
```

Com Git:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 HOTFIX-001 -Git
```

Com Flutter Analyze:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 HOTFIX-001 -Analyze
```

Pacote completo:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 HOTFIX-001 -Full
```

## Manifestos

Cada linha contém um caminho relativo à raiz do projeto. Linhas vazias e iniciadas por `#` são ignoradas.

## Segurança

- Não gera o ZIP se algum arquivo estiver ausente.
- Não gera o ZIP se `flutter analyze` falhar com `-Analyze` ou `-Full`.
- Inclui o manifesto e o relatório de geração no pacote.
- Remove duplicidades do manifesto.

## Git

Adicionar ao `.gitignore`:

```gitignore
# CPB - artefatos gerados
tools/output/*
!tools/output/.gitkeep
```

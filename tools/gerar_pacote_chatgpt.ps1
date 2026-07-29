param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Pacote,

    [switch]$Analyze,
    [switch]$Git,
    [switch]$Full
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 64) -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ("=" * 64) -ForegroundColor DarkGray
}

try {
    $scriptPath = $MyInvocation.MyCommand.Path
    $toolsDir = Split-Path -Parent $scriptPath
    $projectRoot = Split-Path -Parent $toolsDir

    $manifestDir = Join-Path $toolsDir "manifestos"
    $outputDir = Join-Path $toolsDir "output"
    $manifestPath = Join-Path $manifestDir "$Pacote.txt"

    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Manifesto não encontrado: $manifestPath"
    }

    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $safePackageName = ($Pacote -replace '[^a-zA-Z0-9._-]', '_')
    $workDir = Join-Path $env:TEMP "CPB_${safePackageName}_$timestamp"
    $packageRoot = Join-Path $workDir $safePackageName
    $zipPath = Join-Path $outputDir "${safePackageName}_$timestamp.zip"

    if (Test-Path -LiteralPath $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

    $manifestLines = Get-Content -LiteralPath $manifestPath -Encoding utf8
    $files = @(
        $manifestLines |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and -not $_.StartsWith("#") } |
            Select-Object -Unique
    )

    if ($files.Count -eq 0) {
        throw "O manifesto está vazio: $manifestPath"
    }

    $included = New-Object System.Collections.Generic.List[string]
    $missing = New-Object System.Collections.Generic.List[string]
    $commandFailures = New-Object System.Collections.Generic.List[string]

    Write-Section "CPB - ChatGPT Package Builder"
    Write-Host "Pacote........: $Pacote"
    Write-Host "Projeto.......: $projectRoot"
    Write-Host "Manifesto.....: $manifestPath"
    Write-Host "Arquivos......: $($files.Count)"

    foreach ($relativePath in $files) {
        $normalizedRelativePath = $relativePath -replace '/', [IO.Path]::DirectorySeparatorChar
        $sourcePath = Join-Path $projectRoot $normalizedRelativePath

        if (Test-Path -LiteralPath $sourcePath -PathType Leaf) {
            $destinationPath = Join-Path $packageRoot $normalizedRelativePath
            $destinationDir = Split-Path -Parent $destinationPath
            New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
            Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
            $included.Add($relativePath)
            Write-Host "[OK] $relativePath" -ForegroundColor Green
        }
        else {
            $missing.Add($relativePath)
            Write-Host "[AUSENTE] $relativePath" -ForegroundColor Red
        }
    }

    Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $packageRoot "manifesto_utilizado.txt") -Force

    $collectGit = $Git -or $Full
    $collectAnalyze = $Analyze -or $Full

    if ($collectGit) {
        Write-Section "Coletando informações do Git"
        Push-Location $projectRoot
        try {
            git status 2>&1 | Out-File (Join-Path $packageRoot "git_status.txt") -Encoding utf8
            if ($LASTEXITCODE -ne 0) { $commandFailures.Add("git status") }
            git branch --show-current 2>&1 | Out-File (Join-Path $packageRoot "git_branch.txt") -Encoding utf8
            if ($LASTEXITCODE -ne 0) { $commandFailures.Add("git branch --show-current") }
            git log -1 --decorate --stat 2>&1 | Out-File (Join-Path $packageRoot "git_last_commit.txt") -Encoding utf8
            if ($LASTEXITCODE -ne 0) { $commandFailures.Add("git log -1") }
        }
        finally { Pop-Location }
    }

    if ($collectAnalyze) {
        Write-Section "Executando flutter analyze"
        Push-Location $projectRoot
        try {
            flutter analyze 2>&1 | Tee-Object -FilePath (Join-Path $packageRoot "flutter_analyze.txt")
            if ($LASTEXITCODE -ne 0) { $commandFailures.Add("flutter analyze") }
        }
        finally { Pop-Location }
    }

    $report = @(
        "CPB - ChatGPT Package Builder"
        "Versão: 1.0.0"
        "Pacote: $Pacote"
        "Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
        "Projeto: $projectRoot"
        "Manifesto: $manifestPath"
        ""
        "Arquivos solicitados: $($files.Count)"
        "Arquivos incluídos: $($included.Count)"
        "Arquivos ausentes: $($missing.Count)"
        ""
        "INCLUÍDOS:"
        ($included | ForEach-Object { "- $_" })
        ""
        "AUSENTES:"
        $(if ($missing.Count -eq 0) { "- Nenhum" } else { $missing | ForEach-Object { "- $_" } })
        ""
        "COMANDOS COM FALHA:"
        $(if ($commandFailures.Count -eq 0) { "- Nenhum" } else { $commandFailures | ForEach-Object { "- $_" } })
    )
    $report | Out-File -LiteralPath (Join-Path $packageRoot "relatorio_geracao.txt") -Encoding utf8

    if ($missing.Count -gt 0) {
        Write-Section "Pacote não gerado"
        Write-Host "Existem arquivos ausentes no manifesto." -ForegroundColor Red
        Write-Host "Pasta temporária: $workDir" -ForegroundColor Yellow
        exit 2
    }

    if ($commandFailures.Count -gt 0) {
        Write-Section "Pacote não gerado"
        Write-Host "Um ou mais comandos de validação falharam." -ForegroundColor Red
        Write-Host "Pasta temporária: $workDir" -ForegroundColor Yellow
        exit 3
    }

    Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -CompressionLevel Optimal

    Write-Section "PACOTE GERADO COM SUCESSO"
    Write-Host "Pacote........: $Pacote" -ForegroundColor Green
    Write-Host "Incluídos.....: $($included.Count)" -ForegroundColor Green
    Write-Host "Ausentes......: $($missing.Count)" -ForegroundColor Green
    Write-Host "Destino.......: $zipPath" -ForegroundColor Cyan

    Remove-Item -LiteralPath $workDir -Recurse -Force
    exit 0
}
catch {
    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

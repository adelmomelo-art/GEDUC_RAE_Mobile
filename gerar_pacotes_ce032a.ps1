# ============================================================
# PLATAFORMA FÊNIX
# Gerador automático dos pacotes da Sprint CE-032A
#
# Salvar este arquivo na raiz do projeto, ao lado do pubspec.yaml.
# ============================================================

$ErrorActionPreference = "Stop"

# A raiz do projeto será automaticamente a pasta deste script.
$Projeto = $PSScriptRoot

# Pasta onde os ZIPs serão gerados.
$Saida = Join-Path $Projeto "pacotes_ce032a"

# Pasta temporária usada para preservar a estrutura dos arquivos.
$Temporario = Join-Path $env:TEMP "plataforma_fenix_ce032a"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " PLATAFORMA FÊNIX - GERADOR CE-032A" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# Validação da raiz do projeto
# ------------------------------------------------------------

$Pubspec = Join-Path $Projeto "pubspec.yaml"

if (-not (Test-Path $Pubspec)) {
    Write-Host "ERRO: pubspec.yaml não encontrado." -ForegroundColor Red
    Write-Host ""
    Write-Host "Salve este script na raiz do projeto Flutter," -ForegroundColor Yellow
    Write-Host "no mesmo local onde está o pubspec.yaml." -ForegroundColor Yellow
    exit 1
}

Write-Host "Projeto localizado em:" -ForegroundColor Green
Write-Host $Projeto
Write-Host ""

# ------------------------------------------------------------
# Limpeza das pastas anteriores
# ------------------------------------------------------------

if (Test-Path $Temporario) {
    Remove-Item $Temporario -Recurse -Force
}

if (-not (Test-Path $Saida)) {
    New-Item -ItemType Directory -Path $Saida | Out-Null
}

# ------------------------------------------------------------
# Definição dos pacotes
# ------------------------------------------------------------

$Pacotes = @(
    @{
        Nome = "CE-032A_01_CORE_DOMAINS.zip"
        Arquivos = @(
            "lib\core\domains\domain_provider.dart",
            "lib\core\domains\domain_cache.dart",
            "lib\core\domains\domain_groups.dart",
            "lib\core\domains\domain_extensions.dart"
        )
    },
    @{
        Nome = "CE-032A_02_PERSISTENCIA.zip"
        Arquivos = @(
            "lib\core\services\domain_service.dart",
            "lib\repositories\domain_repository.dart",
            "lib\data\models\domain_model.dart",
            "lib\data\datasources\domain_data_source.dart",
            "lib\data\datasources\firestore_domain_data_source.dart"
        )
    },
    @{
        Nome = "CE-032A_03_WIDGETS.zip"
        Arquivos = @(
            "lib\shared\widgets\domain\domain_dropdown.dart",
            "lib\shared\widgets\domain\domain_radio_group.dart",
            "lib\shared\widgets\domain\domain_checkbox_group.dart"
        )
    }
)

$ErrosEncontrados = $false

# ------------------------------------------------------------
# Criação de cada pacote
# ------------------------------------------------------------

foreach ($Pacote in $Pacotes) {

    $NomeZip = $Pacote.Nome
    $PastaPacote = Join-Path $Temporario `
        ([System.IO.Path]::GetFileNameWithoutExtension($NomeZip))

    Write-Host "Preparando: $NomeZip" -ForegroundColor Cyan

    New-Item -ItemType Directory -Path $PastaPacote -Force | Out-Null

    foreach ($ArquivoRelativo in $Pacote.Arquivos) {

        $ArquivoOrigem = Join-Path $Projeto $ArquivoRelativo

        if (-not (Test-Path $ArquivoOrigem)) {
            Write-Host "  AUSENTE: $ArquivoRelativo" -ForegroundColor Red
            $ErrosEncontrados = $true
            continue
        }

        $ArquivoDestino = Join-Path $PastaPacote $ArquivoRelativo
        $PastaDestino = Split-Path $ArquivoDestino -Parent

        if (-not (Test-Path $PastaDestino)) {
            New-Item -ItemType Directory `
                -Path $PastaDestino `
                -Force | Out-Null
        }

        Copy-Item `
            -Path $ArquivoOrigem `
            -Destination $ArquivoDestino `
            -Force

        Write-Host "  COPIADO: $ArquivoRelativo" -ForegroundColor Green
    }

    if ($ErrosEncontrados) {
        Write-Host ""
        Write-Host "O ZIP $NomeZip não foi criado porque existem arquivos ausentes." `
            -ForegroundColor Yellow
        Write-Host ""
        break
    }

    $CaminhoZip = Join-Path $Saida $NomeZip

    if (Test-Path $CaminhoZip) {
        Remove-Item $CaminhoZip -Force
    }

    Compress-Archive `
        -Path (Join-Path $PastaPacote "*") `
        -DestinationPath $CaminhoZip `
        -CompressionLevel Optimal `
        -Force

    Write-Host "  ZIP CRIADO: $CaminhoZip" -ForegroundColor Green
    Write-Host ""
}

# ------------------------------------------------------------
# Finalização
# ------------------------------------------------------------

if ($ErrosEncontrados) {
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " PROCESSO INTERROMPIDO" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Revise os caminhos dos arquivos indicados como AUSENTE." `
        -ForegroundColor Yellow

    if (Test-Path $Temporario) {
        Remove-Item $Temporario -Recurse -Force
    }

    exit 1
}

if (Test-Path $Temporario) {
    Remove-Item $Temporario -Recurse -Force
}

Write-Host "============================================" -ForegroundColor Green
Write-Host " PACOTES CE-032A GERADOS COM SUCESSO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Os arquivos estão em:" -ForegroundColor Cyan
Write-Host $Saida
Write-Host ""

# Abre automaticamente a pasta dos ZIPs no Windows Explorer.
Start-Process explorer.exe $Saida
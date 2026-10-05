param(
    [Parameter(Mandatory=$true)][ValidateSet('Emuladores','Preparar','Testar','App')][string]$Etapa,
    [string]$RepoPath
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoPath)) {
    $launcherDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoPath = Split-Path -Parent (Split-Path -Parent $launcherDirectory)
}
Set-Location -LiteralPath $RepoPath
foreach ($path in @('package-lock.json','firebase.ago001-hml.json','lib/main_ago001_hml.dart','tools/ago001/hml.cjs')) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Arquivo ausente: $path" }
}
$env:CI = 'true'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'
function Check-Exit {
    if ($LASTEXITCODE -ne 0) { throw "Etapa $Etapa falhou. Preserve o log." }
}
switch ($Etapa) {
    'Emuladores' {
        & java -version
        Check-Exit
        $listeners = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
        foreach ($port in @(4400,8080,9099)) {
            if (@($listeners | Where-Object { $_.Port -eq $port }).Count -ne 0) {
                throw "Porta $port ocupada. Encerre o emulador anterior."
            }
        }
        & .\node_modules\.bin\firebase.cmd emulators:start --only auth,firestore --project demo-geduc-ago001-hml --config firebase.ago001-hml.json
        Check-Exit
    }
    'Preparar' {
        & node tools/ago001/hml.cjs seed
        Check-Exit
    }
    'Testar' {
        & node tools/ago001/hml.cjs smoke
        Check-Exit
    }
    'App' {
        & node tools/ago001/hml.cjs smoke
        Check-Exit
        & flutter run -d chrome -t lib/main_ago001_hml.dart --web-hostname 127.0.0.1 --web-port 7351 --dart-define=APP_ENV=homologacao
        Check-Exit
    }
}

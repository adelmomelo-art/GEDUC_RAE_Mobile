param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [string]$OutputCsv = "docs\catalogo_territorial_fortaleza_lc307.csv",
  [string]$OutputMarkdown = "MATRIZ_CATALOGO-TERRITORIAL_FORTALEZA_LC307.md"
)

$ErrorActionPreference = 'Stop'
$ExpectedSourceSha256 = '4AC3848EDAD45BF567A6D7513953B220D0BBD351360767EC04CDBDB19AAD08A3'
$SourcePage = 'https://mapas.fortaleza.ce.gov.br/mapa/21/bairros-de-fortaleza'

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
  throw "Fonte não encontrada: $Source. Obtenha o CSV em $SourcePage"
}
$actualSourceSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash
if ($actualSourceSha256 -ne $ExpectedSourceSha256) {
  throw "SHA-256 da fonte divergiu. Esperado: $ExpectedSourceSha256; obtido: $actualSourceSha256. Fonte oficial: $SourcePage"
}
$rows = Import-Csv -LiteralPath $Source -Encoding UTF8

$expectedTerritories = @{
  1 = 12
  2 = 1; 3 = 1; 4 = 1; 5 = 1; 6 = 1
  7 = 2; 8 = 2; 9 = 2; 10 = 2
  11 = 3; 12 = 3; 13 = 3; 14 = 3
  15 = 4; 16 = 4; 17 = 4; 18 = 4
  19 = 8; 20 = 8; 21 = 8
  22 = 7; 23 = 7; 24 = 7; 25 = 7
  26 = 6; 27 = 6; 28 = 6; 29 = 6; 30 = 6
  31 = 9; 32 = 9; 33 = 9
  34 = 10; 35 = 10
  36 = 11; 37 = 11; 38 = 11
  39 = 5
}

$catalog = foreach ($row in $rows) {
  $values = @($row.PSObject.Properties.Value)
  $regionalText = $values[8]
  if ($regionalText -notmatch '(\d+)$') {
    throw "Regional inválida para $($values[3]): $regionalText"
  }
  $regional = [int]$Matches[1]
  $territory = [int]$values[10]
  if ($expectedTerritories[$territory] -ne $regional) {
    throw "Divergência LC 307: território $territory / SER $regional / $($values[3])"
  }
  [pscustomobject]@{
    codigo_bairro = [int]$values[5]
    codigo_ibge = $values[4]
    bairro = $values[3].Trim()
    regional = "SER $($regional.ToString('00'))"
    codigo_regiao = $values[9]
    territorio = $territory
    fonte = 'IPLANFOR - Bairros de Fortaleza / LC 307-2021'
    vigencia_referencia = '2021-12-13'
  }
}

$catalog = @($catalog | Sort-Object @{Expression={ [int]($_.regional -replace '\D','') }}, territorio, bairro)
$normalized = $catalog | ForEach-Object {
  $_.bairro.Normalize([Text.NormalizationForm]::FormD).ToLowerInvariant() -replace '\p{Mn}','' -replace '\s+',' '
}
$errors = @()
if ($catalog.Count -ne 121) { $errors += "Esperado 121 bairros; obtido $($catalog.Count)" }
if (($catalog.regional | Sort-Object -Unique).Count -ne 12) { $errors += 'Quantidade de regionais diferente de 12' }
if (($catalog.territorio | Sort-Object -Unique).Count -ne 39) { $errors += 'Quantidade de territórios diferente de 39' }
if (($catalog.codigo_bairro | Sort-Object -Unique).Count -ne 121) { $errors += 'Código de bairro duplicado' }
if (($normalized | Sort-Object -Unique).Count -ne 121) { $errors += 'Nome normalizado de bairro duplicado' }
if ($errors.Count) { throw ($errors -join '; ') }

$parent = Split-Path -Parent $OutputCsv
if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$catalog | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8

$lines = [Collections.Generic.List[string]]::new()
$lines.Add('# Matriz oficial do catálogo territorial de Fortaleza — LC nº 307/2021')
$lines.Add('')
$lines.Add('Fonte cadastral: IPLANFOR, conjunto “Bairros de Fortaleza”, com validação território–Regional contra o anexo da Lei Complementar nº 307/2021.')
$lines.Add('')
$lines.Add('## Portões estruturais')
$lines.Add('')
$lines.Add('- 121 bairros e 121 códigos únicos;')
$lines.Add('- 12 Secretarias Executivas Regionais;')
$lines.Add('- 39 territórios;')
$lines.Add('- zero bairros duplicados por nome normalizado;')
$lines.Add('- 100% dos territórios compatíveis com a LC nº 307/2021.')
$lines.Add('')
foreach ($regionalGroup in ($catalog | Group-Object regional)) {
  $lines.Add("## $($regionalGroup.Name)")
  $lines.Add('')
  $lines.Add('| Território | Código bairro | Bairro | Código da região |')
  $lines.Add('|---:|---:|---|---|')
  foreach ($item in $regionalGroup.Group) {
    $lines.Add("| $($item.territorio) | $($item.codigo_bairro) | $($item.bairro) | $($item.codigo_regiao) |")
  }
  $lines.Add('')
}
$lines.Add('## Estado')
$lines.Add('')
$lines.Add('Matriz gerada para revisão e homologação humana. Nenhuma alteração no Firestore é autorizada por este documento.')
[IO.File]::WriteAllLines((Join-Path (Get-Location) $OutputMarkdown), $lines, [Text.UTF8Encoding]::new($false))

[pscustomobject]@{
  bairros = $catalog.Count
  regionais = ($catalog.regional | Sort-Object -Unique).Count
  territorios = ($catalog.territorio | Sort-Object -Unique).Count
  duplicidades = $catalog.Count - ($normalized | Sort-Object -Unique).Count
  csv = $OutputCsv
  matriz = $OutputMarkdown
}

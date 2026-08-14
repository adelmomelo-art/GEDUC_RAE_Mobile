param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [string]$OutputDirectory = 'assets\geo'
)

$ErrorActionPreference = 'Stop'
$expectedHash = 'D04B16BBAD3DD205AA19C616CD8CB4D4061917234E656AEF3DF18159CAEF0CCE'
$sourcePage = 'https://mapas.fortaleza.ce.gov.br/mapa/21/bairros-de-fortaleza'

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
  throw "GeoJSON não encontrado: $Source. Fonte: $sourcePage"
}
$actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash
if ($actualHash -ne $expectedHash) {
  throw "SHA-256 divergente. Esperado: $expectedHash; obtido: $actualHash"
}
$geoJson = Get-Content -Raw -LiteralPath $Source -Encoding UTF8 | ConvertFrom-Json
if ($geoJson.type -ne 'FeatureCollection' -or $geoJson.features.Count -ne 121) {
  throw 'GeoJSON oficial deve conter uma FeatureCollection com 121 feições.'
}
$names = @($geoJson.features | ForEach-Object { $_.properties.Nome })
if (($names | Sort-Object -Unique).Count -ne 121) {
  throw 'Os 121 bairros devem possuir nomes únicos.'
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$target = Join-Path $OutputDirectory 'bairros_fortaleza_ipplanfor.geojson'
[IO.File]::WriteAllBytes((Join-Path (Get-Location) $target), [IO.File]::ReadAllBytes((Resolve-Path $Source)))
$manifest = [ordered]@{
  dataset = 'Bairros de Fortaleza'
  provider = 'IPLANFOR - Prefeitura de Fortaleza'
  sourcePage = $sourcePage
  capturedAt = '2026-08-13'
  crs = 'EPSG:4326'
  featureCount = 121
  geoJsonAsset = 'assets/geo/bairros_fortaleza_ipplanfor.geojson'
  geoJsonSha256 = $expectedHash
  attribution = 'Fonte: IPLANFOR ' + [char]0x2014 + ' Fortaleza em Mapas, Bairros de Fortaleza'
}
$manifestJson = $manifest | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText(
  (Join-Path (Get-Location) (Join-Path $OutputDirectory 'manifesto_bairros_fortaleza.json')),
  $manifestJson + [Environment]::NewLine,
  [Text.UTF8Encoding]::new($false)
)

[pscustomobject]@{ features = 121; sha256 = $actualHash; geoJson = $target }

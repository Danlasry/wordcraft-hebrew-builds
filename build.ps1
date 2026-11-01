$ErrorActionPreference = 'Stop'
function Run-Native {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed: $LASTEXITCODE" }
}
$Root = $PSScriptRoot
$Source = Join-Path $Root 'source'
$Catalog = Join-Path $Root 'catalog'
$Dist = Join-Path $Root 'dist'
$SourceRev = 'eecbb8fe57a56340e7fa109e8da7f1376a03e154'
$CatalogRev = '19358491340b9f33d618673de6bcd40108d9a775'
function Checkout-Pinned {
    param([string]$Directory, [string]$Url, [string]$Revision)
    if (Test-Path $Directory) { throw "Use a fresh directory: $Directory" }
    Run-Native git @('init', $Directory)
    Run-Native git @('-C', $Directory, 'config', 'core.autocrlf', 'false')
    Run-Native git @('-C', $Directory, 'remote', 'add', 'origin', $Url)
    Run-Native git @('-C', $Directory, 'fetch', '--depth', '1', 'origin', $Revision)
    Run-Native git @('-C', $Directory, 'checkout', '--detach', $Revision)
}
Checkout-Pinned $Source 'https://github.com/storytold/wordcraft.git' $SourceRev
Checkout-Pinned $Catalog 'https://github.com/storytold/craft-i18n.git' $CatalogRev
foreach ($Name in @('hebrew.patch', 'pointer-fix.patch', 'gray-theme.patch')) {
    $Patch = Join-Path $Root "patches/$Name"
    # Git on Windows may check out patch files with CRLF; unified diffs require LF.
    $PatchText = [IO.File]::ReadAllText($Patch).Replace("`r`n", "`n")
    [IO.File]::WriteAllText($Patch, $PatchText, [Text.UTF8Encoding]::new($false))
    Run-Native git @('-C', $Source, 'apply', '--check', $Patch)
    Run-Native git @('-C', $Source, 'apply', $Patch)
}
$env:CRAFT_I18N_DIR = $Catalog
$env:CRAFT_I18N_REQUIRED = '1'
Push-Location $Source
try {
    foreach ($Filter in @('hebrew', 'ibeam::tests', 'mirror::tests', 'theme::tests', 'interface_theme', 'dark_page_leaves')) {
        Run-Native cargo @('+1.95.0', 'test', '--locked', '-p', 'wordcraft-ui-egui', '--lib', $Filter)
    }
    Run-Native cargo @('+1.95.0', 'build', '--locked', '--release', '-p', 'wordcraft', '--target', 'x86_64-pc-windows-msvc')
} finally { Pop-Location }
New-Item -ItemType Directory -Path $Dist -Force | Out-Null
Copy-Item (Join-Path $Source 'target/x86_64-pc-windows-msvc/release/wordcraft.exe') $Dist
Copy-Item (Join-Path $Root 'LICENSE-MIT'), (Join-Path $Root 'LICENSE-APACHE') $Dist
Copy-Item (Join-Path $Root 'README.md') $Dist
@("WordCraft source: $SourceRev", "Translation catalog: $CatalogRev", "Build configuration: $env:GITHUB_SHA", 'Rust: 1.95.0', 'Target: x86_64-pc-windows-msvc') | Set-Content (Join-Path $Dist 'BUILD-INFO.txt')
$Hash = (Get-FileHash (Join-Path $Dist 'wordcraft.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
"$Hash  wordcraft.exe" | Set-Content (Join-Path $Dist 'SHA256SUMS.txt')

# Activate starship cross-shell prompt.
# @note Updated 2026-05-31.
function _koopa_activate_starship {
    $starship = Join-Path $env:KOOPA_PREFIX 'bin/starship'
    if (-not (Test-Path $starship)) { return }
    $cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/starship-powershell.ps1'
    if ((-not (Test-Path $cacheFile)) -or ((Get-Item $starship).LastWriteTime -gt (Get-Item $cacheFile).LastWriteTime)) {
        New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
        & $starship init powershell | Set-Content $cacheFile
    }
    . $cacheFile
}

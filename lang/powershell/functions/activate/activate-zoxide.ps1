# Activate zoxide.
# @note Updated 2026-05-31.
function _koopa_activate_zoxide {
    $zoxide = Join-Path $env:KOOPA_PREFIX 'bin/zoxide'
    if (-not (Test-Path $zoxide)) { return }
    $cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/zoxide-powershell.ps1'
    if ((-not (Test-Path $cacheFile)) -or ((Get-Item $zoxide).LastWriteTime -gt (Get-Item $cacheFile).LastWriteTime)) {
        New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
        & $zoxide init powershell | Set-Content $cacheFile
    }
    . $cacheFile
}

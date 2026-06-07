# Activate direnv.
# @note Updated 2026-05-31.
function _koopa_activate_direnv {
    $direnv = Join-Path $env:KOOPA_PREFIX 'bin/direnv'
    if (-not (Test-Path $direnv)) { return }
    $cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/direnv-hook-powershell.ps1'
    if ((-not (Test-Path $cacheFile)) -or ((Get-Item $direnv).LastWriteTime -gt (Get-Item $cacheFile).LastWriteTime)) {
        New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
        & $direnv hook pwsh | Set-Content $cacheFile
    }
    . $cacheFile
}

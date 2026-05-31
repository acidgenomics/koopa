# Activate conda.
# @note Updated 2026-05-31.
function _koopa_activate_conda {
    $prefix = Join-Path $env:KOOPA_PREFIX 'opt/conda'
    if (-not (Test-Path $prefix -PathType Container)) {
        return
    }
    $conda = Join-Path $prefix 'bin/conda'
    if (-not (Test-Path $conda)) {
        return
    }
    $cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/conda-powershell.ps1'
    if ((-not (Test-Path $cacheFile)) -or ((Get-Item $conda).LastWriteTime -gt (Get-Item $cacheFile).LastWriteTime)) {
        New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
        & $conda shell.powershell hook | Set-Content $cacheFile
    }
    . $cacheFile
}

# Activate conda.
# @note Updated 2026-05-12.
function _koopa_activate_conda {
    $prefix = Join-Path (_koopa_opt_prefix) 'conda'
    if (-not (Test-Path $prefix -PathType Container)) {
        return
    }
    $conda = Join-Path $prefix 'bin/conda'
    if (-not (Test-Path $conda)) {
        return
    }
    Invoke-Expression (& $conda shell.powershell hook)
}

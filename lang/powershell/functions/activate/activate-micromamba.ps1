# Activate micromamba environment variables.
# @note Updated 2026-06-13.
function _koopa_activate_micromamba {
    if (-not $env:MAMBA_ROOT_PREFIX) {
        $env:MAMBA_ROOT_PREFIX = Join-Path $HOME '.mamba'
    }
}

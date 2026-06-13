# Activate Julia environment variables.
# @note Updated 2026-06-13.
function _koopa_activate_julia {
    $julia = Join-Path $env:KOOPA_PREFIX 'bin/julia'
    if (-not (Test-Path $julia)) { return }
    $env:JULIA_DEPOT_PATH = Join-Path $HOME '.julia'
    $env:JULIA_NUM_THREADS = $env:KOOPA_CPU_COUNT
}

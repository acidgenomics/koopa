# Conditionally activate koopa bootstrap in current path.
# @note Updated 2026-05-01.
function _koopa_activate_bootstrap {
    $bootstrapPrefix = Join-Path (_koopa_xdg_data_home) 'koopa-bootstrap'
    if (-not (Test-Path $bootstrapPrefix -PathType Container)) {
        return
    }
    $optPrefix = _koopa_opt_prefix
    $hasAll = (
        (Test-Path (Join-Path $optPrefix 'bash')) -and
        (Test-Path (Join-Path $optPrefix 'coreutils')) -and
        (Test-Path (Join-Path $optPrefix 'openssl3')) -and
        (Test-Path (Join-Path $optPrefix 'python3.14')) -and
        (Test-Path (Join-Path $optPrefix 'zlib'))
    )
    if ($hasAll) {
        return
    }
    _koopa_add_to_path_start (Join-Path $bootstrapPrefix 'bin')
}

# Custom application install prefix.
# @note Updated 2026-05-01.
function _koopa_opt_prefix {
    return (Join-Path $env:KOOPA_PREFIX 'opt')
}

# Koopa binary prefix.
# @note Updated 2026-05-01.
function _koopa_bin_prefix {
    return (Join-Path $env:KOOPA_PREFIX 'bin')
}

# Koopa binary prefix.
# @note Updated 2026-05-01.
export def _koopa_bin_prefix []: [nothing -> string] {
    $"($env.KOOPA_PREFIX)/bin"
}

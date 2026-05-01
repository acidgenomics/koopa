# Custom application install prefix.
# @note Updated 2026-05-01.
export def _koopa_opt_prefix [] -> string {
    $"($env.KOOPA_PREFIX)/opt"
}

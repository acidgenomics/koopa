# Conditionally activate koopa bootstrap in current path.
# @note Updated 2026-05-01.
export def _koopa_activate_bootstrap [] {
    let bootstrap_prefix = $"((_koopa_xdg_data_home))/koopa-bootstrap"
    if not ($bootstrap_prefix | path exists) {
        return
    }
    let opt_prefix = (_koopa_opt_prefix)
    let has_all = (
        ($"($opt_prefix)/bash" | path exists) and
        ($"($opt_prefix)/coreutils" | path exists) and
        ($"($opt_prefix)/openssl3" | path exists) and
        ($"($opt_prefix)/python3.12" | path exists) and
        ($"($opt_prefix)/zlib" | path exists)
    )
    if $has_all {
        return
    }
    _koopa_add_to_path_start $"($bootstrap_prefix)/bin"
}

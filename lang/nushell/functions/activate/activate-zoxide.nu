# Activate zoxide.
# @note Updated 2026-05-01.
#
# Zoxide provides native nushell support. This function checks for the
# binary and runs its init. The output of 'zoxide init nushell' must be
# sourced at parse time. To use:
#
#     In env.nu or config.nu:
#     source ~/.cache/koopa/zoxide.nu
#
#     Generate with:
#     zoxide init nushell | save -f ~/.cache/koopa/zoxide.nu
export def _koopa_activate_zoxide [] {
    let zoxide = $"($env.KOOPA_PREFIX)/bin/zoxide"
    if not ($zoxide | path exists) {
        return
    }
    let cache_dir = $"($env.HOME)/.cache/koopa"
    let cache_file = $"($cache_dir)/zoxide.nu"
    if not ($cache_dir | path exists) {
        mkdir $cache_dir
    }
    ^$zoxide init nushell | save -f $cache_file
}

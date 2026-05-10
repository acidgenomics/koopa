# Activate starship cross-shell prompt.
# @note Updated 2026-05-01.
#
# Starship provides native nushell support. The output of
# 'starship init nu' must be sourced at parse time. To use:
#
#     In env.nu or config.nu:
#     source ~/.cache/koopa/starship.nu
#
#     Generate with:
#     starship init nu | save -f ~/.cache/koopa/starship.nu
export def _koopa_activate_starship [] {
    let starship = $"($env.KOOPA_PREFIX)/bin/starship"
    if not ($starship | path exists) {
        return
    }
    let cache_dir = $"($env.HOME)/.cache/koopa"
    let cache_file = $"($cache_dir)/starship.nu"
    if not ($cache_dir | path exists) {
        mkdir $cache_dir
    }
    ^$starship init nu | save -f $cache_file
}

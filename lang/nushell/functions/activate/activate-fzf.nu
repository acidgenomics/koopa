# Activate fzf, command-line fuzzy finder.
# @note Updated 2026-05-01.
export def _koopa_activate_fzf [] {
    let fzf = $"($env.KOOPA_PREFIX)/bin/fzf"
    if not ($fzf | path exists) {
        return
    }
    if not ("FZF_DEFAULT_OPTS" in $env) {
        $env.FZF_DEFAULT_OPTS = "--border --color bw --multi"
    }
}

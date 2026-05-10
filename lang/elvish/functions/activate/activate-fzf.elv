# Activate fzf, command-line fuzzy finder.
# @note Updated 2026-05-01.
fn activate-fzf {
    var fzf = $E:KOOPA_PREFIX'/bin/fzf'
    if (not (path:is-regular &follow-symlink $fzf)) {
        return
    }
    if (not (has-env FZF_DEFAULT_OPTS)) {
        set-env FZF_DEFAULT_OPTS '--border --color bw --multi'
    }
}

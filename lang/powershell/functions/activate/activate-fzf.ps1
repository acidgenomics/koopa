# Activate fzf, command-line fuzzy finder.
# @note Updated 2026-05-01.
function _koopa_activate_fzf {
    $fzf = Join-Path $env:KOOPA_PREFIX 'bin/fzf'
    if (-not (Test-Path $fzf)) { return }
    if (-not $env:FZF_DEFAULT_OPTS) {
        $env:FZF_DEFAULT_OPTS = '--border --color bw --multi'
    }
}

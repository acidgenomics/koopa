function _koopa_activate_fzf
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2026-05-01.
    test -x "(_koopa_bin_prefix)/fzf"; or return 0
    if not set -q FZF_DEFAULT_OPTS
        set -gx FZF_DEFAULT_OPTS '--border --color bw --multi'
    end
end

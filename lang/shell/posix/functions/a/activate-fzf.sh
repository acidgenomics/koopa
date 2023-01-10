#!/bin/sh

koopa_activate_fzf() {
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2022-05-12.
    # """
    [ -x "$(koopa_bin_prefix)/fzf" ] || return 0
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}

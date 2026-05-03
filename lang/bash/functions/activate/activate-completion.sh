#!/usr/bin/env bash

_koopa_activate_completion() {
    # """
    # Activate koopa shell completion.
    # @note Updated 2026-05-03.
    #
    # Bash: the koopa completion file lives in
    # $KOOPA_PREFIX/share/bash-completion/completions/koopa and is
    # lazy-loaded by bash-completion v2 via BASH_COMPLETION_USER_DIR.
    # No explicit activation is needed here.
    #
    # Zsh: handled by _koopa_activate_zsh_completion in the zsh layer.
    # """
    return 0
}

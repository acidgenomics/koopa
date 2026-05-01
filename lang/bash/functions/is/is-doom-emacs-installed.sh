#!/usr/bin/env bash

_koopa_is_doom_emacs_installed() {
    # """
    # Is Doom Emacs installed?
    # @note Updated 2021-10-25.
    # """
    local init_file prefix
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed 'emacs' || return 1
    prefix="$(_koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    _koopa_file_detect_fixed --file="$init_file" --pattern='doom-emacs'
}

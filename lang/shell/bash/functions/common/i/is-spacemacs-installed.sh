#!/usr/bin/env bash

koopa_is_spacemacs_installed() {
    # """
    # Is Spacemacs installed?
    # @note Updated 2022-02-17.
    # """
    local init_file prefix
    koopa_assert_has_no_args "$#"
    koopa_is_installed 'emacs' || return 1
    prefix="$(koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa_file_detect_fixed --file="$init_file" --pattern='Spacemacs'
}

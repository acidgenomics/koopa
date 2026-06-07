#!/usr/bin/env zsh

_koopa_activate_zsh_fpath() {
    _koopa_add_to_fpath_start \
        "${KOOPA_PREFIX:?}/lang/zsh/functions" \
        "${KOOPA_PREFIX:?}/share/zsh/site-functions"
    return 0
}

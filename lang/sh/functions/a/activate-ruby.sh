#!/bin/sh

_koopa_activate_ruby() {
    # """
    # Activate Ruby gems for current user.
    # @note Updated 2023-03-10.
    # """
    __kvar_prefix="${HOME:?}/.gem"
    export GEM_HOME="$__kvar_prefix"
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    unset -v __kvar_prefix
    return 0
}

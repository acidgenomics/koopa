#!/bin/sh

koopa_activate_ruby() {
    # """
    # Activate Ruby gems for current user.
    # @note Updated 2022-07-08.
    # """
    local prefix
    prefix="${HOME:?}/.gem"
    export GEM_HOME="$prefix"
    koopa_add_to_path_start "${prefix}/bin"
    return 0
}
